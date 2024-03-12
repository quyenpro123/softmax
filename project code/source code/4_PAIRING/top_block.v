module top_block
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input                               start_i                                                                 ,
    input           [data_size - 1:0]   data_i                                                                  ,

    output          [data_size - 1:0]   ln_data_o                                                               ,
    output                              ln_data_valid_o
);
    //internal downscale
    wire                                sub_result_valid                                                        ;
    wire            [data_size - 1:0]   sub_result                                                              ;

    wire            [data_size - 1:0]   data_exp_o                                                              ;
    wire                                exp_done_signal_o                                                       ;
    wire                                exp_data_valid_o                                                        ;
    
    wire          [data_size - 1:0]     adder_data_o                                                            ;
    wire                                adder_data_valid_o                                                      ;
    
    downscale_block #(data_size, number_of_data) downscale(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .start_i(start_i)                                                                                       ,
        .downscale_data_i(data_i)                                                                               ,

        //output
        .sub_result_valid_o(sub_result_valid)                                                                   ,
        .sub_result_o(sub_result)
    );

    exp_block #(data_size, number_of_data) exp(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .exp_data_i(sub_result)                                                                                 ,
        .exp_data_valid_i(sub_result_valid)                                                                     ,

        //output
        .exp_done_o(exp_done_signal_o)                                                                          ,
        .exp_data_valid_o(exp_data_valid_o)                                                                     ,
        .exp_data_o(data_exp_o)
    );
    
    adder_block adder(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .adder_data_i(data_exp_o)                                                                               ,
        .adder_data_valid_i(exp_data_valid_o)                                                                   ,
        .exp_done_i(exp_done_signal_o)                                                                          ,
        
        .adder_data_o(adder_data_o)                                                                             ,
        .adder_data_valid_o(adder_data_valid_o) 
    );

    ln_block ln(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .ln_data_i(adder_data_o)                                                                                ,
        .ln_data_valid_i(adder_data_valid_o)                                                                    ,

        .ln_data_o(ln_data_o)                                                                                   ,
        .ln_data_valid_o(ln_data_valid_o)
    );
endmodule