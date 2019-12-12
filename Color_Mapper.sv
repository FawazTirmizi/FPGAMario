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
                        input logic is_mario,
                        input logic [1:0] run_counter,
                        input logic is_jumping, direction,
                        input logic draw_is_goomba, goomba_sprite,           // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       
                        input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                        input logic [9:0] Mario_X_Pos, Mario_Y_Pos, Goomba_X_Pos, Goomba_Y_Pos, // Gets the X and Y coords of Mario & Goomba
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
      PixelX = DrawX - 10'd120;
      PixelY = DrawY - 10'd40;
      
      if (DrawX < 10'd120 || DrawX >= 10'd520 || DrawY < 10'd40) begin
         SSXPos = 3'h0;
         SSYPos = 3'h4;
      end
      else if (DrawY >= 10'd440) begin
         SSXPos = 3'h2;
         SSYPos = 3'h3;
      end
      else if (is_mario == 1'b1) begin
         if (is_jumping) begin
            SSXPos = 3'h2 + direction;
            SSYPos = 3'h0;
         end
         else begin
            if (direction == 1'b0) begin // If Mario is facing right
               SSXPos = 3'h1 + run_counter;
               if (run_counter != 2'b00) begin
                  SSYPos = 3'h1;
               end
               else begin
                  SSYPos = 3'h0;
               end
            end
            else begin // If mario is facing left
               case (run_counter)
                  2'b00 : begin
                     SSXPos = 3'h0;
                     SSYPos = 3'h0;
                  end
                  2'b01 : begin
                     SSXPos = 3'h4;
                     SSYPos = 3'h0;
                  end
                  2'b10 : begin
                     SSXPos = 3'h0;
                     SSYPos = 3'h1;
                  end
                  2'b11 : begin
                     SSXPos = 3'h1;
                     SSYPos = 3'h1;
                  end
               endcase
            end
         end
         
         PixelX = DrawX - 10'd120 - Mario_X_Pos - 10'd4;
         PixelY = DrawY - 10'd40 - Mario_Y_Pos - 10'd4;
      end
      else if (draw_is_goomba == 1'b1) begin
         SSXPos = 3'h3 + goomba_sprite;
         SSYPos = 3'h2;
         
         PixelX = DrawX - 10'd120 - Goomba_X_Pos - 10'd4;
         PixelY = DrawY - 10'd40 - Goomba_Y_Pos - 10'd4;
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
      
      pixelAddress = (SSWidth * SpriteLength * SSYPos) + (SpriteLength * SSXPos) + (PixelX % SpriteLength) + ((PixelY % SpriteLength) * SSWidth);
   end
   
   // Every clock cycle, get the right color for the palette
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
   
   frameRAM spriteSheet(.Clk, .read_address(pixelAddress), .data_Out(pixelPaletteID),
                        .write_address(16'h0000), .we(1'b0));
    
endmodule


