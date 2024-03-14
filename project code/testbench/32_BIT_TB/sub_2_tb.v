module sub_2_tb();
    reg                                 clock_i                                                                 ;
    reg                                 reset_n_i                                                               ;

    reg                                 sub_data_valid                                                          ;
    reg                 [31:0]          sub_data                                                                ;

    reg                                 ln_data_valid                                                           ;
    reg                 [31:0]          ln_data                                                                 ;

    wire                                sub_2_data                                                              ;
    wire                [31:0]          sub_2_data_valid                                                        ;

    subtractor_2_block sub2(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,

        .sub_2_ln_data_i(ln_data)                                                                               ,
        .sub_2_data_valid_i(ln_data_valid)                                                                      ,

        .sub_2_downscale_data_i(sub_data)                                                                       ,
        .sub_2_downscale_data_valid_i(sub_data_valid)                                                           ,

        .sub_2_data_valid_o(sub_2_data_valid)                                                                   ,
        .sub_2_data_o(sub_2_data)
    );
    initial
    begin
        clock_i = 0                                                                                             ;
        reset_n_i = 0                                                                                           ;
        sub_data_valid = 0                                                                                      ;
        sub_data = 0                                                                                            ;
        ln_data_valid = 0                                                                                       ;
        ln_data = 0                                                                                             ;
        #20
        reset_n_i = 1                                                                                           ;
        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC0A6D2C4                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC0A5D0A4                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hBF9DF3B6                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        sub_data_valid = 1                                                                                      ;
        sub_data = 32'hC05060D2                                                                                 ;
        #10
        sub_data_valid = 0                                                                                      ;

        #20
        ln_data_valid = 1                                                                                       ;
    end

    always #5 clock_i = ~clock_i                                                                                ;
endmodule
