module downscale_block_16 
#(
    parameter                           data_size = 16                                                          , //number of bits of one data
    parameter                           number_of_data = 10                                                       //the amount of data corressponds to number of categories
)
(
    input                               clock_i                                                                 , //clock source
    input                               reset_n_i                                                               , //reset active low
    input                               downscale_data_valid_i                                                  ,
    input           [2*data_size - 1:0] downscale_data_i                                                        , //data in: Z = {Z1, Z2, Z3, ... , Zn}

    output  reg                         downscale_data_valid_o                                                  ,         
    output  reg     [data_size - 1:0]   downscale_data_o                                                              //Zi - Zmax
);

    integer                             counter_for_loop                                                        ; //variable in for loop  
    reg             [2*data_size - 1:0] fxp_32_input_data                                                       ; //fxp data in 1.7.8
    reg                                 input_valid_to_save                                                     ;
    reg             [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                                    ; //buffer save fxp input data

    //----------------------------------declare internal variables for max detect block-------------------------
    reg             [data_size - 1:0]   Z_max                                                                   ; //save max value

    reg                                 max_done                                                                ; //signal that max value was found
    reg             [7:0]               counter_data_for_max                                                    ; //count number of input data was saved

    //----------------------------------declare internal variables for sub block--------------------------------
    reg                                 sub_done                                                                ;
    reg             [data_size - 1:0]   sub_result                                                              ;
    reg                                 sub_result_valid                                                        ;
    reg             [7:0]               counter_data_for_sub                                                    ;                    

    //-------------------------------------------FSM variables--------------------------------------------------
    localparam                          IDLE = 0                                                                ;
    localparam                          SUBSTRACTOR = 1                                                         ;
    localparam                          POST_SUB = 2                                                            ;

    reg             [1:0]               downscale_current_state                                                 ;
    reg             [1:0]               downscale_next_state                                                    ;
    //----------------------------------------------------------------------------------------------------------

     always @(posedge clock_i) 
     begin
        if (~reset_n_i)
            begin
                downscale_data_valid_o <= 0                                                                     ;
                downscale_data_o <= 0                                                                           ;
            end   
        else
            begin
                if (counter_data_for_sub < number_of_data)
                    begin
                        downscale_data_valid_o <= sub_result_valid                                              ;
                        downscale_data_o <= sub_result                                                          ;
                    end
                else
                    begin
                        downscale_data_valid_o <= 0                                                             ;
                        downscale_data_o <= 0                                                                   ;
                    end
            end
     end

    //input stream: save fxp_32 (in form 16 bit: 1.7.8) into input buffer
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for (counter_for_loop = 0 ; counter_for_loop < number_of_data ; counter_for_loop = counter_for_loop + 1)
                input_buffer[counter_for_loop] <= 0                                                             ;
        else    
            if (counter_data_for_max >= 0 && max_done == 0 && input_valid_to_save)
                input_buffer[counter_data_for_max] <= fxp_32_input_data[31] ? ~{1'b0, fxp_32_input_data[29:23],
                                                      fxp_32_input_data[22:15]} + 1 : {fxp_32_input_data[31], 
                                                      fxp_32_input_data[29:23], fxp_32_input_data[22:15]}       ;
    end
    //fp_32 to fxp_32
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin    
                input_valid_to_save <= 0                                                                        ;
                fxp_32_input_data <= 0                                                                          ;
            end
        else
            if (downscale_data_valid_i)
                begin
                    fxp_32_input_data[31] <= downscale_data_i[31]                                               ;
                    if (downscale_data_i[30:23] > 127)
                        fxp_32_input_data[30:0] <= {7'b0,1'b1,downscale_data_i[22:0]} 
                                                  << (downscale_data_i[30:23] - 127)                            ;
                    else if (downscale_data_i[30:23] < 127)
                        fxp_32_input_data[30:0] <= {7'b0,1'b1,downscale_data_i[22:0]} 
                                                  >> (127 - downscale_data_i[30:23])                            ;
                    else
                        fxp_32_input_data[30:0] <= {7'b0,1'b1,downscale_data_i[22:0]}                           ;
                    input_valid_to_save <= 1                                                                    ;
                end
            if (input_valid_to_save)
                input_valid_to_save <= 0                                                                        ;
    end
    //handle counter
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_for_max <= 0                                                                           ;
        else 
            if (input_valid_to_save && counter_data_for_max < number_of_data)
                counter_data_for_max <= counter_data_for_max + 1                                                ;
    end
    //find max value
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                Z_max <= 0                                                                                      ;
            end
        else
            if (~max_done)
                if (counter_data_for_max == 1)
                    Z_max <= input_buffer[0]                                                                    ;
                else if (counter_data_for_max > 1)
                begin
                    if (Z_max[data_size - 1] != input_buffer[counter_data_for_max - 1][data_size - 1])
                        if (Z_max[data_size - 1])
                            Z_max <= input_buffer[counter_data_for_max - 1]                                     ;
                        else
                            Z_max <= Z_max                                                                      ;
                    else 
                        if (Z_max[15] && ((~Z_max + 1) > (~(input_buffer[counter_data_for_max - 1]) + 1)))
                            Z_max <= input_buffer[counter_data_for_max - 1]                                     ;
                        else if (~Z_max[15] && (Z_max < input_buffer[counter_data_for_max - 1]))
                            Z_max <= input_buffer[counter_data_for_max - 1]                                     ;
                        else
                            Z_max <= Z_max                                                                      ;
                end
    end

    //handle max done
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            max_done <= 0                                                                                       ;
        else
            if (counter_data_for_max == number_of_data)
                max_done <= 1                                                                                   ;
    end

    //----------------------------------------------------FSM SUBTRACTOR----------------------------------------

    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            downscale_current_state <= IDLE                                                                     ;
        else
            downscale_current_state <= downscale_next_state                                                     ;
    end

    always @* 
    begin
        case (downscale_current_state)
            IDLE:
                if (max_done && ~sub_done)
                    downscale_next_state = SUBSTRACTOR                                                          ;
                else
                    downscale_next_state = IDLE                                                                 ;
            SUBSTRACTOR:
                if (sub_result_valid)
                    downscale_next_state = POST_SUB                                                             ;
                else
                    downscale_next_state = SUBSTRACTOR                                                          ;
            POST_SUB:
                if (sub_done)
                    downscale_next_state = IDLE                                                                 ;
                else
                    downscale_next_state = SUBSTRACTOR                                                          ;
            default: 
                downscale_next_state = IDLE                                                                     ;
        endcase    
    end
    
    always @* 
    begin
        case (downscale_current_state)
            IDLE:
            begin
                if (counter_data_for_sub == number_of_data)
                    sub_done = 1                                                                                ;
                else   
                    sub_done = 0                                                                                ;
                sub_result = 0                                                                                  ;
                sub_result_valid = 0                                                                            ;
            end
            SUBSTRACTOR:
            begin
                if (counter_data_for_sub == number_of_data)
                    sub_done = 1                                                                                ;
                else   
                    sub_done = 0                                                                                ;
                if (Z_max[15] && input_buffer[counter_data_for_sub][15])
                    sub_result = ~{1'b0, ~input_buffer[counter_data_for_sub][14:0] - ~Z_max[14:0]} + 1          ; 
                else if (~Z_max[15] && input_buffer[counter_data_for_max][15])
                    sub_result = ~{1'b0, Z_max[14:0] + ~input_buffer[counter_data_for_sub][14:0] + 1} + 1       ;
                else
                    sub_result = ~{1'b0, Z_max[14:0] - input_buffer[counter_data_for_sub][14:0]} + 1            ;
                sub_result_valid = 1                                                                            ;
            end
            POST_SUB: 
            begin
                if (counter_data_for_sub == number_of_data)
                    sub_done = 1                                                                                ;
                else   
                    sub_done = 0                                                                                ;
                sub_result = 0                                                                                  ;
                sub_result_valid = 0                                                                            ;
            end
            default: 
            begin
                if (counter_data_for_sub == number_of_data)
                    sub_done = 1                                                                                ;
                else   
                    sub_done = 0                                                                                ;
                sub_result = 0                                                                                  ;
                sub_result_valid = 0                                                                            ;
            end
        endcase    
    end

    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_for_sub <= 0                                                                           ;
        else
            if (downscale_current_state == POST_SUB && counter_data_for_sub < number_of_data)
                counter_data_for_sub <= counter_data_for_sub + 1                                                ;
    end
    //-----------------------------------------------------------------------------------------------------------
endmodule
