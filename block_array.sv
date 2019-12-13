module block_array (
   input	logic Clk, Reset, Shift,
   
	input	logic[29:0] new_block_id,
   
	input logic [9:0] drawX, drawY,
   input logic [9:0] Mario_X_Pos, Mario_Y_Pos,
   input logic [9:0] Goomba_X_Pos, Goomba_Y_Pos,
   
   output logic [2:0] mario_poll_up, mario_poll_down, mario_poll_left, mario_poll_right,
   output logic [2:0] Goomba_poll_left, Goomba_poll_right,
   output logic [2:0] block_id_out,
   output logic [7:0] current_block_col
);
	
	logic [39:0] 	blockXPixel, blockYPixel;
	logic	[9:0]		blockX, blockY;
	
   logic [9:0]    Mario_blockX, Mario_blockY;
   logic [9:0]    Mario_block_up, Mario_block_down, Mario_block_left, Mario_block_right;
   logic [4:0]    Mario_blockY_lower, Mario_block_up_lower, Mario_block_down_lower;
   
   logic [9:0]    Goomba_blockX, Goomba_blockY;
   logic [9:0]    Goomba_block_left, Goomba_block_right;
   logic [4:0]    Goomba_blockY_lower;
   
	logic [9:0][29:0] blockCols, blockCols_in;
	
   logic [4:0] block_Y_lower, block_Y_upper;
   logic [4:0] ball_block_Y_lower;
   
	always_ff @ (posedge Clk) begin
		if (Reset) begin
         current_block_col = 8'h00;
			/*
         for (int i = 0; i < 10; i++) begin
				blockCols[i] <= 1'b0;
			end
         */
         for (int i = 0; i < 10; i++) begin
            blockCols[i] = new_block_id;
            current_block_col++;
         end
         /*
         // TESTING ENVIRONMENT; COMMENT OUT WHEN USING MEMORY
         blockCols[6][29:27]  <= 3'b001;   // Draws 3 breakable bricks in a stair
         blockCols[7][29:27]  <= 3'b001;
         blockCols[7][26:24]  <= 3'b001;   
         blockCols[0][2:0]    <= 3'b011;     // Draws question block
         blockCols[4][20:18]  <= 3'b110;
         // END TEST
         */
		end
		else if (Shift) begin
			for (int i = 0; i < 9; i++) begin
				blockCols[i] <= blockCols[i + 1];
			end
         blockCols[9] <= new_block_id;
         current_block_col++;
		end
		else begin
         if (mario_poll_up == 3'b010)
            blockCols[Mario_blockX][Mario_block_up_lower+:3] = 3'b000;
			blockCols = blockCols_in;
		end
	end
	
   // Get block begin drawn
	always_comb begin
		// Put modulus math and stuffs to go from pixel to respective block
      blockX = (drawX - 8'h78) / 8'h28;
      blockY = (drawY - 8'h28) / 8'h28;
      block_Y_lower = 3 * blockY;
      //block_Y_upper = (3 * (blockY + 1)) - 1;
      block_id_out = blockCols[blockX][block_Y_lower+:3];
   end
	
   // Get blocks adjacent to Mario
   always_comb begin
      // Get the block coordinates of Mario
      Mario_blockX         = (Mario_X_Pos - 8'h78) / 8'h28;
      Mario_blockY         = (Mario_Y_Pos - 8'h28) / 8'h28;
      Mario_blockY_lower   = 3 * Mario_blockY;
      
      // Get the Y or X value of the block in whatever direction 
      Mario_block_up    = (Mario_Y_Pos - 10'd20 - 8'h28) / 8'h28;
      Mario_block_down  = (Mario_Y_Pos + 10'd20 - 8'h28) / 8'h28;
      Mario_block_left  = (Mario_X_Pos - 10'd20 - 8'h78) / 8'h28;
      Mario_block_right = (Mario_X_Pos + 10'd20 - 8'h78) / 8'h28;
      
      Mario_block_up_lower    = 3 * Mario_block_up;
      Mario_block_down_lower  = 3 * Mario_block_down;
      
      mario_poll_up     = blockCols[Mario_blockX][Mario_block_up_lower+:3];
      mario_poll_down   = blockCols[Mario_blockX][Mario_block_down_lower+:3];
      mario_poll_left   = blockCols[Mario_block_left][Mario_blockY_lower+:3];
      mario_poll_right  = blockCols[Mario_block_right][Mario_blockY_lower+:3];
      
      blockCols_in = blockCols;
      
      //if (mario_poll_up == 3'b010)
      //   blockCols_in[Mario_blockX][Mario_block_up_lower+:3] = 3'b000;
   end
   
   // Get blocks adjacent to Goomba
   always_comb begin
      // Get block coords of Goomba
      Goomba_blockX = (Goomba_X_Pos - 8'h78) / 8'h28;
      Goomba_blockY = (Goomba_Y_Pos - 8'h28) / 8'h28;
      Goomba_blockY_lower = 3 * Goomba_blockY;
      
      // Get X values of blocks adjacent to Goomba
      Goomba_block_left  = (Goomba_X_Pos - 10'd18 - 8'h78 - 10'd1) / 8'h28;
      Goomba_block_right = (Goomba_X_Pos + 10'd18 - 8'h78) / 8'h28;    

      Goomba_poll_left   = blockCols[Goomba_block_left][Goomba_blockY_lower+:3];
      Goomba_poll_right  = blockCols[Goomba_block_right][Goomba_blockY_lower+:3];
   end
endmodule