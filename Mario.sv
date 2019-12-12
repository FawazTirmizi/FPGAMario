module Mario (
   input logic Clk, Reset, frame_clk,
   input logic [9:0] DrawX, DrawY,
   input logic [15:0] keycode,
   input logic [2:0] mario_poll_up, mario_poll_down, mario_poll_left, mario_poll_right,
   
   
   output logic[9:0] Mario_X_Pos, Mario_Y_Pos,
   output logic is_mario, Shift,
   output logic is_jumping, direction,
   output logic [1:0] run_counter
);

   parameter [9:0] Mario_X_Center   = 10'd320;  // Center position on the X axis
   parameter [9:0] Mario_Y_Center   = 10'd240;  // Center position on the Y axis
   parameter [9:0] Mario_X_Min      = 10'd120;  // Leftmost point on the X axis
   parameter [9:0] Mario_X_Max      = 10'd519;  // Rightmost point on the X axis
   parameter [9:0] Mario_Y_Min      = 10'd40;   // Topmost point on the Y axis
   parameter [9:0] Mario_Y_Max      = 10'd439;  // Bottommost point on the Y axis
   parameter [9:0] Mario_X_Step     = 10'd2;    // Step size on the X axis
   parameter [9:0] Mario_Y_Step     = 10'd2;    // Step size on the Y axis
   parameter [9:0] Mario_X_Size     = 10'd20;   // Mario width
   parameter [9:0] Mario_Y_Size     = 10'd20;   // Mario height
    
   logic [9:0] Mario_X_Motion, Mario_Y_Motion;
   logic [9:0] Mario_X_Pos_in, Mario_X_Motion_in, Mario_Y_Pos_in, Mario_Y_Motion_in;
   
	logic [6:0] Jump_Counter, Jump_Counter_in;
	logic			Falling, Falling_in;
   logic       is_jumping_in, direction_in;
   logic [1:0] run_counter_in;
   logic [3:0] run_sprite_timer, run_sprite_timer_in;
   
   // Detect rising edge of frame_clk
   logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
      frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
   
   // Register updating and stuffs
   always_ff @ (posedge Clk) begin
      if (Reset) begin
         Mario_X_Pos    <= (Mario_X_Min + 10'd20);
         Mario_Y_Pos    <= Mario_Y_Max - Mario_Y_Size;
         Mario_X_Motion <= 10'd0;
         Mario_Y_Motion <= 10'd0;
			Falling        <= 1'b0;
			Jump_Counter   <= 1'b0;
         run_counter    <= 2'b0;
         is_jumping     <= 1'b0;
         direction      <= 1'b0;
         run_sprite_timer <= 4'hF;
      end
      else begin
         Mario_X_Pos    <= Mario_X_Pos_in;
         Mario_Y_Pos    <= Mario_Y_Pos_in;
         Mario_X_Motion <= Mario_X_Motion_in;
         Mario_Y_Motion <= Mario_Y_Motion_in;
			Falling        <= Falling_in;
         Jump_Counter   <= Jump_Counter_in;
			is_jumping     <= is_jumping_in;
         run_counter    <= run_counter_in;
         direction      <= direction_in;
         run_sprite_timer <= run_sprite_timer_in;
      end
   end
   
   // Combinational shizzle wizzle
   always_comb begin
      // Nothing changes by default
      Mario_X_Pos_in = Mario_X_Pos;
      Mario_Y_Pos_in = Mario_Y_Pos;
      Mario_X_Motion_in = 10'd0;
      Mario_Y_Motion_in = 10'd0;
		Jump_Counter_in = Jump_Counter;
		Falling_in = Falling;
      Shift = 1'b0;
      is_jumping_in = is_jumping;
      run_counter_in = run_counter;
      direction_in = direction;
      run_sprite_timer_in = run_sprite_timer;
      //Mario_X_poll = Mario_X_Pos;
      //Mario_Y_poll = Mario_Y_Pos;
      
      // If we're at the rising edge stuff happens
      if (frame_clk_rising_edge) begin
         // If W is pressed, Mario isn't falling nor jumping, and the block above is empty, begin jumping
         if (keycode == 16'h001A && Falling == 1'b0 && Jump_Counter == 1'b0 && mario_poll_up == 3'b000) begin
            Mario_Y_Motion_in = (~(Mario_Y_Step) + 1'b1);
            Jump_Counter_in = 7'b0000001;
            is_jumping_in = 1'b1;
         end
         // If Mario is going up (i.e. jumping), do stuff
         else if (Jump_Counter >= 7'b0000001) begin
            is_jumping_in = 1'b1;
            // If he's hit a ceiling or he's jumped max height, start falling
            if (Jump_Counter == 7'b1001111 || Mario_Y_Pos - Mario_Y_Size <= Mario_Y_Min || mario_poll_up != 3'b000) begin // If the jump counter has maxed, begin falling
               Mario_Y_Motion_in = Mario_Y_Step;
               Falling_in = 1'b1;
               Jump_Counter_in = 7'b0000000;
            end
            else begin // If Mario is jumping, keep rising and incrementing
               Jump_Counter_in = Jump_Counter + 1'b1;
               Mario_Y_Motion_in = (~(Mario_Y_Step) + 1'b1);
            end
         end
         // If Mario is on the ground or a block stop falling
         else if ((Mario_Y_Pos + Mario_Y_Size - 1'b1 >= Mario_Y_Max || mario_poll_down != 3'b000)) begin
            Mario_Y_Motion_in = 1'b0;
            Falling_in = 1'b0;
            Jump_Counter_in = 7'b0000000;
            is_jumping_in = 1'b0;
         end
         // If Mario is falling or the block below is open air, keep falling and go down
         else if (Falling || mario_poll_down == 3'b000) begin
            Falling_in = 1'b1;
            Mario_Y_Motion_in = Mario_Y_Step;
         end
         
         // If A is pressed, the left block is empty, and Mario isn't at the left bound, move left
         if (keycode == 16'h0004 && mario_poll_left == 3'b000 && Mario_X_Pos >= Mario_X_Min + Mario_X_Size) begin
            Mario_X_Motion_in = (~(Mario_X_Step - is_jumping) + 1'b1);
            direction_in = 1'b1;
            if (run_sprite_timer == 4'h9) begin
               case (run_counter)
                  2'b00 : run_counter_in = 2'b01;
                  2'b01 : run_counter_in = 2'b10;
                  2'b10 : run_counter_in = 2'b11;
                  2'b11 : run_counter_in = 2'b10;
               endcase
               run_sprite_timer_in = 4'h0;
            end
            else begin
               run_sprite_timer_in = run_sprite_timer + 1'b1;
            end
         end
         
         // If D is pressed, the right block is empty, and Mario isn't at the right bound, move right
         else if (keycode == 16'h0007 && mario_poll_right == 3'b000 && Mario_X_Pos + Mario_X_Size <= Mario_X_Max) begin
            Mario_X_Motion_in = Mario_X_Step - is_jumping;
            direction_in = 1'b0;
            if (run_sprite_timer == 4'h9) begin
               case (run_counter)
                  2'b00 : run_counter_in = 2'b01;
                  2'b01 : run_counter_in = 2'b10;
                  2'b10 : run_counter_in = 2'b11;
                  2'b11 : run_counter_in = 2'b10;
               endcase
               run_sprite_timer_in = 4'h0;
            end
            else begin
               run_sprite_timer_in = run_sprite_timer + 1'b1;
            end
         end
         else begin
            run_counter_in = 2'b0;
         end
         
         
         Mario_Y_Pos_in = Mario_Y_Pos + Mario_Y_Motion_in;
         
         // Mario will only move to the right if he's not at the middle
         if (Mario_X_Pos + 10'd21 > (Mario_X_Max + Mario_X_Min) / 2) begin
            Mario_X_Pos_in = Mario_X_Pos - 10'd40;
            Shift = 1'b1;
         end
         else begin
            Mario_X_Pos_in = Mario_X_Pos + Mario_X_Motion_in;
            Shift = 1'b0;
         end
      end
   end
   
   always_comb begin
      if ( Mario_X_Pos - Mario_X_Size <= DrawX && DrawX < Mario_X_Pos + Mario_X_Size
         && Mario_Y_Pos - Mario_Y_Size <= DrawY && DrawY < Mario_Y_Pos + Mario_Y_Size) begin
            is_mario = 1'b1;
      end
      else begin
         is_mario = 1'b0;
      end
   end
   
endmodule