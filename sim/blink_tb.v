// Testbench: run with `make sim`, view waves with `make wave`
`timescale 1ns / 1ps
module blink_tb;
  reg        clk = 0;
  reg  [1:0] key = 2'b10;  // KEY[0] pressed (reset), KEY[1] released
  reg  [9:0] sw = 0;
  wire [9:0] led;

  blink dut (
      .MAX10_CLK1_50(clk),
      .KEY(key),
      .SW(sw),
      .LEDR(led)
  );

  always #10 clk = ~clk;  // 50 MHz

  task press;  // hold KEY[1] for a while, then release
    begin
      key[1] = 0; #200;
      key[1] = 1; #200;
    end
  endtask

  initial begin
    $dumpfile("blink_tb.vcd");
    $dumpvars(0, blink_tb);
    #50 key[0] = 1;            // release reset
    press; press; press;       // +3
    sw[0] = 1; press; sw[0] = 0;  // paused: ignored
    press;                     // +1
    if (led !== 4) begin
      $display("FAIL: LEDR = %0d, expected 4", led);
      $fatal(1);
    end
    $display("PASS: LEDR = %0d", led);
    $finish;
  end
endmodule
