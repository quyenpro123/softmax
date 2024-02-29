
module max_tree_tb();
    localparam                      data_size = 32                                              ;
    localparam                      number_of_data = 10                                         ;
    reg                             clock_i                                                     ;
    reg                             reset_n_i                                                   ;
    reg                             start_i                                                     ;
    reg         [data_size - 1:0]   data_i                                                      ;
    
    wire        [data_size - 1:0]   data_max_o                                                  ;
    wire                            max_tree_done_o                                             ;
    
    max_tree_block #(data_size, number_of_data) max_tree(
        .clock_i(clock_i)                                                                       ,
        .reset_n_i(reset_n_i)                                                                   ,
        .start_i(start_i)                                                                       ,
        .data_i(data_i)                                                                         ,
        .data_max_o(data_max_o)                                                                 ,
        .max_tree_done_o(max_tree_done_o)                                           
    );
    
    initial 
    begin
        clock_i = 0                                                                             ;
        reset_n_i = 0                                                                           ;
        start_i = 0                                                                             ;
        data_i = 0                                                                              ;
        
        #30
        reset_n_i = 1                                                                           ;
        #20 
        start_i = 1                                                                             ;
        
    end
    always #10 data_i = data_i + 1                                                              ;
    always #5 clock_i = ~clock_i                                                                ;
endmodule
