module softmax_32_tb();
    parameter                           data_size = 32                                                          ;
    parameter                           number_of_data = 10                                                     ;

    reg                                 clock_i                                                                 ;
    reg                                 reset_n_i                                                               ;
    reg                                 start_i                                                                 ;
    reg             [data_size - 1:0]   data_i                                                                  ;
    
    wire                                exp_2_data_valid_o                                                      ;
    wire            [data_size - 1:0]   exp_2_data_o                                                            ;
    top_block top(
        //input
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .start_i(start_i)                                                                                       ,
        .data_i(data_i)                                                                                         ,

        //output
        .exp_2_data_valid_o(exp_2_data_valid_o)                                                                 ,
        .exp_2_data_o(exp_2_data_o)
    );

    initial 
    begin
        clock_i = 0                                                                                             ;
        reset_n_i = 0                                                                                           ;
        start_i = 0                                                                                             ;
        data_i = 0                                                                                              ;
        
        #30
        reset_n_i = 1                                                                                           ;
        #20 
        start_i = 1                                                                                             ;
        
        data_i = 32'hC05060D2                                                                                   ; // -3.2559
        #10 
        data_i = 32'h40A5D0A4                                                                                   ; // 5.1817
        #10
        data_i = 32'hBF3A1674                                                                                   ; // -0.7269
        #10
        data_i = 32'h401D24F6                                                                                   ; // 2.45538
        #10
        data_i = 32'hBE3BD70A                                                                                   ; // -0.1834
        #10
        data_i = 32'h3F461F7D                                                                                   ; // 0.7739
        #10
        data_i = 32'hC0350DF4                                                                                   ; // -2.8289
        #10
        data_i = 32'h40BEEE67                                                                                   ; // 5.9666
        #10
        data_i = 32'hC0A6D2C4                                                                                   ; // -5.21322
        #10
        data_i = 32'h3F9DF3B6                                                                                   ; // 1.233999


    end
    always #5 clock_i = ~clock_i                                                                                ;
endmodule
