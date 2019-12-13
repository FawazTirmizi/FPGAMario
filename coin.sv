module coin (
   input logic Clk, Reset, frame_clk,
   input logic start, Shift,
   input logic [9:0] DrawX, DrawY,
   input logic [9:0] Mario_X_Pos, Mario_Y_Pos,
   input logic [1:0] start_block,
   
   output logic coin_taken, is_coin   
);
   
   parameter [9:0] coinSize   = 10'd19;
   parameter [9:0] coin_X_Min = 10'd120;
   
   logic is_running, is_running_in;
   logic coin_taken_in;
   
   
   logic [9:0] Coin_X_Pos, Coin_Y_Pos;
   logic [9:0] Coin_X_Pos_in, Coin_Y_Pos_in;
   
   // Detect rising edge of frame_clk
   logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
      frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
   
   always_ff @ (posedge Clk) begin
      if (Reset) begin
         Coin_X_Pos <= 10'd0;
         Coin_Y_Pos <= 10'd0;
         coin_taken <= 1'b0;
         is_running <= 1'b0;
      end
      else if (start) begin
         Coin_X_Pos <= 10'd500;
         Coin_Y_Pos <= (10'd40 * start_block) - 10'd20 + 10'd160;
         coin_taken <= 1'b0;
         is_running <= 1'b1;
      end
      else if (coin_taken == 1'b1) begin
         Coin_X_Pos <= 10'd0;
         Coin_Y_Pos <= 10'd0;
         is_running <= 1'b0;
         coin_taken <= 1'b0;
      end
      else begin
         Coin_X_Pos <= Coin_X_Pos_in;
         Coin_Y_Pos <= Coin_Y_Pos_in;
         coin_taken <= coin_taken_in;
         is_running <= is_running_in;
      end
   end
   
   always_comb begin
      Coin_Y_Pos_in = Coin_Y_Pos;
      Coin_X_Pos_in = Coin_X_Pos;
      is_running_in = is_running;
      
      if (frame_clk_rising_edge) begin
         if (Coin_X_Pos < coin_X_Min) begin
            is_running_in = 1'b0;
         end
         else if (Shift) begin
            Coin_X_Pos_in = Coin_X_Pos - 10'd40;
         end
      end
   end
   
   // Taken from Lab 8's ball module
   int Size;
   assign Size = coinSize;
   
   int DistX, DistY;
   assign DistX = DrawX - Coin_X_Pos;
   assign DistY = DrawY - Coin_Y_Pos;
   always_comb begin
        if ( (( DistX*DistX + DistY*DistY) <= (Size*Size)) && is_running == 1'b1 ) 
            is_coin = 1'b1;
        else
            is_coin = 1'b0;
   end
   
   int MarioDistX, MarioDistY;
   assign MarioDistX = Mario_X_Pos - Coin_X_Pos;
   assign MarioDistY = Mario_Y_Pos - Coin_Y_Pos;
   always_comb begin
      if ( (( MarioDistX*MarioDistX + MarioDistY*MarioDistY) <= (Size*Size)) && is_running == 1'b1  ) begin
         coin_taken_in = 1'b1;
      end
      else begin
         coin_taken_in = 1'b0;
      end
   end
   
endmodule