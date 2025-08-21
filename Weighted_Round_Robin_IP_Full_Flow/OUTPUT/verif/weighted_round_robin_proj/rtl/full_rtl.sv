// *** Start of the file - rtl.sv

module weighted_round_robin #(
    parameter int N          = 32,         // Number of requestors
    parameter int PRIORITY_W = 4,          // Priority (weight) bitwidth
    parameter int ID_BITS    = $clog2(N),  // Bits needed to encode requestor ID
    parameter int CREDIT_W   = 8           // Internal credit counter width
) (
    //============================================================
    // Misc
    //============================================================
    input wire clk,
    input wire rst,

    //============================================================
    // Round Robin Interface
    //============================================================
    input wire [N-1:0] req,  // Request signals
    input wire         ack,  // Handshake: 1 means "accepted" this cycle

    output logic [      N-1:0] gnt_w,  // One-hot grant
    output logic [ID_BITS-1:0] gnt_id, // Encoded ID of granted request

    //============================================================
    // Dynamic Priority/Weight Update Interface
    //============================================================
    input wire [PRIORITY_W-1:0] prio,     // New priority value
    input wire [   ID_BITS-1:0] prio_id,  // Which requestor to update
    input wire                  prio_upt  // Update strobe
);

    // ----------------------------------------------------------------
    // Priority (Weight) Storage
    // ----------------------------------------------------------------
    // Each of the N requestors has a 4-bit weight (PRIORITY_W).
    // We'll store these in a small register file.
    // prio_reg[i] will hold the weight of requestor i.
    // ----------------------------------------------------------------
    logic [PRIORITY_W-1:0] prio_reg[N-1:0];

    // ----------------------------------------------------------------
    // Credit Counters
    // ----------------------------------------------------------------
    // The “credit” (or “deficit”) array. Each requestor i has a credit count
    // that is replenished by its weight whenever the credit goes to zero.
    // We use 8 bits here to avoid overflow if priorities accumulate.
    // ----------------------------------------------------------------
    logic [  CREDIT_W-1:0] credit_r[N-1:0];
    logic [  CREDIT_W-1:0] credit_n[N-1:0];

    // ----------------------------------------------------------------
    // Arbitration Pointer
    // ----------------------------------------------------------------
    // Round-robin pointer that rotates through requestors searching
    // for one with nonzero credit and a valid request.
    // ----------------------------------------------------------------
    logic [ID_BITS-1:0] pointer_r, pointer_n;

    // ----------------------------------------------------------------
    // Combinational Next-State Logic
    // ----------------------------------------------------------------
    always_comb begin : wrr_next_state
        int k, j;
        bit found;
        logic [ID_BITS-1:0] idx;


        // Calculate grand for the given input
        for (k = 0; k < N; k++) begin : ack_set_loop
            idx   = (pointer_r + k) % N;
            found = 0;

            $display(
                "%t RTL: Looking for a match for the given request req=%X idx=%d k=%d pointer_r=%d, credit_r=%X",
                $time, req, idx, k, pointer_r, credit_r[idx]);

            // Check if this requestor is requesting and has credit.
            if ((req[idx] == 1'b1) && (credit_r[idx] != 0)) begin : ack_set_loop_req
                // We have a winner.
                found = 1;

                $display(
                    "%t RTL: Match found for the given request req=%X idx=%d k=%d gnt_id=%d gnt_w=%X pointer_r=%d pointer_n=%d",
                    $time, req, idx, k, gnt_id, gnt_w, pointer_r, pointer_n);

                break;
            end
        end

        if (found) begin : match_found
            gnt_id     = idx[ID_BITS-1:0];
            gnt_w      = '0;  // Clear all bits
            gnt_w[idx] = 1'b1;  // One-hot for idx

            // Update credits for next cycle
            for (k = 0; k < N; k++) begin : update_credits
                logic [ID_BITS-1:0] index;
                index = (pointer_r + k) % N;
                if (index == idx) begin
                    credit_n[index] = credit_r[index] - 1'b1;
                end else begin
                    credit_n[index] = credit_r[index];
                end
            end
            // Update pointer
            pointer_n = (idx + 1) % N;
            $display(
                "%t RTL: LOST CREDIT req=%X idx=%d gnt_id=%d gnt_w=%X pointer_r=%d pointer_n=%d",
                $time, req, idx, gnt_id, gnt_w, pointer_r, pointer_n);

        end else begin
            gnt_id = '0;  // No grant id
            gnt_w  = '0;  // No grant this cycle while we replenish
            // Update credits for next cycle
            for (k = 0; k < N; k++) begin : update_credits
                logic [ID_BITS-1:0] index;
                index = (pointer_r + k) % N;
                credit_n[index] = prio_reg[index] + 1;
            end
            // Update pointer
            pointer_n = (idx + 1) % N;
            $display(
                "%t RTL: REPLENISH CREDIT req=%X idx=%d gnt_id=%d gnt_w=%X pointer_r=%d pointer_n=%d",
                $time, req, idx, gnt_id, gnt_w, pointer_r, pointer_n);
        end

    end


    // ----------------------------------------------------------------
    // Sequential State Update
    // ----------------------------------------------------------------
    always_ff @(posedge clk or negedge rst) begin
        if (rst) begin
            // Reset all registers
            for (int i = 0; i < N; i++) begin
                prio_reg[i] <= '0;
                credit_r[i] <= 1;
            end
            pointer_r <= '0;
        end else begin
            // ------------------------------------------------------------
            // 1) Handle any priority/weight update
            //    The design specification says prio_upt cannot coincide with ack=1
            //    in the same cycle. You can enforce this with an assertion:
            //      assert(!(ack && prio_upt))
            // ------------------------------------------------------------
            if (prio_upt) begin
                prio_reg[prio_id] <= prio;
            end

            // ------------------------------------------------------------
            // 2) Update credit counters, pointer
            // ------------------------------------------------------------
            if (ack || (gnt_w == 0)) begin
                $display("%t RTL: Flop req=%X gnt_id=%d gnt_w=%X pointer_r=%d pointer_n=%d", $time,
                         req, gnt_id, gnt_w, pointer_r, pointer_n);
                for (int i = 0; i < N; i++) begin
                    credit_r[i] <= #2 credit_n[i];
                    $display("%t RTL: Flop Credit[%d]= %d", $time, i, credit_n[i]);

                end
                pointer_r <= #2 pointer_n;
            end

        end
    end

    // ----------------------------------------------------------------
    // Drive the module outputs
    // ----------------------------------------------------------------
    // assign gnt_w  = gnt_w_r;
    // assign gnt_id = gnt_id_r;

endmodule


// *** End of the file - rtl.sv

