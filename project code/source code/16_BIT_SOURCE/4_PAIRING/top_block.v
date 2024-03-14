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

    output          [data_size - 1:0]   exp_2_data_o                                                            ,
    output                              exp_2_data_valid_o
);
    //internal downscale
    wire                                downscale_data_valid_o                                                  ;
    wire            [data_size - 1:0]   downscale_data_o                                                        ;

    wire            [data_size - 1:0]   exp_data_o                                                              ;
    wire                                exp_done_signal_o                                                       ;
    wire                                exp_data_valid_o                                                        ;
    
    wire            [data_size - 1:0]   adder_data_o                                                            ;
    wire                                adder_data_valid_o                                                      ;

    wire            [data_size - 1:0]   ln_data_o                                                               ;
    wire                                ln_data_valid_o                                                         ;


    wire            [data_size - 1:0]   sub_2_data_o                                                            ;
    wire                                sub_2_data_valid_o                                                      ;
    
    downscale_block #(data_size, number_of_data) downscale(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .start_i(start_i)                                                                                       ,
        .downscale_data_i(data_i)                                                                               ,

        //output
        .downscale_data_valid_o(downscale_data_valid_o)                                                         ,
        .downscale_data_o(downscale_data_o)
    );

    exp_block #(data_size, number_of_data) exp(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .exp_data_i(downscale_data_o)                                                                           ,
        .exp_data_valid_i(downscale_data_valid_o)                                                               ,

        //output
        .exp_done_o(exp_done_signal_o)                                                                          ,
        .exp_data_valid_o(exp_data_valid_o)                                                                     ,
        .exp_data_o(exp_data_o)
    );
    
    adder_block adder(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .adder_data_i(exp_data_o)                                                                               ,
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

    subtractor_2_block sub_2(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .sub_2_ln_data_i(ln_data_o)                                                                             ,
        .sub_2_ln_data_valid_i(ln_data_valid_o)                                                                 ,
        .sub_2_downscale_data_i(downscale_data_o)                                                               ,
        .sub_2_downscale_data_valid_i(downscale_data_valid_o)                                                   ,

        .sub_2_data_o(sub_2_data_o)                                                                             ,
        .sub_2_data_valid_o(sub_2_data_valid_o)
    );

    exp_2_block exp2(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .exp_2_data_i(sub_2_data_o)                                                                             ,
        .exp_2_data_valid_i(sub_2_data_valid_o)                                                                 ,

        //output
        .exp_2_data_valid_o(exp_2_data_valid_o)                                                                 ,
        .exp_2_data_o(exp_2_data_o)
    )
endmodule