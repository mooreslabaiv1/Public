
`ifndef CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_IF__SV
`define CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_IF__SV

// -----------------------------------------------------------------------------
interface crc32_accelerator_if(input logic clk, input logic rst);
   // Input signals to the DUT
   logic [7:0] data_in;
   logic       data_valid;

   // Output signals from the DUT
   logic [31:0] crc_out;
   logic        crc_valid;

   // Clocking block for driving inputs
   clocking drv_cb @(posedge clk);
      output data_in;
      output data_valid;
   endclocking

   // Clocking block for monitoring outputs
   clocking mon_cb @(posedge clk);
      input crc_out;
      input crc_valid;
      input data_in;
      input data_valid;
   endclocking
endinterface
`endif // CRC32_ACCELERATOR_P_CRC32_ACCELERATOR_IF__SV
