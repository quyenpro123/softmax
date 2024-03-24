module top_tb_16();
    localparam                          data_size = 16                                                          ;
    reg                                 axi_clock_i                                                             ;
    reg                                 axi_reset_n_i                                                           ;
    reg                                 s_axis_valid_i                                                          ;
    reg     signed  [2*data_size - 1:0] s_axis_data_i                                                           ;
    reg                                 s_axis_last_i                                                           ;    
    reg                                 m_axis_ready_i                                                          ;
    
    wire                                s_axis_ready_o                                                          ;
    wire                                m_axis_valid_o                                                          ;
    wire    signed  [data_size - 1:0]   m_axis_data_o                                                           ;
    wire                                m_axis_last_o                                                           ;
    reg                                 fisrt_data                                                              ;
    
    integer i                                                                                                   ;
    reg             [2*data_size - 1:0] buffer  [9:0]                                                           ;
    top_block_16 #(data_size) top_16(
        .axi_clock_i(axi_clock_i)                                                                               ,
        .axi_reset_n_i(axi_reset_n_i)                                                                           ,
        .s_axis_valid_i(s_axis_valid_i)                                                                         ,
        .s_axis_data_i(s_axis_data_i)                                                                           ,
        .s_axis_last_i(s_axis_last_i)                                                                           ,
        .s_axis_ready_o(s_axis_ready_o)                                                                         ,
        .m_axis_valid_o(m_axis_valid_o)                                                                         ,
        .m_axis_data_o(m_axis_data_o)                                                                           ,
        .m_axis_last_o(m_axis_last_o)
    );
    always @(posedge axi_clock_i)
        begin
            if (~axi_reset_n_i)
                buffer[0] = 32'b1100_0000_1001_1101_1111_1011_1110_0111                                            ;
                buffer[1] = 32'b0100_0000_0111_1110_1111_1001_1101_1011                                            ;
                buffer[2] = 32'b0100_0000_1011_0111_0010_0010_1101_0000                                            ;
                buffer[3] = 32'b1011_1111_1101_0000_0000_0000_0000_0000                                            ;
                buffer[4] = 32'b0100_0000_0100_0000_0100_0001_1000_1001                                            ;
                buffer[5] = 32'b0100_0000_1001_0111_0000_0010_0000_1100                                            ;
                buffer[6] = 32'b0011_1111_1111_0110_1010_0111_1110_1111                                            ;
                buffer[7] = 32'b0011_1111_1101_0001_0000_0110_0010_0100                                            ;
                buffer[8] = 32'b0100_0000_1011_1001_1010_1001_1111_1011                                            ;
                buffer[9] = 32'b1100_0000_0010_0100_1010_1100_0000_1000                                            ;
        end
    initial 
    begin
        axi_clock_i = 0                                                                                         ;
        axi_reset_n_i = 0                                                                                       ;
        s_axis_data_i = 0                                                                                       ;
        s_axis_valid_i = 0                                                                                      ;
        s_axis_last_i <= 0                                                                                      ;
        #30
        axi_reset_n_i = 1                                                                                       ;
    end
    
    always @(posedge axi_clock_i)
    begin
        if (~axi_reset_n_i)
            begin
                fisrt_data <= 0                                                                                 ;
                i <= 1                                                                                          ;
                s_axis_valid_i <= 0                                                                             ;
                s_axis_data_i <= 0                                                                              ;
            end
        else
            begin
                if (i <= 9)
                    s_axis_valid_i <= 1                                                                         ;
                if (axi_reset_n_i && ~fisrt_data)
                begin
                    fisrt_data <= 1                                                                             ;
                    s_axis_data_i <= buffer[0]                                                                  ;
                end
                if (s_axis_ready_o && s_axis_valid_i)
                    begin
                        i <= i + 1                                                                              ;
                        s_axis_data_i <= buffer[i]                                                              ;
                    end
                if (i == 10 && s_axis_valid_i)
                    begin
                        s_axis_valid_i <= 0                                                                     ;
                        s_axis_last_i <= 1                                                                      ;
                    end
                if (s_axis_last_i)
                    s_axis_last_i <= 0                                                                          ;
            end
    end
    always #5 axi_clock_i = ~axi_clock_i                                                                        ;
endmodule
