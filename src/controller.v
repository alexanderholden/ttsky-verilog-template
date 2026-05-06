module Controller(
    input  wire        clk,
    input  wire        clr,
    input  wire [3:0]  inst_in,
    output reg         Cp,
    output reg         Ep,
    output reg         Lm,
    output reg         CE,
    output reg         Li,
    output reg         Ei,
    output reg         La,
    output reg         Ea,
    output reg         Su,
    output reg         Eu,
    output reg         Lb,
    output reg         Lo,
    output reg         HLT
);

    // FSM states
    typedef enum logic [2:0] {idle, t0, t1, t2, t3, t4, t5} state_t;
    state_t pr_state = t0, nx_state;

    reg [11:0] control_signal = 12'b0;
    reg HLT_sig = 1'b1;

    // State register
    always @(posedge clk or negedge clr) begin
        if (!clr)
            pr_state <= idle;
        else
            pr_state <= nx_state;
    end

    // Next state and control logic
    always @(*) begin
        control_signal = 12'b0;
        HLT_sig = 1'b1;
        nx_state = pr_state;

        case (pr_state)
            idle: begin
                control_signal = 12'b000000000000;
                HLT_sig = 1'b1;
                nx_state = t0;
            end
            t0: begin
                control_signal = 12'b011000000000; // Ep=1, Lm=1
                nx_state = t1;
            end
            t1: begin
                control_signal = 12'b100000000000; // Cp=1
                nx_state = t2;
            end
            t2: begin
                control_signal = 12'b000110000000; // CE=1, Li=1
                nx_state = t3;
            end
            t3: begin
                if (inst_in == 4'b1110) begin
                    control_signal = 12'b000000010001; // OUT instruction
                end else if (inst_in == 4'b1111) begin
                    control_signal = 12'b000000000000; // HLT instruction
                    HLT_sig = 1'b0;
                end else begin
                    control_signal = 12'b001001000000;
                end
                nx_state = t4;
            end
            t4: begin
                if (inst_in == 4'b0000) begin      // LDA
                    control_signal = 12'b000100100000;
                end else if (inst_in == 4'b0001) begin // ADD
                    control_signal = 12'b000100000010;
                end else if (inst_in == 4'b0010) begin // SUB
                    control_signal = 12'b000100000010;
                end else begin
                    control_signal = 12'b000000000000;
                end
                nx_state = t5;
            end
            t5: begin
                if (inst_in == 4'b0001) begin      // ADD
                    control_signal = 12'b000000100100; // Su=0
                end else if (inst_in == 4'b0010) begin // SUB
                    control_signal = 12'b000000101100; // Su=1
                end else begin
                    control_signal = 12'b000000000000;
                end
                nx_state = t0;
            end
        endcase
    end

    // Assign control signals to outputs
    always @(*) begin
        Cp  = control_signal[11];
        Ep  = control_signal[10];
        Lm  = control_signal[9];
        CE  = control_signal[8];
        Li  = control_signal[7];
        Ei  = control_signal[6];
        La  = control_signal[5];
        Ea  = control_signal[4];
        Su  = control_signal[3];
        Eu  = control_signal[2];
        Lb  = control_signal[1];
        Lo  = control_signal[0];
        HLT = HLT_sig;
    end

endmodule