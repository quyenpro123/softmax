module top_tb_16();
    localparam                          data_size = 16                                                          ;
    reg                                 axi_clock_i                                                             ;
    reg                                 axi_reset_n_i                                                           ;
    reg                                 s_axis_valid_i                                                          ;
    reg             [2*data_size - 1:0] s_axis_data_i                                                           ;
    reg                                 s_axis_last_i                                                           ;    
    reg                                 m_axis_ready_i                                                          ;
    
    reg                                 s_axis_last_i_temp                                                      ;
    
    wire                                s_axis_ready_o                                                          ;
    wire                                m_axis_valid_o                                                          ;
    wire            [2*data_size - 1:0] m_axis_data_o                                                           ;
    wire                                m_axis_last_o                                                           ;
    reg                                 fisrt_data                                                              ;
    
    reg                                 valid                                                                   ;
    integer j                                                                                                   ;
    integer i                                                                                                   ;
    reg             [2*data_size - 1:0] buffer  [9:0]                                                           ;
    softmax_top_16 #(data_size) softmax_top(
        .axi_clock_i(axi_clock_i)                                                                               ,
        .axi_reset_n_i(axi_reset_n_i)                                                                           ,
        .s_axis_valid_i(s_axis_valid_i)                                                                         ,
        .s_axis_data_i(s_axis_data_i)                                                                           ,
        .s_axis_last_i(s_axis_last_i)                                                                           ,
        .s_axis_ready_o(s_axis_ready_o)                                                                         ,
        .m_axis_ready_i(m_axis_ready_i)                                                                         ,
        .m_axis_valid_o(m_axis_valid_o)                                                                         ,
        .m_axis_data_o(m_axis_data_o)                                                                           ,
        .m_axis_last_o(m_axis_last_o)
    );
    always @(posedge axi_clock_i)
        begin
            if (~axi_reset_n_i)
                buffer[0] = 32'b1100_0000_0101_0011_0001_0010_0110_1110                                         ;
                buffer[1] = 32'b0011_1110_1000_1100_0100_1001_1011_1010                                         ;
                buffer[2] = 32'b1100_0000_0001_0000_0001_0000_0110_0010                                         ;
                buffer[3] = 32'b1011_1111_1100_1111_0011_1011_0110_0100                                         ;
                buffer[4] = 32'b1100_0000_1000_0001_0000_1110_0101_0110                                         ;
                buffer[5] = 32'b1100_0000_1000_0101_0100_0111_1010_1110                                         ;
                buffer[6] = 32'b0100_0000_1001_1000_0100_1001_1011_1010                                         ;
                buffer[7] = 32'b1100_0000_1001_1111_1101_1111_0011_1011                                         ;
                buffer[8] = 32'b0011_1111_1100_1011_1010_0101_1110_0011                                         ;
                buffer[9] = 32'b1100_0000_1000_0111_0011_1011_0110_0100                                         ;
        end
    initial 
    begin
        axi_clock_i = 0                                                                                         ;
        axi_reset_n_i = 0                                                                                       ;
        s_axis_data_i = 0                                                                                       ;
        s_axis_valid_i = 0                                                                                      ;
        valid = 0                                                                                               ;
        #30
        axi_reset_n_i = 1                                                                                       ;
        
        #205
        valid = 1                                                                                               ;
        s_axis_last_i = 0                                                                                       ;
    end
    
    always @(posedge axi_clock_i)
    begin
        if (~axi_reset_n_i)
            s_axis_last_i <= 0                                                                                  ;
        else
            s_axis_last_i <= ~valid ? s_axis_last_i_temp : 0                                                    ;
    end
    
    always @(posedge axi_clock_i)
    begin
        if (~axi_reset_n_i)
            begin
                fisrt_data <= 0                                                                                 ;
                i <= 1                                                                                          ;
                s_axis_valid_i <= 0                                                                             ;
                s_axis_data_i <= 0                                                                              ;
                s_axis_last_i_temp <= 0                                                                         ;
            end
        else
            begin
                if (axi_reset_n_i && ~fisrt_data && i < 10 || fisrt_data && i != 10)
                    s_axis_valid_i <= 1                                                                         ;
                if (i == 10 && s_axis_ready_o)
                begin
                    s_axis_valid_i <= 0                                                                         ;
                    s_axis_last_i_temp <= 0                                                                     ;
                end
                if (axi_reset_n_i && ~fisrt_data && i < 10)
                begin
                    fisrt_data <= 1                                                                             ;
                    s_axis_data_i <= buffer[0]                                                                  ;
                end
                else if (s_axis_ready_o && s_axis_valid_i && i < 10)
                    begin
                        i <= i + 1                                                                              ;
                        s_axis_data_i <= buffer[i]                                                              ;
                    end
                if (i == 9 && s_axis_valid_i)
                        s_axis_last_i_temp <= 1                                                                 ;
            end
    end
    
    always @(posedge axi_clock_i)
    begin
        if (~axi_reset_n_i)
        begin
            m_axis_ready_i <= 0                                                                                 ;
            j <= 0                                                                                              ;
        end
        else
            begin
                if (~m_axis_last_o && m_axis_valid_o && ~m_axis_ready_i || m_axis_last_o && m_axis_valid_o)
                    begin
                    m_axis_ready_i <= 1                                                                         ;
                    j = j + 1                                                                                   ; 
                    end
                if (m_axis_ready_i)
                    m_axis_ready_i <= 0                                                                         ;
            end
    end
    always #5 axi_clock_i = ~axi_clock_i                                                                        ;
endmodule
