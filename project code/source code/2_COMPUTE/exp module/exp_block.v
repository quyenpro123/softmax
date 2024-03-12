module exp_block 
#(
    parameter                           data_size = 32                                                          ,
    parameter                           number_of_data = 10
)
(
    input                               clock_i                                                                 ,
    input                               reset_n_i                                                               ,
    input           [data_size - 1:0]   exp_data_i                                                              ,
    input                               exp_data_valid_i                                                        ,

    output                              exp_done_o                                                              ,
    output                              exp_data_valid_o                                                        ,
    output          [data_size - 1:0]   exp_data_o
);
    //----------------------------------------internal variable-------------------------------------------------
    integer                             i                                                                       ;

    reg             [7:0]               counter_data_input_stream                                               ;
    reg             [data_size - 1:0]   exp_buffer    [number_of_data - 1:0]                                    ;

    reg                                 exp_valid_o_temp                                                        ;
    reg             [data_size - 1:0]   exp_o_temp                                                              ;
    reg                                 next_exp_valid_o_temp                                                   ;
    wire                                next_exp_valid_o_temp_wire                                              ;
    reg             [data_size - 1:0]   next_exp_o_temp                                                         ;
    wire            [data_size - 1:0]   next_exp_o_temp_wire                                                    ;
    reg                                 exp_done_o_temp                                                         ;

    reg             [data_size - 1:0]   exp_input_data_temp                                                     ;
    reg             [data_size - 1:0]   exp_fxp_data                                                            ;
    wire            [data_size - 1:0]   exp_fxp_data_wire                                                       ;
    reg             [data_size - 1:0]   next_exp_fxp_data                                                       ;


    //-------------------------------------------FSM variable---------------------------------------------------
    localparam                          IDLE = 0                                                                ;
    localparam                          FP_2_FXP = 1                                                            ;
    localparam                          LUT = 2                                                                 ;
    
    reg                                 FP_2_FXP_done                                                           ;
    wire                                FP_2_FXP_done_wire                                                      ;
    reg                                 exp_input_ready                                                         ;
    
    reg             [1:0]               exp_current_state                                                       ;
    reg             [1:0]               exp_next_state                                                          ;
    reg             [7:0]               counter_data_compute_output                                             ;


    //-------------------------------------------assign output--------------------------------------------------
    assign exp_data_valid_o = exp_valid_o_temp                                                                  ;
    assign exp_data_o = exp_o_temp                                                                              ;
    assign exp_done_o = exp_done_o_temp                                                                         ;

    //--------------------------------------------input stream--------------------------------------------------
    always @(posedge clock_i) 
    begin
        if (~reset_n_i)
            for(i = 0 ; i < number_of_data ; i = i + 1)
                exp_buffer[i] <= 0                                                                              ;
        else
            if (exp_data_valid_i)
                exp_buffer[counter_data_input_stream] <= exp_data_i                                             ;
    end
    
    //handle counter data input stream
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            counter_data_input_stream <= 0                                                                      ;
        else
            if (counter_data_input_stream < number_of_data && exp_data_valid_i)
                counter_data_input_stream = counter_data_input_stream + 1                                       ;
    end

    //input valid for compute
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
            exp_input_ready <= 0                                                                                ;
        else
            if (exp_input_ready)
                exp_input_ready <= 0                                                                            ;
            if (counter_data_input_stream > counter_data_compute_output && ~exp_input_ready)
                exp_input_ready <= 1                                                                            ;
    end
    
    //output temp load value
    always @(posedge clock_i) 
    begin
        if(~reset_n_i)
        begin
            exp_fxp_data <= 0                                                                                   ;
            exp_o_temp <= 0                                                                                     ;
            exp_valid_o_temp <= 0                                                                               ;
        end
        else
        begin
            exp_fxp_data <= {12'b0, next_exp_fxp_data[26:23], next_exp_fxp_data[22:7]}                          ;
            exp_o_temp <= next_exp_o_temp                                                                       ;
            exp_valid_o_temp <= next_exp_valid_o_temp                                                           ;
        end
    end
    
    always @(posedge clock_i)
    begin
        if (~reset_n_i)
            exp_done_o_temp <= 0                                                                                ;
        else
            if (counter_data_compute_output == 10)
                exp_done_o_temp <= 1                                                                            ;
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
                if (exp_input_ready)
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
        next_exp_fxp_data = 0                                                                                   ;
        case(exp_current_state)
            IDLE:
            begin
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 1                                                                             ;
                next_exp_fxp_data = 0                                                                           ;
                if (counter_data_compute_output < number_of_data)
                    exp_input_data_temp = exp_buffer[counter_data_compute_output]                               ;
                else
                    exp_input_data_temp = 0                                                                     ;
                FP_2_FXP_done = 0                                                                               ;
            end
            FP_2_FXP:
            begin
                exp_input_data_temp = exp_buffer[counter_data_compute_output]                                   ;
                if (exp_input_data_temp == 0)
                    next_exp_fxp_data = 0                                                                       ;
                else
                    if (exp_input_data_temp[30:23] > 127)
                        next_exp_fxp_data[30:0] = {7'b0,1'b1,exp_input_data_temp[22:0]} 
                                                  << (exp_input_data_temp[30:23] - 127)                         ;
                    else if (exp_input_data_temp[30:23] < 127)
                        next_exp_fxp_data[30:0] = {7'b0,1'b1,exp_input_data_temp[22:0]} 
                                                  >> (127 - exp_input_data_temp[30:23])                         ;
                    else
                        next_exp_fxp_data[30:0] = {7'b0,1'b1,exp_input_data_temp[22:0]}                         ;
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 1                                                                             ;
                FP_2_FXP_done = 1                                                                               ;
            end
            LUT:
            begin
                next_exp_fxp_data = exp_fxp_data                                                                ;
                next_exp_valid_o_temp = next_exp_valid_o_temp_wire                                              ;
                next_exp_o_temp = next_exp_o_temp_wire                                                          ;
                FP_2_FXP_done = 1                                                                               ;
                exp_input_data_temp = 0                                                                         ;
            end
                
            default:
            begin
                next_exp_valid_o_temp = 0                                                                       ;
                next_exp_o_temp = 0                                                                             ;
                next_exp_fxp_data = 0                                                                           ;
                exp_input_data_temp = 0                                                                         ;
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
            if (exp_current_state == LUT && counter_data_compute_output < number_of_data)
                counter_data_compute_output = counter_data_compute_output + 1                                   ;
    end
    
    //----------------------------------------------------------------------------------------------------------
    
    //--------------------------------------------LUT EXP-------------------------------------------------------
    assign exp_fxp_data_wire = next_exp_fxp_data                                                                ;
    assign FP_2_FXP_done_wire = FP_2_FXP_done                                                                   ;
    
    lut_exp lut(
                    .clock_i(clock_i)                                                                           ,
                    .reset_n_i(reset_n_i)                                                                       ,
                    .lut_data_i(exp_fxp_data_wire)                                                              ,
                    .FP_2_FXP_done_i(FP_2_FXP_done_wire)                                                        ,
                    
                    .lut_data_valid_o(next_exp_valid_o_temp_wire)                                               , 
                    .lut_data_o(next_exp_o_temp_wire) 
                );
endmodule