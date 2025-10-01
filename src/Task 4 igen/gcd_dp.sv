module gcd_dp (
    input  logic        clk,
    input  logic        ABorALU,      
    input  logic        LDA,          
    input  logic        LDB,          
    input  logic [15:0] AB,           
    input  logic [1:0]  FN,           
    output logic [15:0] reg_a_out,    
    output logic [15:0] reg_b_out,    
    output logic [15:0] C_init,       
    output logic [15:0] Y,            
    output logic        Z,            
    output logic        N             
);

    logic [15:0] mux_out;
    logic [15:0] alu_res;

    c_mux #(.N(16)) mux_inst (
        .data_in1(AB),
        .data_in2(alu_res),
        .s(ABorALU),
        .data_out(mux_out)
    );

    c_reg #(.N(16)) reg_a_inst (
        .clk(clk),
        .en(LDA),
        .data_in(mux_out),
        .data_out(reg_a_out)
    );

    c_reg #(.N(16)) reg_b_inst (
        .clk(clk),
        .en(LDB),
        .data_in(mux_out),
        .data_out(reg_b_out)
    );

    c_alu #(.W(16)) alu_inst (
        .A(reg_a_out),
        .B(reg_b_out),
        .fn(FN),
        .C(alu_res),
        .Z(Z),
        .N(N)
    );

    assign C_init = mux_out;
    assign Y      = alu_res;

endmodule
