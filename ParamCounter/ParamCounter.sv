//-------------------------------------------------------------------------------------------------
//This is the RTL for a paramterized counter block
//-------------------------------------------------------------------------------------------------

typedef enum logic [2:0] {
    UP,
    DOWN,
    UPSAT,
    DOWNSAT
} counter_mode_t;

module ParamCounter 
#(
  parameter                          MAX     = 255 ,
  parameter                          MIN     = 0   ,
  parameter counter_mode_t           MODE    = UP  ,
  parameter                          CYCLE   = 1                               //Number of cycles for counting one unit
)(
  input  logic                       clk           ,
  input  logic                       rst_n         ,
  input  logic                       en            ,
  output logic [$clog2(MAX+1)-1:0]   count
);

 localparam CYCLE_WIDTH = (CYCLE > 1) ? $clog2(CYCLE) : 1;
 logic [CYCLE_WIDTH-1:0] cycleCount;

  always_ff @(posedge clk or negedge rst_n) 
  begin
    if (!rst_n) 
    begin
      count      <= (MODE == DOWN || MODE == DOWNSAT) ? MAX : MIN;
      cycleCount <= 0;
    end 
    else 
    begin
      if (cycleCount + 1 == CYCLE) 
      begin
        cycleCount <= 0;
  
        if (en) 
        begin
          case (MODE)
            UP:        count <= count + 1;
            DOWN:      count <= count - 1;
            UPSAT:     if (count != MAX) count <= count + 1;
            DOWNSAT:   if (count != MIN) count <= count - 1;
            default:   count <= count;
          endcase
        end
      end 
      else 
      begin
        cycleCount <= cycleCount + 1;
      end
    end
  end
endmodule