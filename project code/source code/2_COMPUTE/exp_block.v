module exp_block 
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   data_i                                                                  ,
    input                               data_valid_i                                                            ,

    output                              exp_valid_o                                                             ,
    output          [data_size - 1:0]   exp_o
);
    //----------------------------------------internal variable-------------------------------------------------
    integer                             i                                                                       ;

    reg             [7:0]               counter_data_input_stream                                               ;
    reg             [data_size - 1:0]   exp_buffer    [number_of_data - 1:0]                                    ;

    reg                                 exp_valid_o_temp                                                        ;
    reg             [data_size - 1:0]   exp_o_temp                                                              ;
    reg                                 next_exp_valid_o_temp                                                   ;
    reg             [data_size - 1:0]   next_exp_o_temp                                                         ;

    reg             [data_size - 1:0]   input_data                                                              ;
    reg             [data_size - 1:0]   fxp_data                                                                ;
    reg             [data_size - 1:0]   next_fxp_data                                                           ;


    //-------------------------------------------FSM variable---------------------------------------------------
    localparam                          IDLE = 0                                                                ;
    localparam                          FP_2_FXP = 1                                                            ;
    localparam                          LUT = 2                                                                 ;
    
    reg                                 FP_2_FXP_done                                                           ;
    reg                                 input_valid                                                             ;
    
    reg             [1:0]               exp_current_state                                                       ;
    reg             [1:0]               exp_next_state                                                          ;
    reg             [7:0]               counter_data_compute_output                                             ;


    //----------------------------------------LUT---------------------------------------------------------------
    reg             [data_size - 1:0]   LUT_EXP         [30:0]                                                  ;

    //-------------------------------------------assign output--------------------------------------------------
    assign exp_valid_o = exp_valid_o_temp                                                                       ;
    assign exp_o = exp_o_temp                                                                                   ;


    //--------------------------------------------input stream--------------------------------------------------
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for(i = 0 ; i < number_of_data ; i = i + 1)
                exp_buffer[i] <= 0                                                                              ;
        else
            if (data_valid_i)
                exp_buffer[counter_data_input_stream] <= data_i                                                 ;
    end
    
    //handle counter data input stream
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            counter_data_input_stream <= 0                                                                      ;
        else
            if (counter_data_input_stream < number_of_data && data_valid_i)
                counter_data_input_stream = counter_data_input_stream + 1                                       ;
    end

    //input valid for compute
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            input_valid <= 0                                                                                    ;
        else
            if (input_valid)
                input_valid <= 0                                                                                ;
            if (data_valid_i && ~input_valid)
                input_valid <= 1                                                                                ;
    end
    
    //output temp load value
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
        begin
            fxp_data <= 0                                                                                       ;
            exp_o_temp <= 0                                                                                     ;
            exp_valid_o_temp <= 0                                                                               ;
        end
        else
        begin
            fxp_data <= next_fxp_data                                                                           ;
            exp_o_temp <= next_exp_o_temp                                                                       ;
            exp_valid_o_temp <= next_exp_valid_o_temp                                                           ;
        end
    end
    //---------------------------------------------FSM----------------------------------------------------------
    
    //register transfer state
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            exp_current_state <= IDLE                                                                           ;
        else
            exp_current_state <= exp_next_state                                                                 ;
    end

    //comput next state from current state and output
    always @*
    begin
        case(exp_current_state)
            IDLE:
                if (input_valid)
                    exp_next_state = FP_2_FXP                                                                   ;
                else
                    exp_next_state = IDLE                                                                       ;
            FP_2_FXP:
                if (FP_2_FXP_done)
                    exp_next_state = LUT                                                                        ;
                else
                    exp_next_state = FP_2_FXP                                                                   ;
            LUT:
                if (next_exp_valid_o_temp)
                    exp_next_state = IDLE                                                                       ;
                else
                    exp_next_state = LUT                                                                        ;
            default:
                exp_next_state = IDLE                                                                           ;
        endcase
    end
    //comput output from current state
    always @*
    begin
        next_fxp_data = 0                                                                                       ;
        case(exp_current_state)
            IDLE:
            begin
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 1                                                                             ;
                next_fxp_data = 0                                                                               ;
                if (counter_data_compute_output < number_of_data)
                    input_data = exp_buffer[counter_data_compute_output]                                        ;
                else
                    input_data = 0                                                                              ;
                FP_2_FXP_done = 0                                                                               ;
            end
            FP_2_FXP:
            begin
                input_data = exp_buffer[counter_data_compute_output]                                            ;
                if (input_data == 0)
                    next_fxp_data = 32'h00000000                                                                ;
                else
                    if (input_data[30:23] > 127)
                        next_fxp_data[30:0] = {7'b0000000,1'b1,input_data[22:0]} << (input_data[30:23] - 127)   ;
                    else
                        next_fxp_data[30:0] = {7'b0000000,1'b1,input_data[22:0]} >> (127 - input_data[30:23])   ;
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 1                                                                             ;
                FP_2_FXP_done = 1                                                                               ;
            end
            LUT:
            begin
                next_fxp_data = fxp_data                                                                        ;
                for (i = 0 ; i < 31 ; i = i + 1)
                    next_exp_o_temp = next_exp_o_temp * fxp_data[i] ? LUT_EXP[i] : 1                            ;
                FP_2_FXP_done = 0                                                                               ;
                next_exp_valid_o_temp = 1                                                                       ;
                input_data = 0                                                                                  ;
            end
                
            default:
            begin
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 0                                                                             ;
                next_fxp_data = 0                                                                               ;
                input_data = 0                                                                                  ;
                FP_2_FXP_done = 0                                                                               ;
            end
        endcase
    end

    //handle counter data for compute output
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            counter_data_compute_output <= 0                                                                    ;
        else
            if (FP_2_FXP_done && counter_data_compute_output < number_of_data)
                counter_data_compute_output = counter_data_compute_output + 1                                   ;
    end
    
    //----------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------Initiate LUT-------------------------------------------------
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            for(i = 0 ; i < 31 ; i = i + 1)
                LUT_EXP[i] <= 1                                                                                 ;
    end
endmodule