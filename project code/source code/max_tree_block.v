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
        
    output      [data_size - 1:0]   data_max_o                                                  , //Xmax
    output reg                      max_tree_done_o
);
    reg         [data_size - 1:0]   data_max_temp                                               ; //temp save data max value
    reg         [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                        ; //buffer save input data
    reg         [7:0]               counter_data                                                ; //count number of input data was saved
    
    integer                         counter_for_loop                                            ; //variable in for loop   

    assign data_max_o = data_max_temp                                                           ; //update value of data max 

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

    //handle data out max
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            data_max_temp <= 0                                                                  ;
        else
            if (counter_data == 1)
                data_max_temp <= input_buffer[counter_data - 1]                                 ;
            else if (counter_data > 1 && counter_data <= number_of_data)
            begin
                //compare sign, if two number have different sign, data max = positive number
                if (input_buffer[counter_data - 1][data_size - 1] != data_max_temp[data_size - 1])
                    if (input_buffer[counter_data - 1][data_size - 1] == 0)
                        data_max_temp <= input_buffer[counter_data - 1]                         ;
                    else
                        data_max_temp <= data_max_temp                                          ;
                // if two number have same sign, compare integer and fraction
                else 
                    if (input_buffer[counter_data - 1][data_size - 1] == 1)
                        if (input_buffer[counter_data - 1][data_size - 2:0] < data_max_temp[data_size - 2:0])
                            data_max_temp <= input_buffer[counter_data - 1]                     ;
                        else
                            data_max_temp <= data_max_temp                                      ;
                    else
                        if (input_buffer[counter_data - 1][data_size - 2:0] > data_max_temp[data_size - 2:0])
                            data_max_temp <= input_buffer[counter_data - 1]                     ;
                        else
                            data_max_temp <= data_max_temp                                      ;
            end
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