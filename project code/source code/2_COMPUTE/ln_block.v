module ln_block
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [31:0]              ln_data_i                                                               ,  //data from adder block 4 integer, 28 fractional
    input                               ln_data_valid_i                                                         ,
    
    output                              ln_data_valid_o                                                         ,
    output          [31:0]              ln_data_o
);
    reg             [31:0]              fxp_data_i_tem                                                          ;
    reg             [31:0]              fp_data                                                                 ;
    reg                                 fp_data_valid                                                           ;
    reg                                 input_ready                                                             ;
    
    reg                                 ln2_exp_valid                                                           ;
    reg             [31:0]              ln2_exp                                                                 ;

    reg                                 lut_ln_man_valid                                                        ;
    reg             [31:0]              lut_ln_man                                                              ;

    reg             [31:0]              ln_data_o_temp                                                          ;
    reg                                 ln_data_valid_o_temp                                                    ;

    wire            [31:0]              lut_ln_man_wire                                                         ;
    wire            [7:0]               input_lut_man                                                           ;


    assign ln_data_o = ln_data_o_temp                                                                           ;
    assign ln_data_valid_o = ln_data_valid_o_temp                                                               ;
    

    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            begin
                fp_data_valid <= 0                                                                              ;
                fp_data <= {1'b0, 8'b10000010, 23'b0}                                                           ;
                fxp_data_i_tem <= 0                                                                             ;
                input_ready <= 0                                                                                ;
            end
        else
            if (ln_data_valid_i)
            begin
                if (~input_ready)
                begin
                    fxp_data_i_tem <= ln_data_i                                                                 ;
                    input_ready <= 1                                                                            ;
                end
                if (input_ready && ~fp_data_valid)
                begin
                    if (fxp_data_i_tem[31])
                        begin
                            fp_data_valid <= 1                                                                  ;
                            fp_data[30:23] <= fp_data[30:23]                                                    ;
                            fp_data[22:0] <= fxp_data_i_tem[30:8]                                               ;
                        end
                    else
                        begin
                            fxp_data_i_tem <= fxp_data_i_tem << 1                                               ;
                            fp_data[30:23] <= fp_data[30:23] - 1                                                ;
                        end
                end    
            end
    end
    
    //ln(2) * (exp - 127)
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            begin
                ln2_exp_valid <= 0                                                                              ;
                ln2_exp <= 0                                                                                    ;
            end
        else
            begin
                if (fp_data_valid && ~ln2_exp_valid)
                    begin
                        ln2_exp_valid <= 1                                                                      ;
                        if (fp_data[30:23] == 127)
                            ln2_exp <= 32'b0                                                                    ;
                        else if (fp_data[30:23] == 128)
                            ln2_exp <= 32'b0010_1100_0101_1100_1000_0101_1111_1101                              ;
                        else if (fp_data[30:23] == 129)
                            ln2_exp <= 32'b0101_1000_1011_1001_0000_1011_1111_1011                              ;
                        else if (fp_data[30:23] == 130)
                            ln2_exp <= 32'b1000_0101_0001_0101_1001_0001_1111_1001                              ;
                        ln2_exp_valid <= 1                                                                      ;
                    end
            end
    end

    // LUT ln(1,man)
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                lut_ln_man_valid <= 0                                                                           ;
                lut_ln_man <= 0                                                                                 ;
            end
        else
            begin
                if (fp_data_valid && ~lut_ln_man_valid)
                    begin
                        lut_ln_man <= 
                        lut_ln_man_valid <= 1                                                                   ;
                    end
            end
    end
    //ln(x) = ln(2) * (exp - 127) + ln(1,man)
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                ln_data_o_temp <= 0                                                                             ;
                ln_data_valid_o_temp <= 0                                                                       ;
            end
        else
            begin
                if (ln2_exp_valid &&  && ~ln_data_valid_o_temp)
                    begin
                        ln_data_o_temp <= lut_ln_man + ln2_exp                                                  ;
                        ln_data_valid_o_temp <= 1                                                               ;
                    end
            end
    end


endmodule