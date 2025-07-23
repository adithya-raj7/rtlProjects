module AsyncFifo #(
  parameter             DEPTH = 16 ,
  parameter             DW    = 32
)(
  input  logic          wrClk      ,
  input  logic          rdClk      ,
  input  logic          wrRst_n    ,
  input  logic          rdRst_n    ,
  input  logic          wrEn       ,
  input  logic          rdEn       ,
  input  logic [DW-1:0] wrData     ,
  output logic [DW-1:0] rdData     ,
  output logic          empty      ,
  output logic          full 
);

  // Local declarations

  localparam AW = 4;

  logic [AW:0] wrPtr,wrPtrGrey,wrPtrGreyQ1,wrPtrGreySync;
  logic [AW:0] rdPtr,rdPtrGrey,rdPtrGreyQ1,rdPtrGreySync;

  logic [DW-1:0] mem [DEPTH-1:0];

  //Write operation

  always_ff @(posedge wrClk or negedge wrRst_n)
  begin
    if(!wrRst_n)
    begin
      wrPtr <=0;
    end
    else if(wrEn && !full)
    begin
      wrPtr <= wrPtr+1;
    end
    else
    begin
      wrPtr <= wrPtr;
    end
  end

  always_ff @(posedge wrClk)
  begin
    if(wrEn && !full)
      mem[wrPtr[AW-1:0]] <= wrData;
  end

  //Read Operation
  always_ff @(posedge rdClk or negedge rdRst_n)
  begin
    if (!rdRst_n)
    begin
      rdPtr <= 0;
    end
    else if(rdEn && !empty)
    begin
      rdPtr <= rdPtr + 1;
    end
    else
    begin
      rdPtr <= rdPtr;
    end
  end
  

  // Grey conversion of pointers
  assign wrPtrGrey  = (wrPtr>>1)^wrPtr;
  assign rdPtrGrey  = (rdPtr>>1)^rdPtr;

  // Synchronize write pointer to rdClk
  always_ff @(posedge rdClk or negedge rdRst_n)
  begin
    if(!rdRst_n)
    begin
      wrPtrGreyQ1   <= 0;
      wrPtrGreySync <= 0;
    end
    else
    begin
      wrPtrGreyQ1   <= wrPtrGrey;
      wrPtrGreySync <= wrPtrGreyQ1;
    end
  end

  // Synchronize read pointer to wrClk
  always_ff @(posedge wrClk or negedge wrRst_n)
  begin
    if(!wrRst_n)
    begin
      rdPtrGreyQ1   <= 0;
      rdPtrGreySync <= 0;
    end
    else
    begin
      rdPtrGreyQ1   <= rdPtrGrey;
      rdPtrGreySync <= rdPtrGreyQ1;
    end
  end 

  // Drive  read data
  assign rdData = empty ? '0 : mem[rdPtr[AW-1:0]];
  
  // Full and Empty logic
  
  assign empty  = (wrPtrGreySync == rdPtrGrey);
  assign full   = (wrPtrGrey     == {~rdPtrGreySync[AW:AW-1], rdPtrGreySync[AW-2:0]});

endmodule