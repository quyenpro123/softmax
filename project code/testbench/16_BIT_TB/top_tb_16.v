
module top_tb_16();
    localparam                          data_size = 16                                                          ;
    localparam                          number_of_data = 10                                                     ;
    reg                                 clock_i                                                                 ;
    reg                                 reset_n_i                                                               ;
    reg                                 data_valid_i                                                            ;
    reg     signed  [2*data_size - 1:0] data_i                                                                  ;
    wire                                data_valid_o                                                            ;
    wire    signed  [data_size - 1:0]   data_o                                                                  ;
    wire                                done_o                                                                  ;
    top_block_16 #(data_size, number_of_data) top_16(
        .clock_i(clock_i)                                                                                       ,
        .reset_n_i(reset_n_i)                                                                                   ,
        .data_valid_i(data_valid_i)                                                                             ,
        .data_i(data_i)                                                                                         ,
        .exp_2_data_valid_o(data_valid_o)                                                                       ,
        .exp_2_data_o(data_o)                                                                                   ,
        .exp_2_done_o(done_o)
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
        data_i = 32'b0011_1111_0000_0000_0000_0000_0000_0000                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1111_0000_0000_0000_0000_0000_0000                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1110_1001_1110_1011_1000_0101_0001                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1110_1000_0000_0000_0000_0000_0000                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1111_0111_1010_1110_0001_0100_0111                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1111_0010_0011_1101_0111_0000_1010                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1110_0101_0111_0000_1010_0011_1101                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1101_1011_1000_0101_0001_1110_1011                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1110_1010_0011_1101_0111_0000_1010                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
        #10
        
        data_valid_i = 1                                                                                        ;
        data_i = 32'b0011_1111_0111_1000_0101_0001_1110_1011                                                    ;
        #10
        data_valid_i = 0                                                                                        ;
    end
    always #5 clock_i = ~clock_i                                                                                ;
endmodule
