


`ifndef SERIALDP_SERIAL_IF__SV
`define SERIALDP_SERIAL_IF__SV

// -----------------------------------------------------------------------------
// {+++++ <Modify the below interface code as needed> +++++}
interface serial_if (input logic clk, input logic rst);

  // -----------------------------------------------------
  // Block Scope Declaration (all declarations at top)
  // -----------------------------------------------------
  logic in;
  logic [7:0] out_byte;
  logic done;

endinterface

`endif // SERIALDP_SERIAL_IF__SV