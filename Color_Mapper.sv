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
module  color_mapper (  input logic Clk,
                        input              is_mario, draw_is_goomba,           // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       
                        input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                        input logic [9:0] MarioXTL, MarioYTL, GoombaXTL, GoombaYTL, // Gets the top left X and Y coords of Mario & Goomba
                        input logic [2:0] blockID,
                       
                        output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
   logic [7:0] Red, Green, Blue;
   logic [3:0] pixelPaletteID;
   
   parameter SSWidth = 16'd200;
   parameter SSHeight = 16'd200;
   parameter SpriteLength = 16'd40;
   
   logic [9:0] PixelX, PixelY;
   logic [2:0] SSXPos, SSYPos; // SpriteSheet X and Y pos of the block to be drawn
   logic [15:0] pixelAddress;
   
   // Output colors to VGA
   assign VGA_R = Red;
   assign VGA_G = Green;
   assign VGA_B = Blue;
    
   // Assign color based on is_mario signal
   always_comb begin
      if (DrawX < 10'd120 || DrawX >= 10'd520 || DrawY < 10'd40) begin
         SSXPos = 3'h0;
         SSYPos = 3'h4;
      end
      else if (DrawY >= 10'd440) begin
         SSXPos = 3'h2;
         SSYPos = 3'h3;
      end
      else if (is_mario == 1'b1) begin
         SSXPos = 3'h1;
         SSYPos = 3'h0;
      end
      else if (draw_is_goomba == 1'b1) begin
         SSXPos = 3'h3;
         SSYPos = 3'h2;
      end
      /*
      else if (DrawX % 40 == 0 || DrawY % 40 == 0) begin
         Red = 8'hff;
         Green = 8'h80;
         Blue = 8'h00;
      end
      */
      else begin
         case (blockID) // Color cases and stuffs
            3'b000 : begin // Open air, use default background
               SSXPos = 3'h4;
               SSYPos = 3'h4;
            end
            3'b001 : begin // Floor bricks
               SSXPos = 3'h2;
               SSYPos = 3'h3;
            end
            3'b010 : begin // Breakable bricks
               SSXPos = 3'h0;
               SSYPos = 3'h2;
            end
            3'b011 : begin // Question blocks
               SSXPos = 3'h1;
               SSYPos = 3'h3;
            end
            3'b100 : begin // Pipe opening left
               SSXPos = 3'h1;
               SSYPos = 3'h2;
            end
            3'b101 : begin // Pipe opening right
               SSXPos = 3'h2;
               SSYPos = 3'h2;
            end
            3'b110 : begin // Pipe tubing left
               SSXPos = 3'h3;
               SSYPos = 3'h3;
            end
            3'b111 : begin // Pipe tubing right
               SSXPos = 3'h4;
               SSYPos = 3'h3;
            end
            default : begin // Should never occur; but use background
               SSXPos = 3'h4;
               SSYPos = 3'h4;
            end
         endcase
      end
      /*
      if (DrawX > 10'd120) begin
         PixelX = DrawX - 10'd120;
      end
      else begin
         PixelX = DrawX;
      end
      if (DrawY > 10'd40) begin
         PixelY = DrawY - 10'd40;
      end
      else begin
         PixelY = DrawY;
      end
      */
      PixelX = DrawX;
      PixelY = DrawY;
      
      pixelAddress = (SSWidth * SpriteLength * SSYPos) + (SpriteLength * SSXPos) + (PixelX % SpriteLength) + ((PixelY % SpriteLength) * SSWidth);
   end
   
   always_ff @ (posedge Clk) begin
      case (pixelPaletteID)
         4'h0 : begin
            Red   = 8'h0A;
            Green = 8'hB1;
            Blue  = 8'hFF;
         end
         4'h1 : begin
            Red   = 8'hFF;
            Green = 8'h31;
            Blue  = 8'h18;
         end
         4'h2 : begin
            Red   = 8'hFF;
            Green = 8'hC6;
            Blue  = 8'hB5;
         end
         4'h3 : begin
            Red   = 8'h9C;
            Green = 8'h4A;
            Blue  = 8'h00;
         end
         4'h4 : begin
            Red   = 8'hE7;
            Green = 8'h5A;
            Blue  = 8'h10;
         end
         4'h5 : begin
            Red   = 8'hC6;
            Green = 8'h63;
            Blue  = 8'h00;
         end
         4'h6 : begin
            Red   = 8'hD6;
            Green = 8'h5A;
            Blue  = 8'h00;
         end
         4'h7 : begin
            Red   = 8'hF7;
            Green = 8'hD6;
            Blue  = 8'hB5;
         end
         4'h8 : begin
            Red   = 8'hFF;
            Green = 8'h94;
            Blue  = 8'h5A;
         end
         4'h9 : begin
            Red   = 8'hE6;
            Green = 8'h9C;
            Blue  = 8'h21;
         end
         4'hA : begin
            Red   = 8'hBD;
            Green = 8'hFF;
            Blue  = 8'h18;
         end
         4'hB : begin
            Red   = 8'h00;
            Green = 8'hAD;
            Blue  = 8'h00;
         end
         4'hC : begin
            Red   = 8'h00;
            Green = 8'h00;
            Blue  = 8'h00;
         end
         4'hD : begin
            Red   = 8'hFF;
            Green = 8'h00;
            Blue  = 8'hFF;
         end
         4'hE : begin
            Red   = 8'hFF;
            Green = 8'h00;
            Blue  = 8'hFF;
         end
         4'hF : begin
            Red   = 8'hFF;
            Green = 8'h00;
            Blue  = 8'hFF;
         end
         default : begin
            Red   = 8'h0A;
            Green = 8'hB1;
            Blue  = 8'hFF;
         end
      endcase
   end
   /*
   always_comb begin
      if (DrawX < 120 || DrawX >= 520 || DrawY < 40 || DrawY >= 440) begin
         Red = 8'h00;
         Green = 8'h00;
         Blue = 8'h00;
      end
      else if (is_mario == 1'b1) begin
         // White Brick Mario
         Red = 8'hff;
         Green = 8'hff;
         Blue = 8'hff;
      end
      else if (draw_is_goomba == 1'b1) begin
         Red   = 8'h03;
         Green = 8'hfc;
         Blue  = 8'hec;
      end
      else if (DrawX % 40 == 0 || DrawY % 40 == 0) begin
         Red = 8'hff;
         Green = 8'h80;
         Blue = 8'h00;
      end
      else begin
         case (blockID) // Color cases and stuffs
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
   */
   
   frameRAM spriteSheet(.Clk, .read_address(pixelAddress), .data_Out(pixelPaletteID),
                        .write_address(16'h0000), .we(1'b0));
    
endmodule


