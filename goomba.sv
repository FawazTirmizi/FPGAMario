module goomba (
   input logic Clk, Reset, frame_clk,
   input logic start, kill, Shift,
   input logic [9:0] spawnX, spawnY,
   input logic [9:0] DrawX, DrawY,
   input logic [9:0] Mario_X_Pos, Mario_Y_Pos,
   input logic [2:0] Goomba_poll_left, Goomba_poll_right, // Add down eventually
   
   output logic isAlive_out, kill_Mario, goomba_killed,
   output logic [9:0] Goomba_X_Pos, Goomba_Y_Pos,
   output logic draw_is_goomba, goomba_sprite
   //output logic mario_is_goomba
);
  
   //parameter [9:0] Goomba_X_Center = 10'd320;   // Center position on the X axis
   //parameter [9:0] Goomba_Y_Center = 10'd240;   // Center position on the Y axis
   parameter [9:0] Goomba_X_Min  = 10'd120;     // Leftmost point on the X axis
   parameter [9:0] Goomba_X_Max  = 10'd519;     // Rightmost point on the X axis
   parameter [9:0] Goomba_Y_Min  = 10'd40;      // Topmost point on the Y axis
   parameter [9:0] Goomba_Y_Max  = 10'd439;     // Bottommost point on the Y axis
   parameter [9:0] Goomba_X_Step = 10'd1;       // Step size on the X axis
   parameter [9:0] Goomba_Y_Step = 10'd1;       // Step size on the Y axis
   parameter [9:0] Goomba_X_Size = 10'd20;      // Goomba horizontal size
   parameter [9:0] Goomba_Y_Size = 10'd20;      // Goomba vertical size
   
   logic [9:0] Mario_below_Y;
   logic [9:0] Goomba_X_Motion, Goomba_Y_Motion;
   logic [9:0] Goomba_X_Pos_in, Goomba_X_Motion_in, Goomba_Y_Pos_in, Goomba_Y_Motion_in;

   logic			Falling, Falling_in;
   logic       isAlive, isAlive_in;
   logic       kill_Mario_in;
   logic       goomba_sprite_in;
   logic       goomba_killed_in;
   logic [3:0] sprite_timer, sprite_timer_in;
   
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
         Goomba_X_Pos      <= 1'b0;
         Goomba_Y_Pos      <= 1'b0;
         Goomba_X_Motion   <= 10'd0;
         Goomba_Y_Motion   <= 10'd0;
			Falling           <= 1'b0;
         isAlive           <= 1'b0;
         kill_Mario        <= 1'b0;
         goomba_sprite     <= 1'b0;
         sprite_timer      <= 4'hF;
         goomba_killed     <= 1'b0;
      end
      else if (start) begin
         Goomba_X_Pos      <= spawnX;
         Goomba_Y_Pos      <= spawnY - Goomba_Y_Size;
         Goomba_X_Motion   <= (~(Goomba_X_Step) + 1'b1);
         Goomba_Y_Motion   <= 10'd0;
         Falling           <= 1'b0;
         isAlive           <= 1'b1;
         kill_Mario        <= 1'b0;
         goomba_sprite     <= 1'b0;
         sprite_timer      <= 4'hF;
         goomba_killed     <= 1'b0;
      end
      else begin
         Goomba_X_Pos      <= Goomba_X_Pos_in;
         Goomba_Y_Pos      <= Goomba_Y_Pos_in;
         Goomba_X_Motion   <= Goomba_X_Motion_in;
         Goomba_Y_Motion   <= Goomba_Y_Motion_in;
			Falling           <= Falling_in;
         isAlive           <= isAlive_in;
         kill_Mario        <= kill_Mario_in;
         goomba_sprite     <= goomba_sprite_in;
         sprite_timer      <= sprite_timer_in;
         goomba_killed     <= goomba_killed_in;
      end
   end
   
   // Combinational logic to control motion
   always_comb begin
      // Nothing changes by default
      Goomba_X_Pos_in      = Goomba_X_Pos;
      Goomba_Y_Pos_in      = Goomba_Y_Pos;
      Goomba_X_Motion_in   = Goomba_X_Motion;
      Goomba_Y_Motion_in   = 10'd0;
		Falling_in           = Falling;
      isAlive_in           = isAlive;
      kill_Mario_in        = kill_Mario;
      goomba_sprite_in     = goomba_sprite;
      sprite_timer_in      = sprite_timer;
      goomba_killed_in     = 1'b0;
      
      if (frame_clk_rising_edge) begin
         if (isAlive) begin
            // Check if Mario is directly above (i.e. Goomba gonna get squished)
            if ( Goomba_X_Pos - Goomba_X_Size <= Mario_X_Pos && Mario_X_Pos < Goomba_X_Pos + Goomba_X_Size
               && Goomba_Y_Pos - Goomba_Y_Size <= Mario_Y_Pos + 10'd20) begin
               isAlive_in = 1'b0; // Kill Goomba
               goomba_killed_in = 1'b1; // Give points
            end
            // Check if Goomba can kill Mario
            else if ((Goomba_X_Pos - Goomba_X_Size == Mario_X_Pos + 10'd20 ||
               Goomba_X_Pos + Goomba_X_Size == Mario_X_Pos - 10'd20) &&
               (Mario_Y_Pos + 10'd20 > Goomba_Y_Pos - Goomba_Y_Size)) begin
               kill_Mario_in = 1'b1; // Kill Mario; reset game
            end
            // Check if Goomba walks off screen to the left
            else if (Goomba_X_Pos + Goomba_X_Size < Goomba_X_Min) begin
               isAlive_in = 1'b0;
            end
            // If no reason to kill, keep moving
            else begin
               // Timing for Goomba's motion
               if (sprite_timer == 4'hF) begin
                  goomba_sprite_in = ~goomba_sprite;
               end
               sprite_timer_in = sprite_timer + 1'b1;
               
               isAlive_in = 1'b1;
               
               // Check if Goomba collides with anything, and if so turn
               if (Goomba_poll_left != 3'b000) begin
                  Goomba_X_Motion_in = Goomba_X_Step;
               end
               else if (Goomba_poll_right != 3'b000 || Goomba_X_Pos + Goomba_X_Size >= Goomba_X_Max) begin
                  Goomba_X_Motion_in = (~(Goomba_X_Step) + 1'b1);
               end
               
               
               if (Shift) begin // Ensures that Goomba's position is unchanged on screen shift
                  Goomba_X_Pos_in = Goomba_X_Pos - 10'd40 + Goomba_X_Motion;
               end
               else begin
                  Goomba_X_Pos_in = Goomba_X_Pos + Goomba_X_Motion;
               end
               Goomba_Y_Pos_in = Goomba_Y_Pos + Goomba_Y_Motion;
            end
         end
         else begin // If Goomba isn't alive, do nothing
            Goomba_X_Pos_in = 10'd0;
            Goomba_Y_Pos_in = 10'd0;
            Goomba_X_Motion_in = 10'd0;
            Goomba_Y_Motion_in = 10'd0;
            Falling_in = 1'b0;
            isAlive_in = 1'b0;
         end
      end
   end
   
   // Check if current pixel is Goomba to draw
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
endmodule