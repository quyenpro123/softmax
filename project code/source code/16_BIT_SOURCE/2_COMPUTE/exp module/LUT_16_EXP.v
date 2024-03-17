module lut_exp
#(
    parameter                           data_size = 32
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   lut_exp_data_i                                                          ,
    input                               lut_exp_data_valid_i                                                    ,

    output                              lut_exp_data_valid_o                                                    ,
    output          [data_size - 1:0]   lut_exp_data_o
);
    reg             [data_size - 1:0]   LUT_EXP         [19:0]                                                  ;
    reg                                 output_valid_o_temp                                                     ;
    reg             [2*data_size - 1:0] data_o_temp                                                             ;
    reg             [data_size - 1:0]   pre_data_o_temp                                                         ;
    
    
    assign lut_exp_data_valid_o = output_valid_o_temp                                                           ;
    assign lut_exp_data_o = pre_data_o_temp                                                                     ;
    
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
        begin
            //fixed point 0 signed, 0 integer, 32 fraction
            LUT_EXP[19] <= 16'b0000_0000_0001_0101                                                              ; //e^-(2^3)
            LUT_EXP[18] <= 16'b0000_0100_1011_0000                                                              ; //e^-(2^2)
            LUT_EXP[17] <= 16'b0010_0010_1010_0101                                                              ; //e^-(2^1)
            LUT_EXP[16] <= 16'b0101_1110_0010_1101                                                              ; //e^-(2^0)
            LUT_EXP[15] <= 16'b1001_1011_0100_0101                                                              ; //e^-(2^-1)
            LUT_EXP[14] <= 16'b1100_0111_0101_1111                                                              ; //e^-(2^-2)
            LUT_EXP[13] <= 16'b1110_0001_1110_1011                                                              ; //e^-(2^-3)
            LUT_EXP[12] <= 16'b1111_0000_0111_1101                                                              ; //e^-(2^-4)
            LUT_EXP[11] <= 16'b1111_1000_0001_1111                                                              ; //e^-(2^-5)
            LUT_EXP[10] <= 16'b1111_1100_0000_0111                                                              ; //e^-(2^-6)
            LUT_EXP[9]  <= 16'b1111_1110_0000_0001                                                              ; //e^-(2^-7)
            LUT_EXP[8]  <= 16'b1111_1111_0000_0000                                                              ; //e^-(2^-8)
            LUT_EXP[7]  <= 16'b1111_1111_1000_0000                                                              ; //e^-(2^-9)
            LUT_EXP[6]  <= 16'b1111_1111_1100_0000                                                              ; //e^-(2^-10)
            LUT_EXP[5]  <= 16'b1111_1111_1110_0000                                                              ; //e^-(2^-11)
            LUT_EXP[4]  <= 16'b1111_1111_1111_0000                                                              ; //e^-(2^-12)
            LUT_EXP[3]  <= 16'b1111_1111_1111_1000                                                              ; //e^-(2^-13)
            LUT_EXP[2]  <= 16'b1111_1111_1111_1100                                                              ; //e^-(2^-14)
            LUT_EXP[1]  <= 16'b1111_1111_1111_1110                                                              ; //e^-(2^-15)
            LUT_EXP[0]  <= 16'b1111_1111_1111_1111                                                              ; //e^-(2^-16)
        end
    end

    always @*
    begin
        if (lut_exp_data_valid_i)
        begin
            if (lut_exp_data_i == 0)
            begin
                data_o_temp = 0                                                                                 ;
                pre_data_o_temp = 32'hffffffff                                                                  ;
            end
            else
            begin
                if (lut_exp_data_i[30:20])
                begin
                    data_o_temp = 0                                                                             ;
                    pre_data_o_temp = 0                                                                         ;
                end
                else
                begin
                    data_o_temp = lut_exp_data_i[19] ? (lut_exp_data_i[18] ? {LUT_EXP[19], 16'b0} * {LUT_EXP[18], 16'b0} : {LUT_EXP[19], 48'b0})
                                : (lut_exp_data_i[18] ? {LUT_EXP[18], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[17] ? pre_data_o_temp * {LUT_EXP[17], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[17] ? {LUT_EXP[17], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[16] ? pre_data_o_temp * {LUT_EXP[16], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[16] ? {LUT_EXP[16], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[15] ? pre_data_o_temp * {LUT_EXP[15], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[15] ? {LUT_EXP[15], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[14] ? pre_data_o_temp * {LUT_EXP[14], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[14] ? {LUT_EXP[14], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[13] ? pre_data_o_temp * {LUT_EXP[13], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[13] ? {LUT_EXP[13], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[12] ? pre_data_o_temp * {LUT_EXP[12], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[12] ? {LUT_EXP[12], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[11] ? pre_data_o_temp * {LUT_EXP[11], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[11] ? {LUT_EXP[11], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[10] ? pre_data_o_temp * {LUT_EXP[10], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[10] ? {LUT_EXP[10], 48'b0} : 64'b0)                           ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[9] ? pre_data_o_temp * {LUT_EXP[9], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[9] ? {LUT_EXP[9], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[8] ? pre_data_o_temp * {LUT_EXP[8], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[8] ? {LUT_EXP[8], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[7] ? pre_data_o_temp * {LUT_EXP[7], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[7] ? {LUT_EXP[7], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[6] ? pre_data_o_temp * {LUT_EXP[6], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[6] ? {LUT_EXP[6], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[5] ? pre_data_o_temp * {LUT_EXP[5], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[5] ? {LUT_EXP[5], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[4] ? pre_data_o_temp * {LUT_EXP[4], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[4] ? {LUT_EXP[4], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[3] ? pre_data_o_temp * {LUT_EXP[3], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[3] ? {LUT_EXP[3], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[2] ? pre_data_o_temp * {LUT_EXP[2], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[2] ? {LUT_EXP[2], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[1] ? pre_data_o_temp * {LUT_EXP[1], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[1] ? {LUT_EXP[1], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
            
                    data_o_temp = pre_data_o_temp ? (lut_exp_data_i[0] ? pre_data_o_temp * {LUT_EXP[0], 16'b0} : {pre_data_o_temp, 32'b0})
                                : (lut_exp_data_i[0] ? {LUT_EXP[0], 48'b0} : 64'b0)                             ;
                    pre_data_o_temp = data_o_temp[63:32]                                                        ;
                end
            end
            output_valid_o_temp = 1                                                                             ;
        end
        else
        begin
            data_o_temp = 0                                                                                     ;
            pre_data_o_temp = 0                                                                                 ;
            output_valid_o_temp = 0                                                                             ;
        end
    end
endmodule
