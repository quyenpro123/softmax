
`timescale 1 ns / 1 ps

	module softmax_ip_reset_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4,
		parameter data_size = 16
	)
	(
		// Users to add ports here
        input                              s_axis_valid_i                                                           ,
        input                               s_axis_last_i                                                           ,
        input           [2*data_size - 1:0] s_axis_data_i                                                           ,
        output                              s_axis_ready_o                                                          ,

        //master axi4 stream
        input                               m_axis_ready_i                                                          ,
        output          [2*data_size - 1:0] m_axis_data_o                                                           ,
        output                              m_axis_valid_o                                                          ,
        output                              m_axis_last_o                                                           ,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready,
		output      reset
	);
// Instantiation of Axi Bus Interface S_AXI
	softmax_ip_reset_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) softmax_ip_reset_v1_0_S_AXI_inst (
		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready),
		.reset(reset)
	);

	// Add user logic here
	softmax_top_16 softmax(
        axi_clock_i(s_axi_aclk)                                                                     ,
        axi_reset_n_i(reset)                                                                        ,
        //slave axi4 stream
        s_axis_valid_i(s_axis_valid_i)                                                              ,
        s_axis_last_i(s_axis_last_i)                                                                ,
        s_axis_data_i(s_axis_data_i)                                                                ,
        s_axis_ready_o(s_axis_ready_o)                                                              ,

    //master axi4 stream
        m_axis_ready_i(m_axis_ready_i)                                                              ,
        m_axis_data_o(m_axis_data_o)                                                                ,
        m_axis_valid_o(m_axis_valid_o)                                                              ,
        m_axis_last_o(m_axis_last_o)
	// User logic ends
    );
	endmodule
