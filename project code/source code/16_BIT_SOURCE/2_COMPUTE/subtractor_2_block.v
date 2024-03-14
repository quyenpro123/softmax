module subtractor_2_block 
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   sub_2_ln_data_i                                                         ,
    input                               sub_2_ln_data_valid_i                                                   ,

    input           [data_size - 1:0]   sub_2_downscale_data_i                                                  ,
    input                               sub_2_downscale_data_valid_i                                            ,

    output          [data_size - 1:0]   sub_2_data_o                                                            ,
    output                              sub_2_data_valid_o
);
    //internal variables for input
    integer                             i                                                                       ;
    reg             [7:0]               counter_data_input_stream                                               ;
    reg             [data_size - 1:0]   sub_2_input_buffer  [number_of_data - 1:0]                              ;
    reg                                 sub_2_input_ready                                                       ;
    reg             [data_size - 1:0]   reg_sub_2_ln_data_i                                                     ;

    //internal variable for output
    reg                                 sub_2_data_valid_o_temp                                                 ;
    reg                                 next_sub_2_data_valid_o_temp                                            ;
    reg             [data_size - 1:0]   sub_2_data_o_temp                                                       ;
    reg             [data_size - 1:0]   next_sub_2_data_o_temp                                                  ;
    reg             [7:0]               counter_data_compute_output                                             ;


    //FSM variables
    localparam                          IDLE = 0                                                                ;
    localparam                          FP_2_FXP = 1                                                            ;
    localparam                          COMPUTE = 2                                                             ;

    reg             [1:0]               sub_2_current_state                                                     ;
    reg             [1:0]               sub_2_next_state                                                        ;

    //FP to FXP variable
    reg                                 sub_2_FP_2_FXP_done                                                     ;
    reg             [data_size - 1:0]   sub_2_fxp_data                                                          ;
    reg             [data_size - 1:0]   next_sub_2_fxp_data                                                     ;
    reg             [data_size - 1:0]   sub_2_downscale_input_temp                                              ;


    //-------------------------------------------------update output--------------------------------------------
    assign sub_2_data_o = sub_2_data_o_temp                                                                     ;
    assign sub_2_data_valid_o = sub_2_data_valid_o_temp                                                         ;


    //--------------------------------------------------input stream--------------------------------------------
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for(i = 0 ; i < number_of_data ; i = i + 1)
                sub_2_input_buffer[i] <= 0                                                                      ;
        else
            if (sub_2_downscale_data_i)
                sub_2_input_buffer[counter_data_input_stream] <= sub_2_downscale_data_i                         ;
    end

    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_input_stream <= 0                                                                      ;
        else
            if (sub_2_downscale_data_valid_i && counter_data_input_stream < number_of_data)
                counter_data_input_stream <= counter_data_input_stream + 1                                      ;
    end

    //catch ln_data_out
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            reg_sub_2_ln_data_i <= 0                                                                            ;
        else
            if (sub_2_ln_data_valid_i)
                reg_sub_2_ln_data_i <= sub_2_ln_data_i                                                          ;
    end

    //input ready to compute
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            sub_2_input_ready <= 0                                                                              ;
        else
            if (sub_2_input_ready == 1)
                sub_2_input_ready <= 0                                                                          ;
            if (~sub_2_input_ready && counter_data_compute_output < counter_data_input_stream && sub_2_ln_data_valid_i)
                sub_2_input_ready <= 1                                                                          ;
    end

    //---------------------------------------------Get temp output----------------------------------------------
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            begin
                sub_2_data_valid_o_temp <= 0                                                                    ;
                sub_2_data_o_temp <= 0                                                                          ;
            end
        else
            begin
                sub_2_data_valid_o_temp <= next_sub_2_data_valid_o_temp                                         ;
                sub_2_data_o_temp <= next_sub_2_data_o_temp                                                     ;
            end
    end

    //------------------------------------------get FXP data---------------------------------------------------
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            sub_2_fxp_data <= 0                                                                                 ;
        else
            sub_2_fxp_data <= {next_sub_2_fxp_data[31], 7'b0, 
                              next_sub_2_fxp_data[30:23], next_sub_2_fxp_data[22:7]}                            ;
    end

    //------------------------------------------------FSM-------------------------------------------------------


    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            sub_2_current_state <= IDLE                                                                         ;
        else
            sub_2_current_state <= sub_2_next_state                                                             ;
    end

    always @* 
    begin
        case (sub_2_current_state)
            IDLE:
                if (sub_2_input_ready)
                    sub_2_next_state = FP_2_FXP                                                                 ;
                else
                    sub_2_next_state = IDLE                                                                     ;
            FP_2_FXP:
                if (sub_2_FP_2_FXP_done)
                    sub_2_next_state = COMPUTE                                                                  ;
                else
                    sub_2_next_state = FP_2_FXP                                                                 ;
            COMPUTE: 
                if (next_sub_2_data_valid_o_temp)
                    sub_2_next_state = IDLE                                                                     ;
                else
                    sub_2_next_state = COMPUTE                                                                  ;
            default: 
                sub_2_next_state = IDLE                                                                         ;
        endcase    
    end

    always @* 
    begin
        case (sub_2_current_state)
            IDLE:
            begin
                next_sub_2_data_valid_o_temp = 0                                                                ;
                next_sub_2_data_o_temp = 0                                                                      ;
                if (counter_data_compute_output < number_of_data)
                    sub_2_downscale_input_temp = sub_2_input_buffer[counter_data_compute_output]                ;
                else
                    sub_2_downscale_input_temp = 0                                                              ;
                sub_2_FP_2_FXP_done = 0                                                                         ;
                next_sub_2_fxp_data = 0                                                                         ;
            end
            FP_2_FXP:
            begin
                next_sub_2_data_valid_o_temp = 0                                                                ;
                next_sub_2_data_o_temp = 0                                                                      ;
                sub_2_downscale_input_temp = sub_2_input_buffer[counter_data_compute_output]                    ;
                if (sub_2_downscale_input_temp == 0)
                    next_sub_2_fxp_data = 0                                                                     ;
                else
                    begin
                        next_sub_2_fxp_data[31] = sub_2_downscale_input_temp[31]                                ;
                        if (sub_2_downscale_input_temp[30:23] > 127)
                                next_sub_2_fxp_data[30:0] = {7'b0, 1'b1, sub_2_downscale_input_temp[22:0]}
                                                            << (sub_2_downscale_input_temp[30:23] - 127)        ;
                        else if (sub_2_downscale_input_temp[30:23] < 127)
                                next_sub_2_fxp_data[30:0] = {7'b0, 1'b1, sub_2_downscale_input_temp[22:0]}
                                                            >> (127 - sub_2_downscale_input_temp[30:23])        ;
                        else
                            next_sub_2_fxp_data[30:0] = {7'b0, 1'b1, sub_2_downscale_input_temp[22:0]}          ;
                    end
                sub_2_FP_2_FXP_done = 1                                                                         ;
            end 
            COMPUTE: 
            begin
                next_sub_2_data_valid_o_temp = 1                                                                ;
                next_sub_2_data_o_temp[30:0] = {13'b0, reg_sub_2_ln_data_i[31:14]} + sub_2_fxp_data[30:0]       ;
                next_sub_2_data_o_temp[31] = 0                                                                  ;
                sub_2_downscale_input_temp = 0                                                                  ;
                next_sub_2_fxp_data = sub_2_fxp_data                                                            ;
                sub_2_FP_2_FXP_done = 0                                                                         ;
            end 
            default: 
            begin
                next_sub_2_data_valid_o_temp = 0                                                                ;
                next_sub_2_data_o_temp = 0                                                                      ;
                sub_2_downscale_input_temp = 0                                                                  ;
                next_sub_2_fxp_data = 0                                                                         ;
                sub_2_FP_2_FXP_done = 0                                                                         ;
            end   
        endcase 
    end
    
    //handle counter data for comput
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_compute_output <= 0                                                                    ;
        else
            if (sub_2_next_state == COMPUTE && counter_data_compute_output < number_of_data)
                counter_data_compute_output = counter_data_compute_output + 1                                   ;  
    end
endmodule