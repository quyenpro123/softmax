module max_tree_block_tb();
    localparam                    data_size = 31                                    ;
    reg                           clock_i                                           ; //clock source
    reg                           reset_n_i                                         ; //reset active low
    reg       [data_size - 1:0]   data_i                                            ; //data in: x = {X1, X2, X3, ... , Xn}
    wire      [data_size - 1:0]   data_max_o                                        ; //Xmax
    
    max_tree_block tb(
        .clock_i(clock_i)                                                           ,
        .reset_n_i(reset_n_i)                                                       ,
        .data_i(data_i)                                                             ,
        .data_max_o(data_max_o)                                                     
    );
    
    initial 
    begin
        clock_i = 1                                                                 ;
        reset_n_i = 0                                                               ;
        data_i = 1.56                                                               ;
        #50             
        reset_n_i = 1                                                               ;
    end
    always @(negedge clock_i)
    begin
        data_i = data_i + 0.5                                                       ;
    end
    always #5 clock_i = ~clock_i                                                    ;
    
endmodule
