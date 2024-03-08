module downscale_exp_tb();
    parameter                           data_size = 32                                                          ;
    parameter                           number_of_data = 10                                                     ;

    reg                                 clock_i                                                                 ;
    reg                                 reset_n_i                                                               ;
    reg                                 start_i                                                                 ;
    reg             [data_size - 1:0]   data_i                                                                  ;
    
    wire                                data_valid_o                                                            ;
    wire            [data_size - 1:0]   data_o                                                                  ;

    downscale_exp_block downscale_exp (
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .start_i(start_i)                                                                                       ,
        .data_i(data_i)                                                                                         ,

        //output
        .data_valid_o(data_valid_o)                                                                             ,
        .data_o(data_o)
    );

endmodule
