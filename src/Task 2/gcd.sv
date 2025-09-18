// -----------------------------------------------------------------------------
//
//  Title      :  System Verilog FSMD implementation template for GCD
//             :
//  Developers :  Otto Westy Rasmussen
//             :
//  Purpose    :  This is a template for the FSMD (finite state machine with datapath)
//             :  implementation of the GCD circuit
//             :
//  Revision   :  02203 fall 2025 v.1.0
//
// -----------------------------------------------------------------------------


module gcd (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [1 : 0] { idleA, sampleA, ackA, idleB, sampleB, compare
cavvvv    , calc, ackResult } state_t; // Input your own state names here

    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b, compareReg;

    state_t current_state, next_state;

    // Combinatorial logic
    always_comb begin

        next_state = current_state;
        next_reg_a = '0;
        next_reg_b = '0;

        case (state)

            idleA:
                begin
                    if(req) next_state = sampleA;
                end
            sampleA:
                begin
                    if(!req) next_state = ackA;
                    next_reg_a = AB;
                end
            ackA:
                begin
                    next_state = idleB;
                    ack = '1;
                end
            idleB:
                begin
                    if(req) next_state = sampleB;
                    ack = '0;
                end
            sampleB:
                begin
                    next_state = compare;
                    next_reg_b = AB;
                end
            compare:
                begin

                    compareReg = a - b;


                    //If dif is 0 then skip to ackResult
                end
            calc:
                begin
                    if(n) begin
                        a = a-b;
                    end else begin
                        b = b-a;


                    /*
                    if(a !== b) begin
                        if(a > b) a = a-b;
                        else b = b-a;
                        next_state = calc;
                    end else begin
                        next_state = ackResult;
                    end
                    */
                end
            ackResult:
                begin
                    ack = '1;
                    C = a;
                    next_state = idleA;
                end
        endcase
    end

    // Register
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            current_state <= idleA;
            reg_a <= '0;
            reg_b <= '0;

        end else begin

            current_state <= next_state;
            if(state == sampleA) reg_a <= next_reg_a;
            if(state == sampleB) reg_b <= next_reg_b;

        end

    end

endmodule