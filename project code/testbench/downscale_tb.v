
module downscale_tb();
    localparam                      data_size = 16                                              ;
    localparam                      number_of_data = 10                                         ;
    reg                             clock_i                                                     ;
    reg                             reset_n_i                                                   ;
    reg                             start_i                                                     ;
    reg  signed   [data_size - 1:0] data_i                                                      ;
    
    wire signed   [data_size:0]     sub_result_o                                                ;    
    downscale_block #(data_size, number_of_data) downscale(
        .clock_i(clock_i)                                                                       ,
        .reset_n_i(reset_n_i)                                                                   ,
        .start_i(start_i)                                                                       ,
        .data_i(data_i)                                                                         ,
        .sub_result_o(sub_result_o)
    );
    
    initial 
    begin
        clock_i = 0                                                                             ;
        reset_n_i = 0                                                                           ;
        start_i = 0                                                                             ;
        data_i = 5                                                                              ;
        
        #30
        reset_n_i = 1                                                                           ;
        #20 
        start_i = 1                                                                             ;
        
        data_i = 16'hA440                                                                       ;
        #10 
        data_i = 16'h2120                                                                       ;
        #10
        data_i = 16'hA440                                                                       ;
        #10
        data_i = 16'h2120                                                                       ;
        #10
        data_i = 16'hA440                                                                       ;
        #10
        data_i = 16'h2120                                                                       ;
        #10
        data_i = 16'hA440                                                                       ;
        #10
        data_i = 16'h2120                                                                       ;
        #10
        data_i = 16'hA440                                                                       ;
        #10
        data_i = 16'h2120                                                                       ;
    end
    always #5 clock_i = ~clock_i                                                                ;
endmodule
