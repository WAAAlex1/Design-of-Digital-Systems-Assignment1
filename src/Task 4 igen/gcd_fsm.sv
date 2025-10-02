module gcd_fsm (
    input  logic        clk,
    input  logic        reset,
    input  logic        req,
    input  logic        Z,        
    input  logic        N,       
    output logic        ack,
    output logic        ABorALU,
    output logic        LDA,
    output logic        LDB,
    output logic [1:0]  FN
);

    typedef enum logic [3:0] {
        idle_a, sample_a, ack_a, idle_b, sample_b,
        compare, sub_a, sub_b, done
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= idle_a;
        else state <= next_state;
    end

    always_comb begin
        // defaults
        ack        = 0;
        ABorALU    = 1;   
        LDA        = 0;
        LDB        = 0;
        FN         = 2'b10; 
        next_state = state;

        case (state)
            idle_a: begin
                if (req) next_state = sample_a;
            end

            sample_a: begin
                LDA     = 1; 
                ABorALU = 1;
                next_state = ack_a;
            end

            ack_a: begin
                ack = 1;
                if (!req) next_state = idle_b;
            end

            idle_b: begin
                if (req) next_state = sample_b;
            end

            sample_b: begin
                LDB     = 1; 
                ABorALU = 1;
                next_state = compare;
            end

            compare: begin
                ABorALU = 0; 
                FN      = 2'b00;   
                if (Z) next_state = done;     
                else if (!N) next_state = sub_a; 
                else next_state = sub_b;        
            end
            
            sub_a: begin
                ABorALU = 0;
                FN      = 2'b00; 
                LDA     = 1;
                next_state = compare;
            end

            sub_b: begin
                ABorALU = 0;
                FN      = 2'b01; 
                LDB     = 1;
                next_state = compare;
            end

            done: begin
                ack = 1;
                if (!req) next_state = idle_a;
            end

            default: next_state = idle_a;
        endcase
    end
endmodule
