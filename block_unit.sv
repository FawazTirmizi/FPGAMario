module block_unit (
    input logic Clk, Reset, change_id, change_coords,
    input logic [9:0] new_Xcoord, new_Ycoord,
    input logic [3:0] new_block_id,
    
    output logic [9:0] Xcoord, Ycoord,
    output logic [3:0] block_id
);

	always_ff @ (posedge Clk) begin
		if (Reset) begin
			Xcoord <= 1'b0;
			Ycoord <= 1'b0;
			block_id <= 1'b0;
		end
		else  begin
			if (change_coords) begin
				 Xcoord <= new_Xcoord;
				 Ycoord <= new_Ycoord;
			end
			if (change_id) begin
				 block_id <= new_block_id;
			end
		end
	end

endmodule