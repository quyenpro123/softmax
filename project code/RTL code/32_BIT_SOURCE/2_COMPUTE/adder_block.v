/*
=====================================================================================
=                                                                                   =
=   Author: Hoang Van Quyen - UET - VNU                                             =
=                                                                                   =
=====================================================================================
*/
module adder_block
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   adder_data_i                                                            ,
    input                               adder_data_valid_i                                                      ,
    input                               exp_done_i                                                              ,
    
    output          [data_size - 1:0]   adder_data_o                                                            ,
    output                              adder_data_valid_o
);
    reg             [data_size + 3:0]   adder_data_o_temp                                                       ;
    reg                                 adder_data_valid_o_temp                                                 ;
    assign adder_data_valid_o = adder_data_valid_o_temp                                                         ;
    assign adder_data_o = {adder_data_o_temp[data_size + 3:data_size], adder_data_o_temp[data_size - 1:4]}      ;
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
        begin
            adder_data_o_temp <= 0                                                                              ;
            adder_data_valid_o_temp <= 0                                                                        ;
        end
        else
        begin
            if (adder_data_valid_i && ~exp_done_i)
                adder_data_o_temp = adder_data_o_temp + adder_data_i                                            ;
            if (exp_done_i)
                adder_data_valid_o_temp <= 1                                                                    ;
        end
    end


endmodule