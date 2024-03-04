module downscale_block 
#(
    parameter                           data_size = 16                                                          , //number of bits of one data
    parameter                           number_of_data = 10                                                       //the amount of data corressponds to number of categories
)
(
    input                               clock_i                                                                 , //clock source
    input                               reset_n_i                                                               , //reset active low
    input                               start_i                                                                 , //start signal
    input   signed  [data_size - 1:0]   data_i                                                                  , //data in: Z = {Z1, Z2, Z3, ... , Zn}
        
    output  signed  [data_size:0]       sub_result_o                                                              //Zi - Zmax
);
    reg     signed  [data_size - 1:0]   Z_max                                                                   ; //save max value
    reg                                 max_done                                                                ; //signal that max value was found
    reg                                 sub_done                                                                ;
    reg     signed  [data_size:0]       temp_sub_result                                                         ;
    reg     signed  [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                                    ; //buffer save input data
    reg             [7:0]               counter_data                                                            ; //count number of input data was saved
    
    integer                             counter_for_loop                                                        ; //variable in for loop   

    assign sub_result_o = temp_sub_result                                                                       ; //update sub_result

    //input stream: save input data into buffer
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for (counter_for_loop = 0 ; counter_for_loop < number_of_data ; counter_for_loop = counter_for_loop + 1)
                input_buffer[counter_for_loop] <= 0                                                             ;
        else    
            if (start_i && counter_data >= 0 && max_done == 0)
                input_buffer[counter_data] <= data_i                                                            ;
    end   
    //------------------------------------------MAX DETECT--------------------------------------
    //handle data max
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            Z_max <= 0                                                                                          ;
        else
            if (max_done == 0)
            begin
                if (counter_data == 1)
                    Z_max <= input_buffer[counter_data - 1]                                                     ;
                else if (counter_data > 1 && counter_data <= number_of_data)
                begin
                    //compare sign, if two number have different sign, data max = positive number
                    if (input_buffer[counter_data - 1][data_size - 1] != Z_max[data_size - 1])
                        if (input_buffer[counter_data - 1][data_size - 1] == 0)
                            Z_max <= input_buffer[counter_data - 1]                                             ;
                        else
                            Z_max <= Z_max                                                                      ;
                    // if two number have same sign, compare integer and fraction
                    else 
                        if (input_buffer[counter_data - 1][data_size - 1] == 1)
                            if (input_buffer[counter_data - 1][data_size - 2:0] < Z_max[data_size - 2:0])
                                Z_max <= input_buffer[counter_data - 1]                                         ;
                            else
                                Z_max <= Z_max                                                                  ;
                        else
                            if (input_buffer[counter_data - 1][data_size - 2:0] > Z_max[data_size - 2:0])
                                Z_max <= input_buffer[counter_data - 1]                                         ;
                            else
                                Z_max <= Z_max                                                                  ;
                end
            end
    end
    
    //handle counter_data variable
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data <= 0                                                                                   ;
        else
            if(counter_data < number_of_data && start_i)
                counter_data <= counter_data + 1                                                                ;
            if(counter_data == number_of_data && sub_done == 0)
                counter_data <= 0                                                                               ;
    end
    
    //handle max tree done signal
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                max_done <= 0                                                                                   ;
                sub_done <= 0                                                                                   ;
            end    
        else
            if(counter_data == number_of_data && max_done == 0)
                max_done <= 1                                                                                   ;
            if (counter_data == number_of_data && max_done == 1)
                sub_done <= 1                                                                                   ;
    end
    //-----------------------------------------------------------------------------------------

    //------------------------------------------SUBSTRACTOR-------------------------------------
    always @(posedge clock_i)
    begin
        if(~reset_n_i)
            temp_sub_result <= 0                                                                                ;
        else
            if (counter_data >= 0 && counter_data < number_of_data &&  max_done == 1 && sub_done == 0)
            begin
                if (input_buffer[counter_data] == Z_max)
                    temp_sub_result <= 0                                                                        ;
                else 
                    begin
                        temp_sub_result = input_buffer[counter_data] - Z_max                                    ;
                    end
            end
    end
    //----------------------------------------------------------------------------------------
endmodule
