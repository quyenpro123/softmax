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

    output          [data_size - 1:0]   data_o                                                                  ,
    output                              data_valid_o
);
    //internal downscale
    wire                                sub_result_valid                                                        ;
    wire            [data_size - 1:0]   sub_result                                                              ;

    
    downscale_block #(data_size, number_of_data) downscale(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .start_i(start_i)                                                                                       ,
        .data_i(data_i)                                                                                         ,

        //output
        .sub_result_valid_o(sub_result_valid)                                                                   ,
        .sub_result_o(sub_result)
    );

    exp_block #(data_size, number_of_data) exp(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .data_i(sub_result)                                                                                     ,
        .data_valid_i(sub_result_valid)                                                                         ,

        //output
        .exp_valid_o(data_valid_o)                                                                              ,
        .exp_o(data_o)
    );
endmodule