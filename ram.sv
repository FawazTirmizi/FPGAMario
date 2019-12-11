/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameRAM
(
		input [3:0] data_In,
		input [15:0] write_address, read_address,
		input we, Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:39999];

initial
begin
	 $readmemh("SpriteSheet.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
