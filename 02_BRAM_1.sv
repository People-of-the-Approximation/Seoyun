module bram_sm_fsm(
    input wire i_clk,
    input wire i_rst,
    input wire i_start,

    // To Softmax
    output reg [1:0]     o_sm_length_mode,
    output reg           o_sm_valid,
    output wire [1023:0] o_sm_in_x_flat, // softmax의 input

    // From Softmax
    input wire           i_sm_valid,
    input wire [1023:0]  i_sm_prob_flat, // softmax의 output

    // To BRAM
    output reg [3:0]     o_bram_addr,
    output reg           o_bram_en,
    output reg           o_bram_we,
    output wire [1023:0] o_bram_wdata,

    // From BRAM
    input wire [1023:0]  i_bram_rdata
);

//===================================

    localparam MAX_DEPTH    = 12;
    localparam WAIT_CYCLE   = 52;

    localparam IDLE     = 3'd0;
    localparam READ     = 3'd1;
    localparam WAIT     = 3'd2;
    localparam WRITE    = 3'd3;
    localparam DONE     = 3'd4;

    reg [2:0] state;

    reg [4:0] addr; //주소
    reg [5:0] cnt; // 카운트

    reg read_correction; // Latency 보정

    assign o_sm_in_x_flat  = i_bram_rdata;
    assign o_bram_wdata    = i_sm_prob_flat;
//===================================

    always @(posedge i_clk) begin
        if (i_rst) begin
            state           <= IDLE;
            r_addr          <= 0;
            r_wait_cnt      <= 0;

            o_bram_addr     <= 0;
            o_bram_en       <= 0;
            o_bram_we       <= 0;

            o_sm_valid      <= 0;
            o_sm_length_mode<= 2'd2;  
            read_correction <= 0;
        end
        else begin
            o_bram_en       <= 0;
            o_bram_we       <= 0;
            o_sm_valid      <= 0;

            o_sm_valid      <= read_correction; 
            read_correction <= 0;

            case(state)
                IDLE: begin
                    addr    <= 0;
                    cnt     <= 0;
                    if (i_start) state <= READ;
                end

                READ: begin
                    o_bram_en   <= 1;
                    o_bram_we   <= 0;
                    o_bram_addr <= addr;

                    read_correction <= 1;
                
                    if (addr < MAX_DEPTH - 1) begin
                        addr <= addr + 1
                    end 
                    else begin
                        addr <= 0;
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    if (cnt < WAIT_CYCLE - 1) begin
                        cnt <= cnt + 1;
                    end
                    else begin
                        cnt    <= 0;
                        addr   <= 5'd12;
                        state  <= WRITE;
                    end
                end

                WRITE: begin
                    if (i_sm_valid) begin
                        o_bram_en   <= 1;
                        o_bram_we   <= 1;
                        o_bram_addr <= addr;

                        if (addr < MAX_DEPTH - 1) begin
                        addr <= addr + 1;
                        end
                        else begin
                            state <= DONE;
                        end
                    end
                end
                
                DONE: begin
                    addr <= 0;
                    if (!i_start) state <= IDLE;
                end

            endcase

        end

    end




endmodule