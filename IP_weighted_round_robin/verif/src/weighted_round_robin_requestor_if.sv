
`ifndef WEIGHTED_ROUND_ROBIN_REQUESTOR_IF__SV
`define WEIGHTED_ROUND_ROBIN_REQUESTOR_IF__SV

// -----------------------------------------------------------------------------
interface requestor_if #(parameter int N = 32, parameter int ID_BITS = $clog2(N));
    // Declarations at the beginning
    logic          clk;
    logic          rst;
    logic [N-1:0]  req;
    logic          ack;
    logic [N-1:0]  gnt_w;
    logic [ID_BITS-1:0] gnt_id;

    // No executable code within the interface as per guidelines
endinterface : requestor_if
`endif // WEIGHTED_ROUND_ROBIN_REQUESTOR_IF__SV
