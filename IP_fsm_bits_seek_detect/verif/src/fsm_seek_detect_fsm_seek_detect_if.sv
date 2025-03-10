

`ifndef FSM_SEEK_DETECT_FSM_SEEK_DETECT_IF__SV
`define FSM_SEEK_DETECT_FSM_SEEK_DETECT_IF__SV

// -----------------------------------------------------------------------------
// {+++++ <Modify the below interface code as needed> +++++}
interface fsm_seek_detect_if (input logic clk, input logic aresetn);

  // Interface signals
  logic x;   // Input to DUT  
  logic z;   // Output from DUT  

  // Clocking block (for illustration)
  clocking cb @(posedge clk);
    input  x, aresetn;
    output z;
  endclocking

endinterface : fsm_seek_detect_if
`endif // FSM_SEEK_DETECT_FSM_SEEK_DETECT_IF__SV