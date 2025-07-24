module DualPortRAM #(
    parameter AW = 8,
    parameter DW = 32,
    parameter SETPRIORITY = 0        // 0 = No priority, 1 = A port priority , 2 = B port priority for writing
)(
    input  logic          clk,
    
    input  logic          aWrite,
    input  logic          aEn,
    input  logic [AW-1:0] aAddr,
    input  logic [DW-1:0] aWriteData,
    output logic [DW-1:0] aReadData,

    input  logic          bWrite,
    input  logic          bEn,
    input  logic [AW-1:0] bAddr,
    input  logic [DW-1:0] bWriteData,
    output logic [DW-1:0] bReadData,
    output                conflict
);

logic [DW-1:0] mem [(1<<AW)-1:0];
logic conflictDetected;

assign conflictDetected = (aAddr == bAddr) && (aWrite && bWrite);
assign conflict         = (SETPRIORITY == 0) ? conflictDetected : 0;

always_ff @(posedge clk) 
begin
  if (conflictDetected) 
  begin
    case (SETPRIORITY)
      1: if (aEn && aWrite) mem[aAddr] <= aWriteData;
      2: if (bEn && bWrite) mem[bAddr] <= bWriteData;
      default: ; // Do nothing on true conflict
    endcase
  end else 
  begin
    if (aEn && aWrite) mem[aAddr] <= aWriteData;
    if (bEn && bWrite) mem[bAddr] <= bWriteData;
  end
end

assign aReadData = aEn ? mem[aAddr] : '0;
assign bReadData = bEn ? mem[bAddr] : '0;

endmodule