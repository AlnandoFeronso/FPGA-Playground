// DE10-Lite starter: LED counter
//   LEDR[9:0] : binary number, +1 on each KEY[1] press
//   KEY[0]    : reset (button pressed = 0)
//   SW[0]     : pause when switched up (presses ignored)
module blink (
    input  wire       MAX10_CLK1_50,
    /* verilator lint_off SYNCASYNCNET */  // KEY[0] = async reset, KEY[1] = synced button
    input  wire [1:0] KEY,
    /* verilator lint_on SYNCASYNCNET */
    /* verilator lint_off UNUSEDSIGNAL */  // spare switches for your experiments
    input  wire [9:0] SW,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg  [9:0] LEDR
);
  wire reset_n = KEY[0];
  wire pause   = SW[0];

  // Bring KEY[1] into the clock domain (2 flip-flops) and detect the press edge
  reg [2:0] add_sync;  // powers up as 0 on the FPGA
  always @(posedge MAX10_CLK1_50) add_sync <= {add_sync[1:0], ~KEY[1]};
  wire add_press = add_sync[1] & ~add_sync[2];  // 1-cycle pulse when pressed

  always @(posedge MAX10_CLK1_50 or negedge reset_n) begin
    if (!reset_n) begin
      LEDR <= 0;
    end else if (!pause && add_press) begin
      LEDR <= LEDR + 1'b1;
    end
  end
endmodule
