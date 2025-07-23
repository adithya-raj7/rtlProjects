`timescale 1ns / 1ps
typedef enum logic [2:0] {
    UP,
    DOWN,
    UPSAT,
    DOWNSAT
} counter_mode_t;

module ParamCounter_tb;

logic          rst_n = 0;
logic          en    = 0;
logic          clk   = 0;
wire [4:0]     count0;
wire [3:0]     count1;
wire [3:0]     count2;
wire [3:0]     count3;

always #5 clk = ~clk;


ParamCounter #(
    .MAX(30),
    .MIN(4),
    .MODE(UP),
    .CYCLE(1)
) u0_ParamCounter (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .count(count0)
);

ParamCounter #(
    .MAX(15),
    .MIN(10),
    .MODE(UPSAT),
    .CYCLE(1)
) u1_ParamCounter (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .count(count1)
);

ParamCounter #(
    .MAX(15),
    .MIN(6),
    .MODE(DOWN),
    .CYCLE(8)
) u2_ParamCounter (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .count(count2)
);

ParamCounter #(
    .MAX(15),
    .MIN(10),
    .MODE(DOWNSAT),
    .CYCLE(2)
) u3_ParamCounter (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .count(count3)
);

initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, ParamCounter_tb);           // dumps TB signals
    $dumpvars(1, ParamCounter_tb.u0_ParamCounter); // dumps DUT signals
end

initial 
begin
  $display("Testbench started.");
  #10;
  rst_n = 1;
  #10;
  en    = 1;
  #50;
  en    = 0;
  #10;
  en    = 1;
  #100;
  rst_n = 0;
  #10;
  $display("Testbench finished.");
  $finish;
end

initial begin
    $monitor("Time: %0t | count0 = %0d | count1 = %0d | count2 = %0d | count3 = %0d", $time, count0, count1, count2, count3);
end

endmodule