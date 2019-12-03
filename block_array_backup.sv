module block_array (
   input	logic Clk, Reset, Shift,
   
	input	logic[29:0] new_block_id,
   
	input logic [9:0] drawX, drawY,
   input logic [9:0] ball_X_poll, ball_Y_poll,
   
   output logic[2:0] ball_poll_block_id_out,
   output logic[2:0] block_id_out
	
	//output logic [7:0] VGA_R, VGA_G, VGA_B;

);
	
	logic [39:0] 	blockXPixel, blockYPixel;
	logic	[9:0]		blockX, blockY;
	logic [9:0]    ball_blockX, ball_blockY;
   
	logic [9:0][29:0] blockCols;
	
   logic [4:0] block_Y_lower, block_Y_upper;
   logic [4:0] ball_block_Y_lower;
   
	always_ff @ (posedge Clk) begin
		if (Reset) begin
			for (int i = 0; i < 10; i++) begin
				blockCols[i] <= 1'b0;
			end
         
         // TESTING ENVIRONMENT; COMMENT OUT WHEN USING MEMORY
         blockCols[5][29:27] <= 3'b001;   // Draws 3 breakable bricks in a stair
         blockCols[6][29:27] <= 3'b001;
         blockCols[6][26:24] <= 3'b001;   
         blockCols[0][2:0] <= 3'b011;     // Draws question block
         // END TEST
		end
		else if (Shift) begin
			for (int i = 0; i < 9; i++) begin
				blockCols[i] <= blockCols[i + 1];
			end
         blockCols[9] <= new_block_id;
		end
		else begin
			blockCols <= blockCols;
		end
	end
	
	always_comb begin
		// Put modulus math and stuffs to go from pixel to respective block
      blockX = (drawX - 8'h78) / 8'h28;
      blockY = (drawY - 8'h28) / 8'h28;
      block_Y_lower = 3 * blockY;
      //block_Y_upper = (3 * (blockY + 1)) - 1;
      block_id_out = blockCols[blockX][block_Y_lower+:3];
   end
	
   always_comb begin
      ball_blockX = (ball_X_poll - 8'h78) / 8'h28;
      ball_blockY = (ball_Y_poll - 8'h28) / 8'h28;
      ball_block_Y_lower = 3 * ball_blockY;
      //block_Y_upper = (3 * (blockY + 1)) - 1;
      ball_poll_block_id_out = blockCols[ball_blockX][ball_block_Y_lower+:3];
   end
endmodule