module block_array (
   input	logic Clk, Reset, Shift,
   
	input	logic[29:0] new_block_id,
   
	input logic [9:0] drawX, drawY

   //output logic block_id,
	
	//output logic [7:0] VGA_R, VGA_G, VGA_B;

);
   //BlockUnit block_unit[10][10] (.clk, .Reset, .change_id
   /*
   logic [29:0] 	blockCol_9_In, blockCol_8_In, blockCol_7_In, blockCol_6_In, 
						blockCol_5_In, blockCol_4_In, blockCol_3_In, blockCol_2_In, 
						blockCol_1_In, blockCol_0_In;
   logic [29:0]	blockCol_9_Out, blockCol_8_Out, blockCol_7_Out, blockCol_6_Out, 
						blockCol_5_Out, blockCol_4_Out, blockCol_3_Out, blockCol_2_Out, 
						blockCol_1_Out, blockCol_0_Out;
   */
    
	//logic [9:0][29:0] blockColsIn, blockColsOut
	
	logic [39:0] 	blockXPixel, blockYPixel;
	logic	[9:0]		blockX, blockY;
	
	logic [9:0][29:0] blockCols;
	
	always_ff @ (posedge Clk) begin
		if (Reset) begin
			for (int i = 0; i < 10; i++) begin
				blockCols[i] <= 1'b0;
			end
		end
		else if (Shift) begin
			for (int i = 0; i < 9; i++) begin
				blockCols[i] <= blockCols[i + 1];
			end
		end
		else begin
			blockCols <= blockCols;
		end
	end
	
	always_comb begin
		// Put modulus math and stuffs to go from pixel to respective block
	end
	
	/*
	always_comb begin
		if (Shift) begin
			for (int i = 0; i < 9; i++) begin
				blockColsIn[i] <= blockColsOut[i + 1];
			end
			blockColsIn[9] = new_block_id;
		end
		else begin
			blockColsIn = blockColsOut;
		end
	end
	*/
	 /*
    blockColumn9 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[9]),
        .block_ids(blockColsOut[9])
    );
    
    blockColumn8 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[8]),
        .block_ids(blockColsOut[8])
    );
    
    blockColumn7 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[7]),
        .block_ids(blockColsOut[7])
    );
    
    blockColumn6 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[6]),
        .block_ids(blockColsOut[6])
    );
    
    blockColumn5 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[5]),
        .block_ids(blockColsOut[5])
    );
    
    blockColumn4 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[4]),
        .block_ids(blockColsOut[4])
    );
    
    blockColumn3 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[3]),
        .block_ids(blockColsOut[3])
    );
    
    blockColumn2 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[2]),
        .block_ids(blockColsOut[2])
    );
    
    blockColumn1 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[1]),
        .block_ids(blockColsOut[1])
    );
    
    blockColumn0 block_column (
        .Clk, .Reset, .Shift,
        .new_block_ids(blockColsIn[0]),
        .block_ids(blockColsOut[0])
    );
	 */
endmodule