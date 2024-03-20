
module down_scale_tb();
    localparam                          data_size = 16                                                          ;
    localparam                          number_of_data = 10                                                     ;
    reg                                 clock_i                                                                 ;
    reg                                 reset_n_i                                                               ;
    reg                                 data_valid_i                                                            ;
    reg     signed  [2*data_size - 1:0] data_i                                                                  ;
    wire                                sub_result_valid_o                                                      ;
    wire    signed  [data_size - 1:0]   sub_result_o                                                            ;
    downscale_block_16 #(data_size, number_of_data) downscale(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .downscale_data_valid_i(data_valid_i)                                                                   ,
        .downscale_data_i(data_i)                                                                               ,
        .downscale_data_valid_o(sub_result_valid_o)                                                             ,
        .downscale_data_o(sub_result_o)
    );
    
    initial 
    begin
        clock_i = 0                                                                                             ;
        reset_n_i = 0                                                                                           ;
        data_i = 0                                                                                              ;
        data_valid_i = 0                                                                                        ;
        #30
        reset_n_i = 1                                                                                           ;
        #25 
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'hC05060D2                                                                                   ; // -3.2559
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'h40A5D0A4                                                                                   ; // 5.1817
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'hBF3A1674                                                                                   ; // -0.7269
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'h401D24F6                                                                                   ; // 2.45538
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'hBE3BD70A                                                                                   ; // -0.1834
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'h3F461F7D                                                                                   ; // 0.7739
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'hC0350DF4                                                                                   ; // -2.8289
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'h40BEEE67                                                                                   ; // 5.9666
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'hC0A6D2C4                                                                                   ; // -5.21322
        #10
        data_valid_i = 0                                                                                        ;
	    #10

        data_valid_i = 1                                                                                        ;
        data_i = 32'h3F9DF3B6                                                                                   ; // 1.233999
        #10
        data_valid_i = 0                                                                                        ;
    end
    always #5 clock_i = ~clock_i                                                                                ;
endmodule
