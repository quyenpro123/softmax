module max_tree_block 
#(
    parameter                       data_size = 32                                          , //number of bits of one data
    parameter                       number_of_data = 10                                       //the amount of data corressponds to number of categories  
)
(
    input                           clock_i                                                 , //clock source
    input                           reset_n_i                                               , //reset active low
    input       [data_size - 1:0]   data_i                                                  , //data in: x = {X1, X2, X3, ... , Xn}
        
    output      [data_size - 1:0]   data_max_o                                                //Xmax
);
              
    reg         [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                    ; //buffer save input data
    reg         [data_size - 1:0]   data_max_o_temp                                         ; //temp variable save max value of input array
    reg         [7:0]               counter_data                                            ; //count number of input data was saved
    
    integer                         counter_for_loop                                        ; //variable in for loop   

    localparam                      IDLE = 0                                                ; //states of max tree block
    localparam                      INPUT_STREAM = 1                                        ;
    localparam                      COMPUTE = 2                                             ;
    reg                             compute_done_sig                                        ;

    reg         [1:0]               current_state                                           ;
    reg         [1:0]               next_state                                              ;

    //input stream: save input data into buffer
    always @(posedge clock_i, negedge reset_n_i) 
    begin
        if (~reset_n_i)
            for (counter_for_loop = 0 ; counter_for_loop < number_of_data ; counter_for_loop ++)
                input_buffer[counter_for_loop] <= 0                                         ;
        else    
            if (current_state == INPUT_STREAM)
                input_buffer[counter_data] <= data_i                                        ;
    end   
    
    //handle counter_data variable
    always @(posedge clock_i, negedge reset_n_i) 
    begin
        if (~reset_n_i)
            counter_data <= 0                                                               ;
        else
            if(counter_data < number_of_data)
                counter_data <= counter_data + 1                                            ;
            else if (counter_data == number_of_data && current_state == COMPUTE)
                counter_data <= 0                                                           ;
    end

    //register transfer logic
    always @(posedge clock_i, negedge reset_n_i)
    begin
        if (~reset_n_i)
            current_state <= IDLE                                                           ;
        else
            current_state <= next_state                                                     ;
    end

    //compute next state from current state and input
    always @*
    begin
        case (current_state)
            IDLE:
            begin
                next_state = INPUT_STREAM                                                   ;
            end
            
            INPUT_STREAM:
            begin
                if (counter_data == number_of_data)     
                    next_state = COMPUTE                                                    ;
                else
                    next_state = INPUT_STREAM                                               ;
            end
            
            COMPUTE: 
            begin
                if (compute_done_sig == 1)
                    next_state = IDLE                                                       ;
            end
            default:
            begin
                next_state = IDLE                                                           ;
            end 
        endcase
    end

    //compute output from current state 
    always @*
    begin
        case (current_state)
            IDLE: 
            begin
                data_max_o_temp = 0                                                         ;
            end
            INPUT_STREAM:
            begin
                data_max_o_temp = 0                                                         ;
            end
            COMPUTE:
            begin
                data_max_o_temp = input_buffer[0]                                           ;
                for(counter_for_loop = 1 ; counter_for_loop < number_of_data ; counter_for_loop ++)
                    if (input_buffer[counter_for_loop] > data_max_o_temp)
                        data_max_o_temp = input_buffer[counter_for_loop]                    ;
                    else
                        data_max_o_temp = data_max_o_temp                                   ;
                compute_done_sig = 1                                                        ;
            end
        endcase
    end

endmodule