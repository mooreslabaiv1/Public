

`ifndef WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_IF__SV
`define WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_IF__SV

// -----------------------------------------------------------------------------
interface prio_update_if #(parameter int N = 32, parameter int PRIORITY_W = 4, parameter int ID_BITS = $clog2(N));
    // Declarations at the beginning
    logic                   clk;
    logic                   rst;
    logic [PRIORITY_W-1:0]  prio;
    logic [ID_BITS-1:0]     prio_id;
    logic                   prio_upt;

    // No executable code within the interface as per guidelines
endinterface : prio_update_if
`endif // WEIGHTED_ROUND_ROBIN_PRIO_UPDATE_IF__SV