module max_tree_block 
#(
    parameter                       data_size = 32                                              , //number of bits of one data
    parameter                       number_of_data = 10                                           //the amount of data corressponds to number of categories
)
(
    input                           clock_i                                                     , //clock source
    input                           reset_n_i                                                   , //reset active low
    input                           start_i                                                     , //start signal
    input       [data_size - 1:0]   data_i                                                      , //data in: x = {X1, X2, X3, ... , Xn}
        
    output reg  [data_size - 1:0]   data_max_o                                                  , //Xmax
    output reg                      max_tree_done_o                     
);

    reg         [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                        ; //buffer save input data
    reg         [7:0]               counter_data                                                ; //count number of input data was saved
    
    integer                         counter_for_loop                                            ; //variable in for loop   

    //input stream: save input data into buffer
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for (counter_for_loop = 0 ; counter_for_loop < number_of_data ; counter_for_loop = counter_for_loop + 1)
                input_buffer[counter_for_loop] <= 0                                             ;
        else    
            if (start_i && counter_data >= 0)
                input_buffer[counter_data] <= data_i                                            ;
    end   
    
    //handle counter_data variable
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data <= 0                                                                   ;
        else
            if(counter_data <= number_of_data && start_i)
                counter_data <= counter_data + 1                                                ;
    end

    //handle data out max
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            data_max_o <= 0                                                                     ;
        else
            if (counter_data > 1 && counter_data <= number_of_data)
                data_max_o <= input_buffer[counter_data - 1] > input_buffer[counter_data - 2] ?
                              input_buffer[counter_data - 1] : input_buffer[counter_data - 2]   ;
    end 
    
    //handle max tree done signal
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            max_tree_done_o <= 0                                                                ;
        else
            if(counter_data == number_of_data)
                max_tree_done_o <= 1                                                            ;     
    end
endmodule