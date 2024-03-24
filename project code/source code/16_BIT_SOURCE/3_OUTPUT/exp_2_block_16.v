module exp_2_block_16 
#(
    parameter                           data_size = 16
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   exp_data_i                                                              , // 1.7.8
    input                               exp_data_valid_i                                                        ,
    input                               exp_sub_2_done_i                                                        ,

    //Master AXI4 Stream 
    input                               m_axis_ready_i                                                          ,
    output  reg                         m_axis_last_o                                                           ,
    output  reg                         m_axis_valid_o                                                          ,
    output  reg     [data_size - 1:0]   m_axis_data_o
);
    //----------------------------------------internal variable-------------------------------------------------
    integer                             i                                                                       ;
    reg             [7:0]               counter_data_output                                                     ;
    reg             [7:0]               m_axis_counter_data                                                     ;
    reg             [7:0]               number_of_data                                                          ;
    reg             [data_size - 1:0]   LUT_EXP         [11:0]                                                  ;
    wire            [data_size - 1:0]   exp_data_i_temp                                                         ;
    reg                                 exp_data_valid_o_temp                                                   ;
    reg             [4*data_size - 1:0] exp_data_o_temp                                                         ;
    reg             [2*data_size - 1:0] pre_exp_data_o_temp                                                     ;
    reg             [data_size - 1:0]   output_buffer   [9:0]                                                   ;
    
    
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            for(i = 0 ; i < 10 ; i = i + 1)
                output_buffer[i] <= 0                                                                           ;
        else
            if (exp_data_valid_o_temp)
                output_buffer[counter_data_output] <= pre_exp_data_o_temp[31:16]                                ;
    end
    
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            counter_data_output <= 0                                                                            ;
        else
            if (exp_data_valid_o_temp)
                counter_data_output <= counter_data_output + 1                                                  ;
    end
    
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            number_of_data <= 0                                                                                 ;
        else
            if (exp_sub_2_done_i)
                number_of_data <= counter_data_output                                                           ;
    end
    
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            m_axis_counter_data <= 0                                                                            ;
        else
            if (m_axis_ready_i && m_axis_valid_o && m_axis_counter_data < number_of_data)
                m_axis_counter_data <= m_axis_counter_data + 1                                                  ;
    end
    
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                m_axis_valid_o <= 0                                                                             ;
                m_axis_last_o <= 0                                                                              ;
                m_axis_data_o <= 0                                                                              ;
            end
        else
            begin
                if (m_axis_counter_data < number_of_data)
                    m_axis_valid_o <= 1                                                                         ;
                else
                    m_axis_valid_o = 0                                                                          ;
                if (m_axis_counter_data < number_of_data && m_axis_valid_o)
                    m_axis_data_o <= output_buffer[m_axis_counter_data]                                         ;
                if (m_axis_counter_data == number_of_data - 1)
                    m_axis_last_o <= 1                                                                          ;
                if (m_axis_last_o)
                    m_axis_last_o <= 0                                                                          ;
            end
    end

    assign exp_data_i_temp = ~exp_data_i + 1                                                                    ;
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
        begin
            //fixed point 0 signed, 0 integer, 32 fraction
            LUT_EXP[11] <= 32'b0000_0000_0001_0101                                                              ; //e^-(2^3)
            LUT_EXP[10] <= 16'b0000_0100_1011_0000                                                              ; //e^-(2^2)
            LUT_EXP[9]  <= 16'b0010_0010_1010_0101                                                              ; //e^-(2^1)
            LUT_EXP[8]  <= 16'b0101_1110_0010_1101                                                              ; //e^-(2^0)
            LUT_EXP[7]  <= 16'b1001_1011_0100_0101                                                              ; //e^-(2^-1)
            LUT_EXP[6]  <= 16'b1100_0111_0101_1111                                                              ; //e^-(2^-2)
            LUT_EXP[5]  <= 16'b1110_0001_1110_1011                                                              ; //e^-(2^-3)
            LUT_EXP[4]  <= 16'b1111_0000_0111_1101                                                              ; //e^-(2^-4)
            LUT_EXP[3]  <= 16'b1111_1000_0001_1111                                                              ; //e^-(2^-5)
            LUT_EXP[2]  <= 16'b1111_1100_0000_0111                                                              ; //e^-(2^-6)
            LUT_EXP[1]  <= 16'b1111_1110_0000_0001                                                              ; //e^-(2^-7)
            LUT_EXP[0]  <= 16'b1111_1111_0000_0000                                                              ; //e^-(2^-8)
        end
    end

    always @*
    begin
        if (exp_data_valid_i)
        begin
            if (exp_data_i_temp == 0)
            begin
                exp_data_o_temp = 0                                                                             ;
                pre_exp_data_o_temp = 32'hffffffff                                                              ;
            end
            else
            begin
                if (exp_data_i_temp[14:12])
                begin
                    exp_data_o_temp = 0                                                                         ;
                    pre_exp_data_o_temp = 0                                                                     ;
                end
                else
                begin
                    exp_data_o_temp = exp_data_i_temp[11] ? (exp_data_i_temp[10] ? {LUT_EXP[11], 16'b0} * {LUT_EXP[10], 16'b0} : {LUT_EXP[11], 48'b0})
                                : (exp_data_i_temp[10] ? {LUT_EXP[10], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[9] ? pre_exp_data_o_temp * {LUT_EXP[9], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[9] ? {LUT_EXP[9], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[8] ? pre_exp_data_o_temp * {LUT_EXP[8], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[8] ? {LUT_EXP[8], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[7] ? pre_exp_data_o_temp * {LUT_EXP[7], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[7] ? {LUT_EXP[7], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[6] ? pre_exp_data_o_temp * {LUT_EXP[6], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[6] ? {LUT_EXP[6], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[5] ? pre_exp_data_o_temp * {LUT_EXP[5], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[5] ? {LUT_EXP[5], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[4] ? pre_exp_data_o_temp * {LUT_EXP[4], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[4] ? {LUT_EXP[4], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[3] ? pre_exp_data_o_temp * {LUT_EXP[3], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[3] ? {LUT_EXP[3], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[2] ? pre_exp_data_o_temp * {LUT_EXP[2], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[2] ? {LUT_EXP[2], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[1] ? pre_exp_data_o_temp * {LUT_EXP[1], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[1] ? {LUT_EXP[1], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                    
                    exp_data_o_temp = pre_exp_data_o_temp ? (exp_data_i_temp[0] ? pre_exp_data_o_temp * {LUT_EXP[0], 16'b0} : {pre_exp_data_o_temp, 32'b0})
                                : (exp_data_i_temp[0] ? {LUT_EXP[0], 48'b0} : 64'b0)                            ;
                    pre_exp_data_o_temp = exp_data_o_temp[63:32]                                                ;
                end
            end
            exp_data_valid_o_temp = 1                                                                           ;
        end
        else
        begin
            exp_data_o_temp = 0                                                                                 ;
            pre_exp_data_o_temp = 0                                                                             ;
            exp_data_valid_o_temp = 0                                                                           ;
        end
    end

endmodule