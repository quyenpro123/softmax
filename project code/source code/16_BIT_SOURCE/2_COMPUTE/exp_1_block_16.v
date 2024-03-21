module exp_block_16 
#(
    parameter                           data_size = 16                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   exp_data_i                                                              , // 1.7.8
    input                               exp_data_valid_i                                                        ,

    output  reg                         exp_done_o                                                              ,
    output  reg                         exp_data_valid_o                                                        ,
    output  reg     [data_size - 1:0]   exp_data_o
);
    //----------------------------------------internal variable-------------------------------------------------
    reg             [data_size - 1:0]   LUT_EXP         [10:0]                                                  ;
    wire            [data_size - 1:0]   exp_data_i_temp                                                         ;
    reg                                 exp_data_valid_o_temp                                                   ;
    reg             [4*data_size - 1:0] exp_data_o_temp                                                         ;
    reg             [2*data_size - 1:0] pre_exp_data_o_temp                                                     ;
    reg             [7:0]               counter_for_done_exp                                                    ;

    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_for_done_exp <= 0                                                                           ;
        else
            if (exp_data_valid_o_temp && counter_for_done_exp < number_of_data)
                counter_for_done_exp <= counter_for_done_exp + 1                                                ;
    end
    
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                exp_data_valid_o <= 0                                                                           ;
                exp_done_o <= 0                                                                                 ;
                exp_data_o <= 0                                                                                 ;
            end
        else
            begin
                exp_data_valid_o <= exp_data_valid_o_temp                                                       ;
                exp_data_o <= pre_exp_data_o_temp[31:16]                                                        ;
                if (counter_for_done_exp == number_of_data)
                    exp_done_o <= 1                                                                             ;
            end
    end

    assign exp_data_i_temp = ~exp_data_i + 1                                                                    ;
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
        begin
            //fixed point 0 signed, 0 integer, 32 fraction
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
                if (exp_data_i_temp[14:11])
                begin
                    exp_data_o_temp = 0                                                                         ;
                    pre_exp_data_o_temp = 0                                                                     ;
                end
                else
                begin
                    exp_data_o_temp = exp_data_i_temp[10] ? (exp_data_i_temp[9] ? {LUT_EXP[10], 16'b0} * {LUT_EXP[9], 16'b0} : {LUT_EXP[10], 48'b0})
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