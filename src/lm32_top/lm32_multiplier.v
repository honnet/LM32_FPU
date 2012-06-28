// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2006 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                         FILE DETAILS
// Project          : LatticeMico32
// File             : lm32_multiplier.v
// Title            : Pipelined multiplier.
// Dependencies     : lm32_include.v
// Version          : 6.1.17
//                  : Initial Release
// Version          : 7.0SP2, 3.0
//                  : No Change
// Version          : 3.1
//                  : No Change
// =============================================================================
                  
`include "lm32_include.v"

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////

module lm32_multiplier (
    // ----- Inputs -----
    clk_i,
    rst_i,
    stall_x,
    stall_m,
    operand_0,
    operand_1,
    // ----- Ouputs -----
    result
    );

/////////////////////////////////////////////////////
// Inputs
/////////////////////////////////////////////////////

input clk_i;                            // Clock 
input rst_i;                            // Reset
input stall_x;                          // Stall instruction in X stage
input stall_m;                          // Stall instruction in M stage
input [`LM32_WORD_RNG] operand_0;     	// Muliplicand
input [`LM32_WORD_RNG] operand_1;     	// Multiplier

/////////////////////////////////////////////////////
// Outputs
/////////////////////////////////////////////////////

output [`LM32_WORD_RNG] result;       	// Product of multiplication
reg    [`LM32_WORD_RNG] result;

/////////////////////////////////////////////////////
// Internal nets and registers 
/////////////////////////////////////////////////////

reg [`LM32_WORD_RNG] muliplicand; 
reg [`LM32_WORD_RNG] multiplier; 
reg [`LM32_WORD_RNG] productLL; 
reg [`LM32_WORD_RNG] productLH; 
reg [`LM32_WORD_RNG] productHL; 

/////////////////////////////////////////////////////
// Sequential logic
/////////////////////////////////////////////////////

always @(posedge clk_i `CFG_RESET_SENSITIVITY)
begin
    if (rst_i == `TRUE)
    begin
        muliplicand <= {`LM32_WORD_WIDTH{1'b0}};
        multiplier <= {`LM32_WORD_WIDTH{1'b0}};
    end
    else if (stall_x == `FALSE)
    begin    
       muliplicand <= operand_0;
       multiplier <= operand_1;
    end
end

always @(posedge clk_i `CFG_RESET_SENSITIVITY)
begin
    if (rst_i == `TRUE)
    begin
        productLL <= {`LM32_WORD_WIDTH{1'b0}};
        productLH <= {`LM32_WORD_WIDTH{1'b0}};
        productHL <= {`LM32_WORD_WIDTH{1'b0}};
    end
    else
    begin
        if (stall_m == `FALSE)
         begin
            productLL <= muliplicand[15:0] * multiplier[15:0];
            productLH <= (muliplicand[15:0] * multiplier[31:16])<<16;
            productHL <= (muliplicand[31:16] * multiplier[15:0])<<16;
         end
    end
end

always @(posedge clk_i `CFG_RESET_SENSITIVITY)
begin
    if (rst_i == `TRUE)
    begin
        result <= {`LM32_WORD_WIDTH{1'b0}};
    end
    else
    begin
        result <= productLL + productLH + productHL;
    end
end

endmodule
