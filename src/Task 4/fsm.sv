module fsm(
  input  logic        clk,
  input  logic        reset,
  input  logic        req,
  output logic        ack
);

  typedef enum logic [3:0] {
    idleA=0, sampleA=1, ackA=2, idleB=3, sampleB=4, compare=5, sub=6, ackResult=7
  } state_t;

  state_t state, next_state;

  // Combinatorial logic
  always_comb begin
    next_state = state;
    ack = 1'b0;

    case (state)
      idleA:
        if (req) next_state = sampleA;

      sampleA:
      begin
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
        next_state = compare;
      end

      compare:
      begin

      end

      sub:
      begin


        next_state = compare;
      end

      ackResult:
      begin
        ack = 1'b1;

        if (!req) next_state = idleA;
      end

      default: next_state = idleA;
    endcase
  end


  // Registers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= idleA;
    end else begin
      state <= next_state;
    end
  end


endmodule