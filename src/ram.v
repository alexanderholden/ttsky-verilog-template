module mem(
    input  wire [3:0] mar_addr,     // 4-bit address input
    input  wire       CE,           // active-high chip enable
    output wire [7:0] ram_bus_out   // 8-bit data output
);

    // Define the RAM
    reg [7:0] ram [0:15];

    initial begin
        ram[0]  = 8'b00001001; // LDA @9h
        ram[1]  = 8'b11101111; // OUT
        ram[2]  = 8'b00011010; // ADD @Ah
        ram[3]  = 8'b11101111; // OUT
        ram[4]  = 8'b00101011; // SUB @Bh
        ram[5]  = 8'b11101111; // OUT
        ram[6]  = 8'b11111111; // HLT
        ram[7]  = 8'b00000000;
        ram[8]  = 8'b00000000;
        ram[9]  = 8'b00000110; // 6
        ram[10] = 8'b00001000; // 8
        ram[11] = 8'b00000011; // 3
        ram[12] = 8'b00000000;
        ram[13] = 8'b11111111;
        ram[14] = 8'b11111111;
        ram[15] = 8'b11111111;
    end

    // Output data with tri-state when CE is low
    assign ram_bus_out = (CE) ? ram[mar_addr] : 8'bz;

endmodule