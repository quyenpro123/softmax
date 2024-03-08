module fxp_mul(
    input           [31:0]          a_i                                                 ,
    input           [31:0]          b_i                                                 ,

    output          [31:0]          c_o        
);
    reg             [64:0]          c_o_temp                                            ;
    
    assign c_o = c_o_temp                                                               ;
    //
endmodule