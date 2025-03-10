module crc32_accelerator_p(
    input  wire clk,
    input  wire rst,
    input  wire [7:0] data_in,
    input  wire data_valid,
    output wire [31:0] crc_out,
    output wire crc_valid
);

localparam POLY = 32'hEDB88320;

// Internal register to store the current CRC value
reg [31:0] crc_reg;
reg        valid_reg;

// Function to calculate the next CRC given current CRC and a new byte of data
function automatic [31:0] next_crc(
    input [31:0] cur_crc,
    input [7:0]  din
);
    integer i;
    reg [31:0] tmp_crc;
    begin
        // XOR the incoming data byte with the lower 8 bits of the CRC
        // Note: The reference model suggests a bit-reversed interpretation,
        // but following the given code literally as is:
        //   crc_reg ^= data_in;
        // means just XOR the data_in into the low-order byte.
        tmp_crc = cur_crc ^ din;
        $display("CRC_RTL before `for` tmp_crc = 0x%h, din = 0x%h", tmp_crc, din);
        // Perform 8 iterations of shifting and conditionally XORing with POLY
        for (i = 0; i < 8; i = i + 1) begin
            $display("CRC_RTL1 tmp_crc = 0x%h, din = 0x%h", tmp_crc, din);
            if (tmp_crc[0]) begin           
                tmp_crc = (tmp_crc >> 1) ^ POLY;
                $display("CRC_RTL `if` tmp_crc = 0x%h, din = 0x%h", tmp_crc, din);                
            end                
            else begin
                tmp_crc = tmp_crc >> 1;
                $display("CRC_RTL `else` tmp_crc = 0x%h, din = 0x%h", tmp_crc, din);                                
            end
            $display("CRC_RTL2 tmp_crc = 0x%h, din = 0x%h", tmp_crc, din);
        end

        next_crc = tmp_crc;
    end
endfunction

// Synchronous process for CRC update
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // According to the provided details, at reset crc_reg = 0xFFFFFFFF
        crc_reg   <= 32'hFFFFFFFF;
        valid_reg <= 1'b0;
    end else begin
        if (data_valid) begin
            // Update CRC when data is valid
            crc_reg   <= next_crc(crc_reg, data_in);
            valid_reg <= 1'b1;
        end else begin
            valid_reg <= 1'b0;
        end
    end
end

assign crc_out   = crc_reg;
assign crc_valid = valid_reg;

endmodule

