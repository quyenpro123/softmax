module top_block_16
#(
    parameter                           data_size = 16                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input                               data_valid_i                                                            ,
    input           [2*data_size - 1:0] data_i                                                                  ,

    output          [data_size - 1:0]   exp_2_data_o                                                            ,
    output                              exp_2_data_valid_o                                                      ,
    output                              exp_2_done_o
    
);
    //internal downscale
    wire                                downscale_data_valid_o                                                  ;
    wire            [data_size - 1:0]   downscale_data_o                                                        ;

    wire            [data_size - 1:0]   exp_1_data_o                                                            ;
    wire                                exp_1done_signal_o                                                      ;
    wire                                exp_1data_valid_o                                                       ;
    
    wire            [data_size - 1:0]   adder_data_o                                                            ;
    wire                                adder_data_valid_o                                                      ;

    wire            [data_size - 1:0]   ln_data_o                                                               ;
    wire                                ln_data_valid_o                                                         ;


    wire            [data_size - 1:0]   sub_2_data_o                                                            ;
    wire                                sub_2_data_valid_o                                                      ;
    
    downscale_block_16 #(data_size, number_of_data) downscale(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .downscale_data_valid_i(data_valid_i)                                                                   ,
        .downscale_data_i(data_i)                                                                               ,

        //output
        .downscale_data_valid_o(downscale_data_valid_o)                                                         ,
        .downscale_data_o(downscale_data_o)
    );

    exp_block_16 #(data_size, number_of_data) exp_1(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .exp_data_i(downscale_data_o)                                                                           ,
        .exp_data_valid_i(downscale_data_valid_o)                                                               ,

        //output
        .exp_done_o(exp_1done_signal_o)                                                                         ,
        .exp_data_valid_o(exp_1data_valid_o)                                                                    ,
        .exp_data_o(exp_1_data_o)
    );
    
    adder_block_16 adder_16(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .adder_data_i(exp_1_data_o)                                                                             ,
        .adder_data_valid_i(exp_1data_valid_o)                                                                  ,
        .exp_done_i(exp_1done_signal_o)                                                                         ,
        
        .adder_data_o(adder_data_o)                                                                             ,
        .adder_data_valid_o(adder_data_valid_o) 
    );

    ln_block_16 ln_16(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .ln_data_i(adder_data_o)                                                                                ,
        .ln_data_valid_i(adder_data_valid_o)                                                                    ,

        .ln_data_o(ln_data_o)                                                                                   ,
        .ln_data_valid_o(ln_data_valid_o)
    );

    sub_2_block_16 sub_2_16(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .sub_2_ln_data_i(ln_data_o)                                                                             ,
        .sub_2_ln_data_valid_i(ln_data_valid_o)                                                                 ,
        .sub_2_downscale_data_i(downscale_data_o)                                                               ,
        .sub_2_downscale_data_valid_i(downscale_data_valid_o)                                                   ,

        .sub_2_data_o(sub_2_data_o)                                                                             ,
        .sub_2_data_valid_o(sub_2_data_valid_o)
    );

     exp_block_16 #(data_size, number_of_data) exp_2(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .exp_data_i(sub_2_data_o)                                                                               ,
        .exp_data_valid_i(sub_2_data_valid_o)                                                                   ,

        //output
        .exp_done_o(exp_2_done_o)                                                                               ,
        .exp_data_valid_o(exp_2_data_valid_o)                                                                   ,
        .exp_data_o(exp_2_data_o)
    );
endmodule