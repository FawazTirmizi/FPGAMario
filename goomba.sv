module goomba (
   input logic Clk, Reset, frame_clk,
   input logic start, kill, Shift,
   input logic [9:0] spawnX, spawnY,
   input logic [9:0] DrawX, DrawY,
   input logic [9:0] Mario_X_Pos, Mario_Y_Pos,
   input logic [2:0] Goomba_poll_left, Goomba_poll_right, // Add down eventually
   
   output logic isAlive_out,
   output logic [9:0] Goomba_X_Pos, Goomba_Y_Pos,
   output logic draw_is_goomba
   //output logic mario_is_goomba
);
  
   //parameter [9:0] Goomba_X_Center = 10'd320;  // Center position on the X axis
   //parameter [9:0] Goomba_Y_Center = 10'd240;  // Center position on the Y axis
   parameter [9:0] Goomba_X_Min  = 10'd120;       // Leftmost point on the X axis
   parameter [9:0] Goomba_X_Max  = 10'd519;     // Rightmost point on the X axis
   parameter [9:0] Goomba_Y_Min  = 10'd40;       // Topmost point on the Y axis
   parameter [9:0] Goomba_Y_Max  = 10'd439;     // Bottommost point on the Y axis
   parameter [9:0] Goomba_X_Step = 10'd1;      // Step size on the X axis
   parameter [9:0] Goomba_Y_Step = 10'd1;      // Step size on the Y axis
   parameter [9:0] Goomba_X_Size = 10'd18;        // Ball size
   parameter [9:0] Goomba_Y_Size = 10'd10;
   
   logic [9:0] Mario_below_Y;
   logic [9:0] Goomba_X_Motion, Goomba_Y_Motion;
   logic [9:0] Goomba_X_Pos_in, Goomba_X_Motion_in, Goomba_Y_Pos_in, Goomba_Y_Motion_in;

   logic			Falling, Falling_in;
   logic       isAlive, isAlive_in;
   
   assign isAlive_out = isAlive;
   
   // Detect rising edge of frame_clk
   logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
      frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
   
   // Register updating and stuffs
   always_ff @ (posedge Clk) begin
      if (Reset || kill) begin
         Goomba_X_Pos <= 1'b0;
         Goomba_Y_Pos <= 1'b0;
         Goomba_X_Motion <= 10'd0;
         Goomba_Y_Motion <= 10'd0;
			Falling <= 1'b0;
         isAlive <= 1'b0;
      end
      else if (start) begin
         Goomba_X_Pos <= spawnX;
         Goomba_Y_Pos <= spawnY - Goomba_Y_Size;
         Goomba_X_Motion <= (~(Goomba_X_Step) + 1'b1);
         Goomba_Y_Motion <= 10'd0;
         Falling <= 1'b0;
         isAlive <= 1'b1;
      end
      else begin
         Goomba_X_Pos <= Goomba_X_Pos_in;
         Goomba_Y_Pos <= Goomba_Y_Pos_in;
         Goomba_X_Motion <= Goomba_X_Motion_in;
         Goomba_Y_Motion <= Goomba_Y_Motion_in;
			Falling <= Falling_in;
         isAlive <= isAlive_in;
      end
   end
   
   // Combinational logic to control motion
   always_comb begin
      // Nothing changes by default
      Goomba_X_Pos_in = Goomba_X_Pos;
      Goomba_Y_Pos_in = Goomba_Y_Pos;
      Goomba_X_Motion_in = Goomba_X_Motion;
      Goomba_Y_Motion_in = 10'd0;
		Falling_in = Falling;
      isAlive_in = isAlive;
      
      if (frame_clk_rising_edge) begin
         if (isAlive) begin
            // Check if Mario is directly above (i.e. Goomba gonna get squished)
            if ( Goomba_X_Pos - Goomba_X_Size <= Mario_X_Pos && Mario_X_Pos < Goomba_X_Pos + Goomba_X_Size
               && Goomba_Y_Pos - Goomba_Y_Size == Mario_Y_Pos - 10'd20 ) begin
               isAlive_in = 1'b0;
            end
            // Check if Goomba walks off screen to the left
            else if (Goomba_X_Pos + Goomba_X_Size < Goomba_X_Min) begin
               isAlive_in = 1'b0;
            end
            // If no reason to kill, keep moving
            else begin
               isAlive_in = 1'b1;
               if (Goomba_poll_left != 3'b000) begin
                  Goomba_X_Motion_in = Goomba_X_Step;
               end
               if (Goomba_poll_right != 3'b000 || Goomba_X_Pos + Goomba_X_Size >= Goomba_X_Max) begin
                  Goomba_X_Motion_in = (~(Goomba_X_Step) + 1'b1);
               end
               if (Shift) begin
                  Goomba_X_Pos_in = Goomba_X_Pos - 10'd40;
               end
               else begin
                  Goomba_X_Pos_in = Goomba_X_Pos + Goomba_X_Motion;
               end
               Goomba_Y_Pos_in = Goomba_Y_Pos + Goomba_Y_Motion;
            end
         end
         else begin
            Goomba_X_Pos_in = 10'd0;
            Goomba_Y_Pos_in = 10'd0;
            Goomba_X_Motion_in = 10'd0;
            Goomba_Y_Motion_in = 10'd0;
            Falling_in = 1'b0;
            isAlive_in = 1'b0;
         end
      end
   end
   
   always_comb begin
      if (isAlive == 1'b0) begin
         draw_is_goomba = 1'b0;
      end
      else if ( Goomba_X_Pos - Goomba_X_Size <= DrawX && DrawX < Goomba_X_Pos + Goomba_X_Size
         && Goomba_Y_Pos - Goomba_Y_Size <= DrawY && DrawY < Goomba_Y_Pos + Goomba_Y_Size) begin
         draw_is_goomba = 1'b1;
      end
      else begin
         draw_is_goomba = 1'b0;
      end
   end
   /*
   always_comb begin
      Mario_below_X = Mario_X_Pos;
      Mario_below_Y = Mario_Y_Pos + 10'd20;
   
      if ( Goomba_X_Pos - Goomba_X_Size <= Mario_below_X && Mario_below_X < Goomba_X_Pos + Goomba_X_Size
         && Goomba_Y_Pos - Goomba_Y_Size == Mario_below_Y ) begin
         mario_is_goomba = 1'b1;
      end
      else begin
         mario_is_goomba = 1'b0;
      end
   end
   */
endmodule