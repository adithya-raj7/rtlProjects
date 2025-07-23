`timescale 1ns / 1ps
module AsyncFifo_tb;

logic [31:0] wrData  = 0;
logic        wrClk   = 0;
logic        wrRst_n = 0;
logic        wrEn    = 0;
logic        rdClk   = 0;
logic        rdRst_n = 0;
logic        rdEn    = 0;
wire         full;
wire         empty;
wire  [31:0] rdData;

always #5  wrClk = ~wrClk;
always #10 rdClk = ~rdClk;

AsyncFifo #(
    .DW      (32),
    .DEPTH   (16)
) u_AsyncFifo(
    .wrClk   (wrClk),
    .wrRst_n (wrRst_n),
    .wrEn    (wrEn),
    .rdClk   (rdClk),
    .rdRst_n (rdRst_n),
    .rdEn    (rdEn),
    .wrData  (wrData),
    .full    (full),
    .empty   (empty),
    .rdData  (rdData)
);

initial begin
    $dumpfile("AsyncFifo.vcd");
    $dumpvars(0, AsyncFifo_tb);           // dumps TB signals
    $dumpvars(1, AsyncFifo_tb.u_AsyncFifo); // dumps DUT signals
end

initial begin
    $display("Starting Async FIFO Testbench");

  #20;
  wrRst_n = 1;
  rdRst_n = 1;

  repeat (2) @(posedge wrClk); // small wait after reset

  // Phase 1: Fill FIFO
  $display("---- Writing to FIFO ----");
  for (int i = 0; i < 20; i++) begin
    @(posedge wrClk);
    if (!full) begin
      wrData <= $random;
      wrEn   <= 1;
      $display("[%0t] WRITING: %h", $time, wrData);
    end else begin
      wrEn <= 0;
      $display("[%0t] FIFO FULL, write skipped", $time);
    end
  end
  @(posedge wrClk);
  wrEn <= 0;

  // Phase 2: Wait some time
  repeat (5) @(posedge rdClk);

  // Phase 3: Read from FIFO
  $display("---- Reading from FIFO ----");
  for (int j = 0; j < 20; j++) begin
    @(posedge rdClk);
    if (!empty) begin
      rdEn <= 1;
      if(j>0)
        $display("[%0t] READING: %h", $time, rdData);
    end else begin
      rdEn <= 0;
      $display("[%0t] FIFO EMPTY, read skipped", $time);
    end
  end
  @(posedge rdClk);
  rdEn <= 0;

  $display("---- Testbench Done ----");
  #20;
  $finish;
end

endmodule