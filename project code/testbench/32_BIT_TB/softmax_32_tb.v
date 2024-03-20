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
        
        data_i = 32'b0100_0000_1010_1011_0000_1010_0011_1101                                                    ;
        #10
        //17.286
        data_i = 32'b0100_0001_1000_1010_0100_1001_1011_1010                                                    ;
        #10
        //13.549
        data_i = 32'b0100_0001_0101_1000_1100_1000_1011_0100                                                    ;
        #10
        //20.116
        data_i = 32'b0100_0001_1010_0000_1110_1101_1001_0001                                                    ;
        #10
        //5.687
        data_i = 32'b0100_0000_1011_0101_1111_1011_1110_0111                                                    ;
        #10
        //7.954
        data_i = 32'b0100_0000_1111_1110_1000_0111_0010_1011                                                    ;
        #10
        //8.209
        data_i = 32'b0100_0001_0000_0011_0101_1000_0001_0000                                                    ;
        #10
        //14.418
        data_i = 32'b0100_0001_0110_0110_1011_0000_0010_0000                                                    ;
        #10
        //16.509
        data_i = 32'b0100_0001_1000_0100_0001_0010_0110_1110                                                    ;
        #10
        //0.153
        data_i = 32'b0011_1110_0001_1100_1010_1100_0000_1000                                                    ;
    end
    always #5 clock_i = ~clock_i                                                                                ;
endmodule
