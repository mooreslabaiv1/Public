`ifndef CLK_RST_IF__SV
`define CLK_RST_IF__SV

interface clk_rst_if ();

  //******************************************************************************
  // Ports
  //******************************************************************************
  logic clk;
  logic rst;
  logic clk_div;

endinterface : clk_rst_if

`endif // CLK_RST_IF__SV