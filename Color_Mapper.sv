//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       input logic [2:0] blockID,
                       
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
   logic [7:0] Red, Green, Blue;
    
   // Output colors to VGA
   assign VGA_R = Red;
   assign VGA_G = Green;
   assign VGA_B = Blue;
    
   // Assign color based on is_ball signal
   always_comb begin
      if (DrawX < 120 || DrawX >= 520 || DrawY < 40 || DrawY >= 440) begin
         Red = 8'h00;
         Green = 8'h00;
         Blue = 8'h00;
      end
      else if (is_ball == 1'b1) begin
         // White ball
         Red = 8'hff;
         Green = 8'hff;
         Blue = 8'hff;
      end
      else if (DrawX % 40 == 0 || DrawY % 40 == 0) begin
         Red = 8'hff;
         Green = 8'h80;
         Blue = 8'h00;
      end
      else begin
         case (blockID)
            3'b000 : begin // Open air, use default background
               Red = 8'h3f; 
               Green = 8'h00;
               Blue = 8'h7f - {1'b0, DrawX[9:3]};
            end
            3'b001 : begin // Floor bricks
               Red = 8'h5e;
               Green = 8'h3c;
               Blue = 8'h21;
            end
            3'b010 : begin // Breakable bricks
               Red = 8'h9e;
               Green = 8'h4d;
               Blue = 8'h0e;
            end
            3'b011 : begin // Question blocks
               Red = 8'hff;
               Green = 8'hb7;
               Blue = 8'h00;
            end
            3'b100 : begin // Pipe opening left
               Red = 8'h22;
               Green = 8'hff;
               Blue = 8'h00;
            end
            3'b101 : begin // Pipe opening right
               Red = 8'h10;
               Green = 8'h75;
               Blue = 8'h00;
            end
            3'b110 : begin // Pipe tubing left
               Red = 8'h22;
               Green = 8'h57;
               Blue = 8'h1a;
            end
            3'b111 : begin // Pipe tubing right
               Red = 8'h75;
               Green = 8'ha6;
               Blue = 8'h6d;
            end
            default : begin // Should never occur; but use background
               Red = 8'h3f; 
               Green = 8'h00;
               Blue = 8'h7f - {1'b0, DrawX[9:3]};
            end
         endcase
      end
   end 
    
endmodule
