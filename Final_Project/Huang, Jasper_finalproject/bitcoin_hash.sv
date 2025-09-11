module bitcoin_hash (
    input logic        clk, reset_n, start,
    input logic [15:0] message_addr, output_addr,
    output logic        done, mem_clk, mem_we,
    output logic [15:0] mem_addr,
    output logic [31:0] mem_write_data,
    input logic [31:0] mem_read_data
);

parameter num_nonces = 16;

logic [31:0] hout[num_nonces];
logic [31:0] message[19];
logic [31:0] w[num_nonces / 2][16];

logic [ 7:0] i, nonce;
logic [15:0] offset;

logic        cur_we;
logic [15:0] cur_addr;
logic [31:0] cur_write_data;

logic [31:0] h0[num_nonces];
logic [31:0] h1[num_nonces];
logic [31:0] h2[num_nonces];
logic [31:0] h3[num_nonces];
logic [31:0] h4[num_nonces];
logic [31:0] h5[num_nonces];
logic [31:0] h6[num_nonces];
logic [31:0] h7[num_nonces];

logic [31:0] a[num_nonces / 2];
logic [31:0] b[num_nonces / 2];
logic [31:0] c[num_nonces / 2];
logic [31:0] d[num_nonces / 2];
logic [31:0] e[num_nonces / 2];
logic [31:0] f[num_nonces / 2];
logic [31:0] g[num_nonces / 2];
logic [31:0] h[num_nonces / 2];

logic [31:0] fh0, fh1, fh2, fh3, fh4, fh5, fh6, fh7;


parameter int k[64] = '{
  32'h428a2f98,32'h71374491,32'hb5c0fbcf,32'he9b5dba5,32'h3956c25b,32'h59f111f1,32'h923f82a4,32'hab1c5ed5,
  32'hd807aa98,32'h12835b01,32'h243185be,32'h550c7dc3,32'h72be5d74,32'h80deb1fe,32'h9bdc06a7,32'hc19bf174,
  32'he49b69c1,32'hefbe4786,32'h0fc19dc6,32'h240ca1cc,32'h2de92c6f,32'h4a7484aa,32'h5cb0a9dc,32'h76f988da,
  32'h983e5152,32'ha831c66d,32'hb00327c8,32'hbf597fc7,32'hc6e00bf3,32'hd5a79147,32'h06ca6351,32'h14292967,
  32'h27b70a85,32'h2e1b2138,32'h4d2c6dfc,32'h53380d13,32'h650a7354,32'h766a0abb,32'h81c2c92e,32'h92722c85,
  32'ha2bfe8a1,32'ha81a664b,32'hc24b8b70,32'hc76c51a3,32'hd192e819,32'hd6990624,32'hf40e3585,32'h106aa070,
  32'h19a4c116,32'h1e376c08,32'h2748774c,32'h34b0bcb5,32'h391c0cb3,32'h4ed8aa4a,32'h5b9cca4f,32'h682e6ff3,
  32'h748f82ee,32'h78a5636f,32'h84c87814,32'h8cc70208,32'h90befffa,32'ha4506ceb,32'hbef9a3f7,32'hc67178f2
};

enum logic [3:0] {
  IDLE,
	WAIT,
  READ,
  P1_PREP, P1_RUN,
	NONCE_PREP,
  P2_PREP, P2_RUN,
  P3_PREP, P3_RUN,
  WRITE_PREP, WRITE
} state;


function logic [255:0] sha256_op(input logic [31:0] a, b, c, d, e, f, g, h, w,
                                 input logic [7:0] t);
  logic [31:0] S1, S0, ch, maj, t1, t2; // internal signals
  begin
    S1 = rightrotate(e, 6) ^ rightrotate(e, 11) ^ rightrotate(e, 25);
    // Student to add remaning code below
    // Refer to SHA256 discussion slides to get logic for this function
    ch = (e & f) ^ ((~e) & g);
    t1 = h + S1 + ch + k[t] + w;
    S0 = rightrotate(a, 2) ^ rightrotate(a, 13) ^ rightrotate(a, 22);
    maj = (a & b) ^ (a & c) ^ (b & c);
    t2 = S0 + maj;
    sha256_op = {t1 + t2, a, b, c, d + t1, e, f, g};
  end
endfunction


function logic [31:0] rightrotate(input logic [31:0] x, input logic [ 7:0] r);
  rightrotate = (x >> r) | (x << (32 - r));
endfunction


