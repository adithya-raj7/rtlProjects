`timescale 1ns/1ps

module DualPortRAM_tb;

  // Parameters
  localparam AW = 8;
  localparam DW = 32;
  localparam DEPTH = 1 << AW;

  // Clock
  logic clk = 0;
  always #5 clk = ~clk;

  // Port A signals
  logic          aWrite, aEn;
  logic [AW-1:0] aAddr;
  logic [DW-1:0] aWriteData;
  logic [DW-1:0] aReadData;

  // Port B signals
  logic          bWrite, bEn;
  logic [AW-1:0] bAddr;
  logic [DW-1:0] bWriteData;
  logic [DW-1:0] bReadData;
  logic          conflict;

  // DUT Instance
  DualPortRAM #(
    .AW(AW),
    .DW(DW),
    .SETPRIORITY(2)
  ) dut (
    .clk         (clk),
    .aWrite      (aWrite),
    .aEn         (aEn),
    .aAddr       (aAddr),
    .aWriteData  (aWriteData),
    .aReadData   (aReadData),
    .bWrite      (bWrite),
    .bEn         (bEn),
    .bAddr       (bAddr),
    .bWriteData  (bWriteData),
    .bReadData   (bReadData),
    .conflict    (conflict)
  );

  // Stimulus
  initial begin
    $display("Starting DualPortRAM test...");
    $dumpfile("dualport_ram.vcd");
    $dumpvars(0, DualPortRAM_tb);

    // Reset-like idle phase
    aWrite = 0; aEn = 0; aAddr = 0; aWriteData = 0;
    bWrite = 0; bEn = 0; bAddr = 0; bWriteData = 0;
    repeat (2) @(posedge clk);
    #5;
    ta_Back_to_Back_writes();
    #5;
    ta_Simultaneous_writes();
    #5;
    ta_conflicted_write();

    $display("Test complete.");
    $finish;
  end
  
  initial begin
    $monitor("Time: %0t | conflict set : %b", $time, conflict);
  end

    task ta_Back_to_Back_writes();
       $display("==== Starting Back to Back Writes ====");
      // Write from Port A to locations 0-3
      for (int i = 0; i < 4; i++) begin
        @(posedge clk);
        aEn = 1; aWrite = 1; aAddr = i; aWriteData = 32'hA0000000 + i;
      end
      @(posedge clk); aEn = 0; aWrite = 0;
  
      // Write from Port B to locations 4-7
      for (int i = 0; i < 4; i++) begin
        @(posedge clk);
        bEn = 1; bWrite = 1; bAddr = i + 4; bWriteData = 32'hB0000000 + i;
      end
      @(posedge clk); bEn = 0; bWrite = 0;
  
      // Read back from A
      for (int i = 0; i < 4; i++) begin
        @(posedge clk);
        aEn = 1; aWrite = 0; aAddr = i;
        @(posedge clk);
        $display("Port A Read Addr %0d: %h", i, aReadData);
        assert(aReadData == (32'hA0000000 + i)) else $fatal("Mismatch on A[%0d]", i);
      end
      aEn = 0;
  
      // Read back from B
      for (int i = 0; i < 4; i++) begin
        @(posedge clk);
        bEn = 1; bWrite = 0; bAddr = i + 4;
        @(posedge clk);
        $display("Port B Read Addr %0d: %h", i+4, bReadData);
        assert(bReadData == (32'hB0000000 + i)) else $fatal("Mismatch on B[%0d]", i+4);
      end
      bEn = 0;
    endtask

    task ta_Simultaneous_writes();
      $display("==== Starting Simultaneous Writes ====");
      // Write from Port A to locations 20-23 and from Port B to locations 24 to 27 
      for (int i = 20; i < 24; i++) begin
        @(posedge clk);
        aEn = 1; aWrite = 1; aAddr = i; aWriteData = 32'hA000B000 + i;
        bEn = 1; bWrite = 1; bAddr = i + 4; bWriteData = 32'hB000A000 + i;
      end
      @(posedge clk); aEn = 0; aWrite = 0; bEn = 0; bWrite = 0;
  
      // Read back from A and B
      for (int i = 20; i < 24; i++) begin
        @(posedge clk);
        aEn = 1; aWrite = 0; aAddr = i;
        bEn = 1; bWrite = 0; bAddr = i + 4;
        @(posedge clk);
        $display("Port A Read Addr %0d: %h", i, aReadData);
        assert(aReadData == (32'hA000B000 + i)) else $fatal("Mismatch on A[%0d]", i);
        $display("Port B Read Addr %0d: %h", i+4, bReadData);
        assert(bReadData == (32'hB000A000 + i)) else $fatal("Mismatch on B[%0d]", i+4);
      end
      aEn = 0;
      bEn = 0;
    endtask

    task ta_conflicted_write();
      $display("==== Starting conflicted Write ====");
      // Conflict test — both write to same address
      @(posedge clk);
      aEn = 1; aWrite = 1; aAddr = 8; aWriteData = 32'hDEADBEAF;
      bEn = 1; bWrite = 1; bAddr = 8; bWriteData = 32'hCAFEBABE;
      @(posedge clk);
      aWrite = 0; bWrite = 0;
      $display("A wrote data %h to Addr %h, and B wrote data %h to Addr %h",aWriteData,aAddr,bWriteData,bAddr);
  
      // Read from both
      @(posedge clk);
      aEn = 1; aAddr = 8;
      bEn = 1; bAddr = 8;
      @(posedge clk);
      $display("After conflict: A Read Addr %h = %h, B Read Addr %h = %h", aAddr, aReadData, bAddr, bReadData);
      assert(aReadData == 32'hCAFEBABE && bReadData == 32'hCAFEBABE) else $fatal("Conflict priority logic failed. Expected B's data to win.");
    endtask


endmodule
