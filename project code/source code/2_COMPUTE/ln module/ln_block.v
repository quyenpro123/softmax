module ln_block
#(
    parameter                           data_size = 32
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   ln_data_i                                                               ,  //data from adder block 4 integer, 28 fractional
    input                               ln_data_valid_i                                                         ,
    
    output                              ln_data_valid_o                                                         ,
    output          [data_size - 1:0]   ln_data_o
);
    reg                                 input_ready                                                             ;
    reg             [data_size - 1:0]   fxp_data_i_tem                                                          ;
    reg             [data_size - 1:0]   fp_data                                                                 ;
    reg                                 fp_data_valid                                                           ;
    
    reg                                 ln2_exp_valid                                                           ;
    reg             [data_size - 1:0]   ln2_exp                                                                 ;


    reg             [data_size - 1:0]   ln_data_o_temp                                                          ;
    reg                                 ln_data_valid_o_temp                                                    ;

    wire                                fp_data_valid_wire                                                      ;
    wire            [data_size/2 - 1:0] lut_ln_man_wire                                                         ;
    wire            [data_size/4 - 1:0] lut_ln_man_input_wire                                                   ;
    wire                                lut_ln_man_valid_wire                                                   ;


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
    
    //ln(2) * (exp - 127): 2 integer 30 fraction
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
                        $display("%0d", fp_data[30:23])                                                         ;
                        if (fp_data[30:23] == 8'b01111111)
                            ln2_exp <= 32'b0                                                                    ;
                        else if (fp_data[30:23] == 8'b10000000)
                            ln2_exp <= 32'b0010_1100_0101_1100_1000_0101_1111_1101                              ;
                        else if (fp_data[30:23] == 8'b10000001)
                            ln2_exp <= 32'b0101_1000_1011_1001_0000_1011_1111_1011                              ;
                        else if (fp_data[30:23] == 8'b10000010)
                            ln2_exp <= 32'b1000_0101_0001_0101_1001_0001_1111_1001                              ;
                        ln2_exp_valid <= 1                                                                      ;
                    end
            end
    end

    //LUT LN (1.man)
    assign  lut_ln_man_input_wire = fp_data[22:15]                                                              ;
    assign  fp_data_valid_wire = fp_data_valid                                                                  ;
    lut_ln lut(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .lut_ln_data_i(lut_ln_man_input_wire)                                                                   ,
        .lut_ln_data_valid_i(fp_data_valid_wire)                                                                ,

        .lut_ln_data_o(lut_ln_man_wire)                                                                         ,
        .lut_ln_data_valid_o(lut_ln_man_valid_wire)
    );


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
                if (ln2_exp_valid && lut_ln_man_valid_wire && ~ln_data_valid_o_temp)
                    begin
                        ln_data_o_temp <= {2'b0, lut_ln_man_wire, 14'b0} + ln2_exp                              ;
                        ln_data_valid_o_temp <= 1                                                               ;
                    end
            end
    end
endmodule