// -----------------------------------------------------------------------------
//
//  Title      :  Automatic System Verilog Testbench for the GCD module
//             :
//  Developers :  Alexander Wang Aakersø
//             :
//  Purpose    :  Inspired by previous testbench by Otto. Extended to use randomness.
//             :
//  Revision   : 02203 fall 2025 v.1.0
//
// -----------------------------------------------------------------------------

module gcd_automated_tb ();

  // Number of tests
  localparam number_of_tests = 10000; // takes about 32ms in simulation time to run (depends on random values generated). 

  // Internal testcase struct
  typedef struct {

    shortint unsigned a;
    shortint unsigned b;
    shortint unsigned c_expected;

  } test_case_t;

  test_case_t tests [number_of_tests]; 

  // Period of the clock
  localparam CLOCK = 20ns;

  // Internal signals
  logic clk, reset;
  logic req, ack;
  logic [15 : 0] AB, C;

  // scorekeeping signals
  integer error = 0;
  
  // Instantiate gcd_top module and wire it up to internal signals used for testing
  gcd #(
      .n(2)
  ) u_dut (
      .clk  (clk),    // The clock signal.
      .reset(reset),  // Reset the module.
      .req  (req),    // Start computation.
      .AB   (AB),     // The two operands.
      .ack  (ack),    // Computation is complete.
      .C    (C)       // The result.
  );

  // Clock generation (simulation use only)
  initial begin
    clk = 0;
    forever #(CLOCK / 2) clk = ~clk;
  end

  // MAIN TEST LOOP
  initial begin
    // Reset entity for some clock cycles
    reset = 1;
    #(CLOCK * 4);
    reset = 0;
    #CLOCK;

    // Generate random test values
    foreach (tests[i]) begin
      generate_test(tests[i]);
    end

    // Run test cases
    foreach (tests[i]) begin
      run_test(tests[i]);
    end

    #CLOCK;

    if(error != 0) $display("====== Test Failed! (Failed %d tests!) ======", error );
    else $display("====== Test Succeeded! (Ran %d tests!) ======", number_of_tests );
    $finish;

  end

  initial begin
    $dumpfile("gcd_tb.vcd");
    $dumpvars();
  end

  // HELPER TASKS

  task automatic generate_test(ref test_case_t tc);
    // Generate random positive 16-bit values for a and b
    tc.a = $urandom_range(1, 65535);
    tc.b = $urandom_range(1, 65535);

    // Calculate expected GCD using Euclidean algorithm
    tc.c_expected = calculate_gcd(tc.a, tc.b);
  endtask;

  task automatic run_test(ref test_case_t tc);
    // Supply first operand
    req = 1;
    AB = tc.a;

    // Wait for ack high
    while (ack != 1) begin
      @(posedge clk);
    end

    req = 0;

    // Wait for ack low
    while (ack != 0) begin
      @(posedge clk);
    end

    // Supply second operand
    req = 1;
    AB = tc.b;

    // Wait for ack high
    while (ack != 1) begin
      @(posedge clk);
    end

    // Test the result of the computation
    if (C != tc.c_expected) begin
      $error("GCD test failed: GCD(%0d, %0d) = %0d, expected %0d", tc.a, tc.b, C, tc.c_expected);
      error++;
    end else begin
      $display("GCD test passed: GCD(%0d, %0d) = %0d", tc.a, tc.b, C);
    end

    req = 0;

    // Wait for ack low
    while (ack != 0) begin
      @(posedge clk);
    end
  endtask;

  // Helper function to calculate expected GCD using Euclidean algorithm
  function automatic shortint unsigned calculate_gcd(
    input shortint unsigned a, 
    input shortint unsigned b
  );
    shortint unsigned temp;
    
    // Handle zero cases
    if (a == 0) return b;
    if (b == 0) return a;
    
    // Euclidean algorithm
    while (b != 0) begin
      temp = b;
      b = a % b;
      a = temp;
    end
    return a;
  endfunction

endmodule