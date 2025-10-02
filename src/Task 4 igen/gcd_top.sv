module gcd_top (
    input  logic        clk,
    input  logic        reset,
    input  logic        req,
    input  logic [15:0] AB,
    output logic        ack,
    output logic [15:0] C
);

    logic        ABorALU, LDA, LDB;
    logic [1:0]  FN;
    logic [15:0] reg_a_out, reg_b_out, C_init, Y;
    logic        Z, N;

    gcd_dp datapath (
        .clk(clk),
        .ABorALU(ABorALU),
        .LDA(LDA),
        .LDB(LDB),
        .AB(AB),
        .FN(FN),
        .reg_a_out(reg_a_out),
        .reg_b_out(reg_b_out),
        .C_init(C_init),
        .Y(Y),
        .Z(Z),
        .N(N)
    );

    gcd_fsm controller (
        .clk(clk),
        .reset(reset),
        .req(req),
        .Z(Z),
        .N(N),
        .ack(ack),
        .ABorALU(ABorALU),
        .LDA(LDA),
        .LDB(LDB),
        .FN(FN)
    );
    
    assign C = reg_a_out;
   

endmodule
