//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( 
					input                Clk,                // 50 MHz clock
                                    Reset,              // Active-high reset signal
                                    frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]          DrawX, DrawY,       // Current pixel coordinates
					input [15:0]         keycode,
               input [2:0]          ball_poll_block_id,
               
               output logic [9:0]   ball_X_poll, ball_Y_poll,
               output logic         is_ball             // Whether current pixel belongs to ball or background
);
    
   parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
   parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
   parameter [9:0] Ball_X_Min = 10'd120;     // Leftmost point on the X axis
   parameter [9:0] Ball_X_Max = 10'd519;     // Rightmost point on the X axis
   parameter [9:0] Ball_Y_Min = 10'd40;      // Topmost point on the Y axis
   parameter [9:0] Ball_Y_Max = 10'd439;     // Bottommost point on the Y axis
   parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
   parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
   parameter [9:0] Ball_Size = 10'd4;        // Ball size
    
   logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
   logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
   
	logic [5:0] Jump_Counter, Jump_Counter_in;
	logic			Falling, Falling_in;
	
   //////// Do not modify the always_ff blocks. ////////
   // Detect rising edge of frame_clk
   logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
      frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
   // Update registers
   always_ff @ (posedge Clk) begin
      if (Reset) begin
         Ball_X_Pos <= (Ball_X_Min + 10'd20);
         Ball_Y_Pos <= Ball_Y_Max - Ball_Size;
         Ball_X_Motion <= 10'd0;
         Ball_Y_Motion <= 10'd0;
			Falling <= 1'b0;
			Jump_Counter <= 1'b0;
      end
      else begin
         Ball_X_Pos <= Ball_X_Pos_in;
         Ball_Y_Pos <= Ball_Y_Pos_in;
         Ball_X_Motion <= Ball_X_Motion_in;
         Ball_Y_Motion <= Ball_Y_Motion_in;
			Falling <= Falling_in;
			Jump_Counter <= Jump_Counter_in;
			
      end
   end
   //////// Do not modify the always_ff blocks. ////////
    
   // You need to modify always_comb block.
   always_comb begin
      // By default, keep motion and position unchanged
      Ball_X_Pos_in = Ball_X_Pos;
      Ball_Y_Pos_in = Ball_Y_Pos;
      Ball_X_Motion_in = Ball_X_Motion;
      Ball_Y_Motion_in = Ball_Y_Motion;
		Jump_Counter_in = Jump_Counter;
		Falling_in = Falling;
      ball_X_poll = Ball_X_Pos;
      ball_Y_poll = Ball_Y_Pos;
      
      // Update position and motion only at rising edge of frame clock
      if (frame_clk_rising_edge) begin
         // Be careful when using comparators with "logic" datatype because compiler treats 
         //   both sides of the operator as UNSIGNED numbers.
         // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
         // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
			
			if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max ) begin // Ball is at the bottom edge
            Ball_Y_Motion_in = 1'b0;
				Falling_in = 1'b0;
			end
			
			if (Ball_X_Pos + Ball_Size >= Ball_X_Max ) begin // Ball is at right edge
				Ball_X_Motion_in = 1'b0;
			end
			else if (Ball_X_Pos <= Ball_X_Min + Ball_Size ) begin // Ball is at left edge
				Ball_X_Motion_in = 1'b0;
			end
			
			if((keycode !=16'h001A) && (Ball_Y_Pos + Ball_Size >= Ball_Y_Max )) begin // Ball is at the bottom edge
            Ball_Y_Motion_in = 1'b0;
				Falling_in = 1'b0;
				Jump_Counter_in = 1'b0;
			end
			else begin
				if (Jump_Counter == 6'b111111) begin
					Ball_Y_Motion_in = Ball_Y_Step;
					Falling_in = 1'b1;
				end
				else if (Falling && Jump_Counter > 1'b0) begin
					Jump_Counter_in = Jump_Counter - 1'b1;
					Ball_Y_Motion_in = Ball_Y_Step;
				end
				else if (!Falling && Jump_Counter > 1'b0) begin
					Jump_Counter_in = Jump_Counter + 1'b1;
					Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				end
			end
			
			case (keycode)
				16'h0004: begin // A
					Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
               ball_X_poll = Ball_X_Pos - Ball_Size - 1'b1;
				end
				16'h0007: begin // D
					Ball_X_Motion_in = Ball_X_Step;
               ball_X_poll = Ball_X_Pos + Ball_Size + 1'b1;
				end
				16'h0016: begin // S
				end
				16'h001A: begin // W
					if (Jump_Counter == 1'b0) begin
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
						Jump_Counter_in = 5'b00001;
                  ball_Y_poll = Ball_Y_Pos - Ball_Size - 1'b1;
					end
				end
				default : begin
					Ball_X_Motion_in = 16'h0000;
				end
			endcase
			
         // Update the ball's position with its motion
         if (ball_poll_block_id == 3'b000) begin
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
         end
      end
   end
   
   // Compute whether the pixel corresponds to ball or background
   /* Since the multiplicants are required to be signed, we have to first cast them
      from logic to int (signed by default) before they are multiplied. */
   int DistX, DistY, Size;
   assign DistX = DrawX - Ball_X_Pos;
   assign DistY = DrawY - Ball_Y_Pos;
   assign Size = Ball_Size;
   always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
   end
endmodule
