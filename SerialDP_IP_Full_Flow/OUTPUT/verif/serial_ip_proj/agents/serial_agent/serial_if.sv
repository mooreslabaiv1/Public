`ifndef SERIAL_IF__SV
`define SERIAL_IF__SV

interface serial_if (
    input logic clk,
    input logic rst
);

  //******************************************************************************
  // Ports
  //******************************************************************************
logic in;
  logic [7:0] out_byte;
  logic done;

  //******************************************************************************
  // Clocking Block
  //******************************************************************************
  clocking serial_cb @(posedge clk);
    default input #1step;
    default output #1;
output in;
    input out_byte;
    input done;
  endclocking : serial_cb

endinterface : serial_if

`endif  // SERIAL_IF__SV