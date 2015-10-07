//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
// Notes    : The cited Xilinx article is no longer available
//            on the Xilinx website.  However, the article
//            "Asynchronous FIFO Design with Gray code Pointer
//            for High Speed AMBA AHB Compliant Memory"
//            contains a good description of the circuit.
//=========================================

`timescale 1ns / 1ps

module async_fifo
    #(parameter DATA_WIDTH    = 32,
                ADDRESS_WIDTH = 3,
                FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output wire [DATA_WIDTH-1:0]        Data_out, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,       
     
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    // Internal connections & variables
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Direction_Set, Direction_Reset;
    reg                                 Fifo_Direction;
    wire                                PresetFull, PresetEmpty;
    
    // Code
    // Data ports logic:
    // (Uses a dual-port RAM).
    // 'Data_out' logic:
    // Memory out is set asynchronously.
    assign  Data_out = Mem[pNextWordToRead];
            
    // 'Data_in' logic:
    // Memory out is set on the rising clock edge.
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;

    // Fifo addresses support logic.
    // 'Next Addresses' enable logic.
    // These flags enable the gray code counters.
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    // Addresses (Gray counters) logic.
    // Clear_in is active high.
    // Gray counter write address.
    GrayCounter #(
		.COUNTER_WIDTH( ADDRESS_WIDTH )
    ) GrayCounter_pWr (
        .GrayCount_out(pNextWordToWrite),
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        .Clk(WClk)
    );
       
    // Gray counter read address.
    GrayCounter #(
		.COUNTER_WIDTH( ADDRESS_WIDTH )
    ) GrayCounter_pRd (
        .GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
    );
     
    // 'EqualAddresses' logic.
    // Set when the two gray code addresses are the same.
    // Asynchronous logic.
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    // 'Quadrant selectors' logic.
    // Asynchronous logic.
    assign Direction_Set = 
        (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
        (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Direction_Reset = 
        (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
        (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    // 'Fifo_Direction' latch logic.
    // D Latch w/ Asynchronous Clear & Preset.
    // Asynchronous logic.
    always @ (Direction_Set, Direction_Reset, Clear_in) 
        if (Direction_Reset | Clear_in)
            Fifo_Direction = 0;  // FIFO going Empty
        else if (Direction_Set)
            Fifo_Direction = 1;  // FIFO going Full
            
    // 'Full_out' logic for the writing port.
    // D Flip-Flop w/ Asynchronous Preset.
    // If the FIFO direction is going full and the next addresses are equal
    // the next write will make the FIFO full.
    // The Preset is asynchronous.
    assign PresetFull = Fifo_Direction & EqualAddresses;
    always @ (posedge WClk, posedge PresetFull) 
        if (PresetFull)
            Full_out <= 1;
        else
            Full_out <= 0;
            
    // 'Empty_out' logic for the reading port.
    // D Flip-Flop w/ Asynchronous Preset.    
    // If the FIFO direction is going empty and the next addresses are equal
    // the next read will make the FIFO empty.
    // The Preset is asynchronous.
    assign PresetEmpty = ~Fifo_Direction & EqualAddresses;
    always @ (posedge RClk, posedge PresetEmpty) 
        if (PresetEmpty)
            Empty_out <= 1;
        else
            Empty_out <= 0;
            
endmodule