function logic [31:0] wtnew(input logic [7:0] n);
  logic [31:0] s1, s0;
  s0 = rightrotate(w[n][1], 7) ^ rightrotate(w[n][1], 18) ^ (w[n][1] >> 3);
  s1 = rightrotate(w[n][14], 17) ^ rightrotate(w[n][14], 19) ^ (w[n][14] >> 10);
  wtnew = w[n][0] + s0 + w[n][9] + s1;
endfunction

assign mem_clk = clk;
assign mem_addr = cur_addr + offset;
assign mem_we = cur_we;
assign mem_write_data = cur_write_data;

always_ff @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
      state <= IDLE;

      cur_we <= 0;
      cur_addr <= 0;
      cur_write_data <= 0;

      i <= 0;
      nonce <= 0;
      offset <= 0;
      
  end else begin
    case (state)
      IDLE: begin
        if (start) begin
          i <= 0;
          cur_addr <= message_addr;
          state <= WAIT;
        end
      end
      WAIT: begin
        cur_we <= 1'b0;
        offset <= offset + 16'd1;
        state <= READ;
      end

      READ: begin
				message[i] <= mem_read_data;
				i <= i + 8'd1;
      	offset <= offset + 16'd1;
				if (i == 18) begin
					state <= P1_PREP;
        	i <= 0;
					nonce <= 0;
					cur_addr <= 0;
					offset <= 0;
				end
      end

			P1_PREP: begin
				for (int j = 0; j < 16; j = j + 1)
          w[0][j] <= message[j];
				
				fh0 <= 32'h6a09e667;
				fh1 <= 32'hbb67ae85;
				fh2 <= 32'h3c6ef372;
				fh3 <= 32'ha54ff53a;
				fh4 <= 32'h510e527f;
				fh5 <= 32'h9b05688c;
				fh6 <= 32'h1f83d9ab;
				fh7 <= 32'h5be0cd19;

				a[0] <= 32'h6a09e667;
				b[0] <= 32'hbb67ae85;
				c[0] <= 32'h3c6ef372;
				d[0] <= 32'ha54ff53a;
				e[0] <= 32'h510e527f;
				f[0] <= 32'h9b05688c;
				g[0] <= 32'h1f83d9ab;
				h[0] <= 32'h5be0cd19;
				i <= 0;

				state <= P1_RUN;
			end

			P1_RUN: begin
				if (i <= 64) begin
					if (i < 16) 
						{a[0], b[0], c[0], d[0], e[0], f[0], g[0], h[0]} <= sha256_op(a[0], b[0], c[0], d[0], e[0], f[0], g[0], h[0], w[0][i], i);
					else begin
						for (int n=0; n<15; n++) w[0][n] <= w[0][n+1];
						w[0][15] <= wtnew(.n(0));
						if (i != 16)
            	{a[0], b[0], c[0], d[0], e[0], f[0], g[0], h[0]} <= sha256_op(a[0], b[0], c[0], d[0], e[0], f[0], g[0], h[0], w[0][15], i - 1);
					end
					i <= i + 8'd1;
				end else begin
					fh0 <= fh0 + a[0];
					fh1 <= fh1 + b[0];
					fh2 <= fh2 + c[0];
					fh3 <= fh3 + d[0];
					fh4 <= fh4 + e[0];
					fh5 <= fh5 + f[0];
					fh6 <= fh6 + g[0];
					fh7 <= fh7 + h[0];
					nonce <= 0;
					state <= NONCE_PREP;
				end
			end

			NONCE_PREP: begin
				if (nonce < 16) begin
					state <= P2_PREP;
				end else begin
					state <= WRITE_PREP;
				end
			end

			P2_PREP: begin
				for (int j = 0; j < 8; j = j + 1) begin
					for (int k = 0; k < 3; k++) w[j][k] <= message[k + 16];

					w[j][3] <= j + nonce;
					w[j][4] <= 32'h80000000;

					for (int k = 5; k < 15; k = k + 1)
						w[j][k] <= 32'h00000000;
					
					w[j][15] = 32'd640;
					
					h0[j + nonce] <= fh0;
					h1[j + nonce] <= fh1;
					h2[j + nonce] <= fh2;
					h3[j + nonce] <= fh3;
					h4[j + nonce] <= fh4;
					h5[j + nonce] <= fh5;
					h6[j + nonce] <= fh6;
					h7[j + nonce] <= fh7;
					{a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j]} <= {fh0,fh1,fh2,fh3,fh4,fh5,fh6,fh7};
				end
				i <= 0;
				state <= P2_RUN;
			end

			P2_RUN: begin
				if (i <= 64) begin
					for (int j = 0; j < 8; j = j + 1) begin
						if (i < 16)
							{a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j]} <= sha256_op(a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j], w[j][i], i);
						else begin
							for (int n=0; n<15; n++) w[j][n] <= w[j][n+1];
							w[j][15] <= wtnew(.n(j));
							if (i != 16)
								{a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j]} <= sha256_op(a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j], w[j][15], i - 1);
						end
					end
					i <= i + 8'd1;
				end else begin
					for (int j = 0; j < 8; j = j + 1) begin
						h0[nonce + j] <= h0[nonce + j] + a[j];
						h1[nonce + j] <= h1[nonce + j] + b[j];
						h2[nonce + j] <= h2[nonce + j] + c[j];
						h3[nonce + j] <= h3[nonce + j] + d[j];
						h4[nonce + j] <= h4[nonce + j] + e[j];
						h5[nonce + j] <= h5[nonce + j] + f[j];
						h6[nonce + j] <= h6[nonce + j] + g[j];
						h7[nonce + j] <= h7[nonce + j] + h[j];
					end
					state <= P3_PREP;
				end
			end

			P3_PREP: begin
				for (int j = 0; j < 8; j = j + 1) begin
					w[j][0] <= h0[nonce + j];
					w[j][1] <= h1[nonce + j];
					w[j][2] <= h2[nonce + j];
					w[j][3] <= h3[nonce + j];
					w[j][4] <= h4[nonce + j];
					w[j][5] <= h5[nonce + j];
					w[j][6] <= h6[nonce + j];
					w[j][7] <= h7[nonce + j];
					w[j][8] <= 32'h80000000;

					for (int t = 9; t < 15; t++) begin
						w[j][t] <= 32'h00000000;
					end

					w[j][15] <= 32'd256;

					h0[nonce + j] <= 32'h6a09e667;
					h1[nonce + j] <= 32'hbb67ae85;
					h2[nonce + j] <= 32'h3c6ef372;
					h3[nonce + j] <= 32'ha54ff53a;
					h4[nonce + j] <= 32'h510e527f;
					h5[nonce + j] <= 32'h9b05688c;
					h6[nonce + j] <= 32'h1f83d9ab;
					h7[nonce + j] <= 32'h5be0cd19;

					
					a[j] <= 32'h6a09e667;
					b[j] <= 32'hbb67ae85;
					c[j] <= 32'h3c6ef372;
					d[j] <= 32'ha54ff53a;
					e[j] <= 32'h510e527f;
					f[j] <= 32'h9b05688c;
					g[j] <= 32'h1f83d9ab;
					h[j] <= 32'h5be0cd19;
				end
				i <= 0;
				state <= P3_RUN;
			end

			P3_RUN: begin
				if (i <= 64) begin
					for (int j = 0; j < 8; j = j + 1) begin
						if (i < 16)
							{a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j]} <= sha256_op(a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j], w[j][i], i);
						else begin
							for (int n=0; n<15; n++) w[j][n] <= w[j][n+1];
							w[j][15] <= wtnew(.n(j));
							if (i != 16)
								{a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j]} <= sha256_op(a[j],b[j],c[j],d[j],e[j],f[j],g[j],h[j], w[j][15], i - 1);
						end
					end
					i <= i + 8'd1;
				end else begin
					for (int j = 0; j < 8; j = j + 1) begin
						h0[nonce + j] <= h0[nonce + j] + a[j];
						h1[nonce + j] <= h1[nonce + j] + b[j];
						h2[nonce + j] <= h2[nonce + j] + c[j];
						h3[nonce + j] <= h3[nonce + j] + d[j];
						h4[nonce + j] <= h4[nonce + j] + e[j];
						h5[nonce + j] <= h5[nonce + j] + f[j];
						h6[nonce + j] <= h6[nonce + j] + g[j];
						h7[nonce + j] <= h7[nonce + j] + h[j];
					end
					nonce <= nonce + 8'd8;
					state <= NONCE_PREP;
				end
			end

			WRITE_PREP: begin
				hout <= h0;
				state <= WRITE;
				i <= 0;
        offset <= 0;
			end

			WRITE: begin
				cur_we <= 1;
				cur_addr <= output_addr;

				cur_write_data <= hout[i];
				
				if (i < 16) begin
					i <= i + 8'd1;
					offset <= i;
				end else begin
					cur_we <= 0;
					state <= IDLE;
				end
			end
    endcase
  end
end

assign done = (state == IDLE);
endmodule
