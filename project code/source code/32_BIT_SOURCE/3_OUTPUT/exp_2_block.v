module exp_2_block 
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   exp_2_data_i                                                            , //fixed point 1 sign 15 integer 16 fraction
    input                               exp_2_data_valid_i                                                      ,

    output          [data_size - 1:0]   exp_2_data_o                                                            , //fixed point 0 sign 32 fraction
    output                              exp_2_data_valid_o                                  
);
    reg             [data_size - 1:0]   exp_2_data_o_temp                                                       ;
    reg                                 exp_2_data_valid_o_temp                                                 ;

    wire            [data_size - 1:0]   exp_2_data_o_wire                                                       ;
    wire                                exp_2_data_valid_o_wire                                                 ;
    
    assign exp_2_data_o = exp_2_data_o_temp                                                                     ;
    assign exp_2_data_valid_o = exp_2_data_valid_o_temp                                                         ;    
    
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                exp_2_data_o_temp <= 0                                                                          ;
                exp_2_data_valid_o_temp <= 0                                                                    ;
            end
        else
            begin
                exp_2_data_o_temp <= exp_2_data_o_wire                                                          ;
                exp_2_data_valid_o_temp <= exp_2_data_valid_o_wire                                              ;
            end                                                                          
    end

    lut_exp lut(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .lut_exp_data_i(exp_2_data_i)                                                                           ,
        .lut_exp_data_valid_i(exp_2_data_valid_i)                                                               ,
        
        .lut_exp_data_valid_o(exp_2_data_valid_o_wire)                                                          ,
        .lut_exp_data_o(exp_2_data_o_wire)
    );

endmodule