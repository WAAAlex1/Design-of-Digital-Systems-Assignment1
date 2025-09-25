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
  input  logic        clk,
  input  logic        reset,
  input  logic        req,
  input  logic [15:0] AB,
  output logic        ack,
  output logic [15:0] C
);

  typedef enum logic [2:0] {
    idleA=0, sampleA=1, ackA=2, idleB=3, sampleB=4, compare=5, sub=6, ackResult=7
  } state_t; // Input your own state names here

  state_t state, next_state;
  
  // Standard signals
  shortint unsigned reg_a, next_reg_a;
  shortint unsigned reg_b, next_reg_b;

  // Optimizations signals for Operator sharing
  shortint unsigned op1, op2, res;

  // Operator sharing logic
  always_comb begin

    if(reg_a > reg_b) begin

      op1 = reg_a;
      op2 = reg_b;

    end else begin

      op1 = reg_b;
      op2 = reg_a;
      
    end

    res = op1 - op2;

  end 

    // Combinatorial logic
  always_comb begin
    next_state = state;
    next_reg_a = reg_a;
    next_reg_b = reg_b;
    ack = 1'b0;
    C   = 16'd0;

    case (state)
      idleA: 
        if (req) next_state = sampleA;

      sampleA: 
      begin
        next_reg_a = AB;
        next_state = ackA;
      end

      ackA: 
      begin
        ack = 1'b1;
        if (!req) next_state = idleB; 
      end

      idleB: 
      begin
        if (req) next_state = sampleB;
      end  

      sampleB: 
      begin
        next_reg_b = AB;
        next_state = compare; 
      end

      compare: 
      begin
        if (reg_a == reg_b) next_state = ackResult;
        else next_state = sub;
      end

      sub: 
      begin
        if(reg_a > reg_b) next_reg_a = res;
        else next_reg_b = res;
        
        next_state = compare;
      end
      
      ackResult: 
      begin
        ack = 1'b1;
        C = reg_a;
        if (!req) next_state = idleA; 
      end

      default: next_state = idleA;
    endcase
  end

  // Registers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= idleA;
      reg_a <= 16'd0;
      reg_b <= 16'd0;
    end else begin
      state <= next_state;
      reg_a <= next_reg_a;
      reg_b <= next_reg_b;
    end
  end

endmodule
