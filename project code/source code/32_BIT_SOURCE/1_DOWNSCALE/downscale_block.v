module downscale_block 
#(
    parameter                           data_size = 32                                                          , //number of bits of one data
    parameter                           number_of_data = 10                                                       //the amount of data corressponds to number of categories
)
(
    input                               clock_i                                                                 , //clock source
    input                               reset_n_i                                                               , //reset active low
    input                               start_i                                                                 , //start signal
    input           [data_size - 1:0]   downscale_data_i                                                        , //data in: Z = {Z1, Z2, Z3, ... , Zn}

    output                              downscale_data_valid_o                                                  ,         
    output          [data_size - 1:0]   downscale_data_o                                                              //Zi - Zmax
);

    integer                             counter_for_loop                                                        ; //variable in for loop  
    reg             [data_size - 1:0]   input_buffer  [number_of_data - 1:0]                                    ; //buffer save input data

    //----------------------------------declare internal variables for max detect block-------------------------
    reg             [data_size - 1:0]   Z_max                                                                   ; //save max value
    reg                                 max_done                                                                ; //signal that max value was found
    reg             [7:0]               counter_data_for_max                                                    ; //count number of input data was saved

    //----------------------------------declare internal variables for sub block--------------------------------
    reg                                 sub_done                                                                ;
    reg             [7:0]               counter_data_for_sub                                                    ;

    reg                                 sub_result_sign                                                         ;
    reg             [7:0]               sub_result_exp                                                          ;
    reg             [24:0]              sub_result_man                                                          ;
    
    reg                                 sub_data_valid_o_temp                                                   ;

    reg                                 sub_result_sign_temp                                                    ;
    reg             [7:0]               sub_result_exp_temp                                                     ;
    reg             [24:0]              sub_result_man_temp                                                     ;
    reg                                 sub_result_valid_temp                                                   ;
    
    reg                                 Z_i_sign                                                                ;
    reg             [7:0]               Z_i_exp                                                                 ;
    reg             [22:0]              Z_i_man                                                                 ;
    reg             [23:0]              Z_i_man_temp                                                            ;

    wire                                Z_max_sign                                                              ;
    wire            [7:0]               Z_max_exp                                                               ;
    wire            [22:0]              Z_max_man                                                               ;
    reg             [23:0]              Z_max_man_temp                                                          ;

    reg             [8:0]               exp_sub                                                                 ;
    reg             [7:0]               abs_exp_diff                                                            ;


    //-------------------------------------------FSM variables--------------------------------------------------
    localparam                          IDLE = 0                                                                ;
    localparam                          START = 1                                                               ;
    localparam                          SHIFT = 2                                                               ;

    reg             [1:0]               sub_current_state                                                       ;
    reg             [1:0]               sub_next_state                                                          ;
    //----------------------------------------------------------------------------------------------------------

    //input stream: save input data into buffer
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for (counter_for_loop = 0 ; counter_for_loop < number_of_data ; counter_for_loop = counter_for_loop + 1)
                input_buffer[counter_for_loop] <= 0                                                             ;
        else    
            if (start_i && counter_data_for_max >= 0 && max_done == 0)
                input_buffer[counter_data_for_max] <= downscale_data_i                                          ;
    end   
    //----------------------------------------------------MAX DETECT--------------------------------------------
    //handle data max
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            Z_max <= 0                                                                                          ;
        else
            if (max_done == 0)
            begin
                if (counter_data_for_max == 1)
                    Z_max <= input_buffer[counter_data_for_max - 1]                                             ;
                else if (counter_data_for_max > 1 && counter_data_for_max <= number_of_data)
                begin
                    //compare sign, if two number have different sign, data max = positive number
                    if (input_buffer[counter_data_for_max - 1][data_size - 1] != Z_max[data_size - 1])
                        if (input_buffer[counter_data_for_max - 1][data_size - 1] == 0)
                            Z_max <= input_buffer[counter_data_for_max - 1]                                     ;
                        else
                            Z_max <= Z_max                                                                      ;
                    // if two number have same sign, compare integer and fraction
                    else 
                        if (input_buffer[counter_data_for_max - 1][data_size - 1] == 1)
                            if (input_buffer[counter_data_for_max - 1][data_size - 2:0] < Z_max[data_size - 2:0])
                                Z_max <= input_buffer[counter_data_for_max - 1]                                 ;
                            else
                                Z_max <= Z_max                                                                  ;
                        else
                            if (input_buffer[counter_data_for_max - 1][data_size - 2:0] > Z_max[data_size - 2:0])
                                Z_max <= input_buffer[counter_data_for_max - 1]                                 ;
                            else
                                Z_max <= Z_max                                                                  ;
                end
            end
    end
    
    //handle counter_data_for_max variable
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_for_max <= 0                                                                           ;
        else
            if(counter_data_for_max < number_of_data && start_i && max_done == 0)
                counter_data_for_max <= counter_data_for_max + 1                                                ;
    end
    
    //handle max tree done signal
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                max_done <= 0                                                                                   ;
            end    
        else
            if(counter_data_for_max == number_of_data && max_done == 0)
                max_done <= 1                                                                                   ;
    end
    //----------------------------------------------------------------------------------------------------------

    //------------------------------------------SUBSTRACTOR-----------------------------------------------------

    assign Z_max_sign = Z_max[31]                                                                               ;
    assign Z_max_exp = Z_max[30:23]                                                                             ;
    assign Z_max_man = Z_max[22:0]                                                                              ;
    assign downscale_data_o = {sub_result_sign, sub_result_exp, 
                          sub_result_man[24] ? sub_result_man[23:1] : sub_result_man[22:0]}                     ;
    assign downscale_data_valid_o = sub_data_valid_o_temp                                                       ; 

    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                sub_data_valid_o_temp <= 0                                                                      ;
                sub_result_sign <= 0                                                                            ;
                sub_result_exp <= 0                                                                             ;
                sub_result_man <= 0                                                                             ;
            end
        else
            begin
                sub_data_valid_o_temp <= sub_result_valid_temp                                                  ;
                sub_result_sign <= sub_result_sign_temp                                                         ;
                sub_result_exp <= sub_result_exp_temp                                                           ;
                sub_result_man <= sub_result_man_temp                                                           ;
            end
    end
    //transfer logic
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            sub_current_state <= IDLE                                                                           ;
        else
            sub_current_state <= sub_next_state                                                                 ;
    end

    //compute next state from current state and input
    always @*
    begin
        case (sub_current_state)
            IDLE:
                if (counter_data_for_sub < number_of_data && max_done == 1)
                    sub_next_state <= START                                                                     ;
                else
                    sub_next_state <= IDLE                                                                      ;
            START:
                sub_next_state <= SHIFT                                                                         ;
            SHIFT:
                if (sub_result_valid_temp)
                    sub_next_state <= IDLE                                                                      ;
                else
                    sub_next_state <= SHIFT                                                                     ;
            default: 
                sub_next_state <= IDLE                                                                          ;
        endcase
    end
    //compute output
    always @*
    begin
        case (sub_current_state)
            IDLE:
            begin
                exp_sub = 0                                                                                     ;
                abs_exp_diff = 0                                                                                ;
                Z_max_man_temp = 0                                                                              ;
                Z_i_man_temp = 0                                                                                ;
                sub_result_exp_temp = 0                                                                         ;
                sub_result_sign_temp = 0                                                                        ;
                sub_result_man_temp = 0                                                                         ;
                sub_result_valid_temp = 0                                                                       ;
            end
            START:
            begin
                if (Z_max == {Z_i_sign, Z_i_exp, Z_i_man})
                begin
                    sub_result_sign_temp = 0                                                                    ;
                    sub_result_exp_temp = 0                                                                     ;
                    sub_result_man_temp = {1'b0, 1'b1, 23'b0}                                                   ;
                end
                else
                begin
                    sub_result_sign_temp = 1                                                                    ;
                    exp_sub = Z_i_exp - Z_max_exp                                                               ;
                    abs_exp_diff = exp_sub[8] ? ~(exp_sub[7:0]) + 1'b1 : exp_sub[7:0]                           ;
                    Z_max_man_temp = exp_sub[8] ? {1'b1, Z_max_man} : {1'b1, Z_max_man} >> abs_exp_diff         ;
                    Z_i_man_temp = exp_sub[8] ? {1'b1, Z_i_man} >> abs_exp_diff : {1'b1, Z_i_man}               ;
                    sub_result_exp_temp = exp_sub[8] ? Z_max_exp : Z_i_exp                                      ;
                    sub_result_man_temp = (Z_max_sign && Z_i_sign) ? Z_i_man_temp - Z_max_man_temp :
                                          (~Z_max_sign && Z_i_sign) ? Z_i_man_temp + Z_max_man_temp :
                                          Z_max_man_temp - Z_i_man_temp                                         ;
                end
                sub_result_valid_temp = 0                                                                       ;
            end
            SHIFT:
            begin
                exp_sub = 0                                                                                     ;
                abs_exp_diff = 0                                                                                ;
                sub_result_sign_temp = sub_result_sign                                                          ;
                sub_result_exp_temp = sub_result_man[24] ? sub_result_exp + 1 : 
                                      sub_result_man[23] ? sub_result_exp : sub_result_exp - 1                  ;
                sub_result_man_temp = sub_result_man[24] ? sub_result_man : 
                                      (sub_result_man[23] ? sub_result_man : sub_result_man << 1)               ;
                sub_result_valid_temp = sub_result_man_temp[24] || 
                                      ~sub_result_man_temp[24] && sub_result_man_temp[23]                       ;
            end
            default:
            begin
                exp_sub = 0                                                                                     ;
                abs_exp_diff = 0                                                                                ;
                Z_max_man_temp = 0                                                                              ;
                Z_i_man_temp = 0                                                                                ;
                sub_result_exp_temp = 0                                                                         ;
                sub_result_sign_temp = 0                                                                        ;
                sub_result_man_temp = 0                                                                         ;
                sub_result_valid_temp = 0                                                                       ;
            end 
        endcase
    end

    //load Zi
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            begin
                Z_i_sign <= 0                                                                                   ;
                Z_i_exp <= 0                                                                                    ;
                Z_i_man <= 0                                                                                    ;
            end
        else
            if (sub_current_state == IDLE && max_done == 1 && sub_done == 0 
                && counter_data_for_sub < number_of_data)
            begin
                Z_i_sign <= input_buffer[counter_data_for_sub][31]                                              ;
                Z_i_exp <= input_buffer[counter_data_for_sub][30:23]                                            ;
                Z_i_man <= input_buffer[counter_data_for_sub][22:0]                                             ;
            end
    end
    //handle counter for sub block
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            counter_data_for_sub <= 0                                                                           ;
        else
            if (sub_next_state == IDLE && sub_done == 0 && sub_result_valid_temp == 1)
                counter_data_for_sub = counter_data_for_sub + 1                                                 ;
    end
    
    //handle sub_done
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            sub_done <= 0                                                                                       ;
        else
            if (counter_data_for_sub == number_of_data && sub_done == 0)
                sub_done <= 1                                                                                   ;
    end
    //-----------------------------------------------------------------------------------------------------------
endmodule
