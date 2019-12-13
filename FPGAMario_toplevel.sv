module FPGAMario_toplevel (
				input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
   logic Reset_h, Clk;
   logic [7:0] keycode;
   
   logic [9:0] DrawX, DrawY;

   logic Shift;
	
   logic frame_clk;
	
   
   logic [9:0] Mario_X_Pos, Mario_Y_Pos;
   logic [2:0] mario_poll_up, mario_poll_down, mario_poll_left, mario_poll_right;
   logic [1:0] run_counter;
   logic       is_jumping, direction;
   logic       is_mario;
   
   logic [9:0] Goomba_X_Pos, Goomba_Y_Pos;
   logic       draw_is_goomba, goomba_sprite;
   logic       Goomba_isAlive, goomba_killed;
   logic [2:0] Goomba_poll_left, Goomba_poll_right;
   logic [9:0] spawnX, spawnY;


   logic [2:0] blockID;
    
   logic [7:0] current_block_col; // Address of what column we're getting from memory
   
   logic [29:0] new_block_id; // Incoming block column
   logic [5:0] new_col_control; // Control bits accompanying incoming block column
      
   logic kill_Mario;
   
   // Scoring control
   logic [3:0] coin_taken, is_coin;
   logic [7:0] score;
	always_ff @ (posedge Clk) begin
      score = score + coin_taken[0] + coin_taken[1] + coin_taken[2] + coin_taken[3] + 2 * goomba_killed;
   end
   
   
   // Coin control
   logic [3:0] start_coin;
   always_ff @ (posedge Clk) begin
      if (new_col_control[5] == 1'b1) begin
         case (new_col_control[4:3])
            2'b00 : start_coin <= 4'b0001;
            2'b01 : start_coin <= 4'b0010;
            2'b10 : start_coin <= 4'b0100;
            2'b11 : start_coin <= 4'b1000;
         endcase
      end
      else begin
         start_coin <= 4'h0;
      end
   end
   
   assign Clk = CLOCK_50;
   always_ff @ (posedge Clk) begin
      Reset_h <= ~(KEY[0]) || kill_Mario;        // The push buttons are active low
   end
   
   always_comb begin
		if ((DrawX == 0) && (DrawY == 0))
			frame_clk = 1'b1;
		else
			frame_clk = 1'b0;
	 end
	 
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
   // Use PLL to generate the 25MHZ VGA_CLK.
   // You will have to generate it on your own in simulation.
   vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
   // TODO: Fill in the connections for the rest of the modules 
   VGA_controller vga_controller_instance(.Clk, .Reset(Reset_h), .VGA_CLK, .VGA_HS, .VGA_VS, .VGA_BLANK_N, .VGA_SYNC_N, .DrawX, .DrawY);
    
   // Which signal should be frame_clk?   
   Mario mario_instance(.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY, 
                     .keycode({2'h00, keycode}), .is_mario, .Shift,
                     .Mario_X_Pos, .Mario_Y_Pos, .run_counter, .is_jumping, .direction,
                     .mario_poll_up, .mario_poll_down, .mario_poll_left, .mario_poll_right);
    
   color_mapper color_instance(.Clk, .is_mario, .draw_is_goomba, .DrawX, .DrawY,
                              .VGA_R, .VGA_G, .VGA_B, .blockID, .Mario_X_Pos, .Mario_Y_Pos,
                              .Goomba_X_Pos, .Goomba_Y_Pos, .goomba_sprite,
                               .run_counter, .is_jumping, .direction,
                               .is_coin);
   
   goomba goomba_instance(.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY, 
                           .start(new_col_control[0]), .Shift,
                           .spawnX(10'd500), .spawnY(10'd440), .Mario_X_Pos, .Mario_Y_Pos, 
                           .Goomba_poll_left, .Goomba_poll_right, .isAlive_out(Goomba_isAlive),
                           .Goomba_X_Pos, .Goomba_Y_Pos, .draw_is_goomba, .kill_Mario,
                           .goomba_sprite, .goomba_killed);
   
   block_array block_instance(.Clk, .Reset(Reset_h), .drawX(DrawX), .drawY(DrawY), .block_id_out(blockID), 
                              .new_block_id, .Mario_X_Pos, .Mario_Y_Pos, .Shift,
                              .mario_poll_up, .mario_poll_down, .mario_poll_left, .mario_poll_right,
                              .Goomba_X_Pos, .Goomba_Y_Pos, .Goomba_poll_left, .Goomba_poll_right,
                              .current_block_col);
   
   LevelMemory level_memory(.clock(Clk), .address(current_block_col), .q({new_col_control, new_block_id}));
   
   coin coin_instance_0 (.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY,
                           .start(start_coin[0]), .Shift, .Mario_X_Pos, .Mario_Y_Pos,
                           .start_block(new_col_control[3:2]), .coin_taken(coin_taken[0]), 
                           .is_coin(is_coin[0]));
                           
   coin coin_instance_1 (.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY,
                           .start(start_coin[1]), .Shift, .Mario_X_Pos, .Mario_Y_Pos,
                           .start_block(new_col_control[3:2]), .coin_taken(coin_taken[1]), 
                           .is_coin(is_coin[1]));
   
   coin coin_instance_2 (.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY,
                           .start(start_coin[2]), .Shift, .Mario_X_Pos, .Mario_Y_Pos,
                           .start_block(new_col_control[3:2]), .coin_taken(coin_taken[2]), 
                           .is_coin(is_coin[2]));
   
   coin coin_instance_3 (.Clk, .Reset(Reset_h), .frame_clk, .DrawX, .DrawY,
                           .start(start_coin[3]), .Shift, .Mario_X_Pos, .Mario_Y_Pos,
                           .start_block(new_col_control[3:2]), .coin_taken(coin_taken[3]), 
                           .is_coin(is_coin[3]));
   
   // Display the bottom 4 control bits of the current column
   //HexDriver hex_inst_3 (new_col_control[3:0], HEX3);
   
   // Display the score
   HexDriver hex_inst_0 (score[3:0], HEX0);
   HexDriver hex_inst_1 (score[7:4], HEX1);
   
   // Display the status of the Goomba
   HexDriver hex_inst_3 (Goomba_isAlive, HEX3);
   
   // Display the next block column to be loaded in
   HexDriver hex_inst_4 (current_block_col[3:0], HEX4);
   HexDriver hex_inst_5 (current_block_col[7:4], HEX5);
   
   // Display keycode on hex display
   HexDriver hex_inst_6 (keycode[3:0], HEX6);
   HexDriver hex_inst_7 (keycode[7:4], HEX7);
    
endmodule