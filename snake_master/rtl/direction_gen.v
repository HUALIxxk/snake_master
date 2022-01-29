`timescale  1ns/1ns
module direction_gen
(
	input 	wire				clk,
	input		wire				rst_n,
	input		wire				key1,
	input		wire				key2,
	input		wire				key3,
	input		wire				key4,
	
	output	reg	[3:0]		direction
);

wire [3:0] btn_new;
wire [3:0] btn_old;
	
assign btn_old = direction;
	
key_filter filter3
(	.sys_clk(clk),
	.sys_rst_n(rst_n),
	.key_in(key1),
	.key_flag(btn_new[3])
);

key_filter filter2
(	.sys_clk(clk),
	.sys_rst_n(rst_n),
	.key_in(key3),
	.key_flag(btn_new[2])
);

key_filter filter1
(	.sys_clk(clk),
	.sys_rst_n(rst_n),
	.key_in(key2),
	.key_flag(btn_new[1])
);

key_filter filter0
(	.sys_clk(clk),
	.sys_rst_n(rst_n),
	.key_in(key4),
	.key_flag(btn_new[0])
);

always @(posedge clk or negedge rst_n)
	begin
		if (rst_n == 1'b0) direction<=4'b0100;
		else if (btn_old == 4'b1000 && btn_new == 4'b0100) direction <= btn_old;
		else if (btn_old == 4'b0100 && btn_new == 4'b1000) direction <= btn_old;
		else if (btn_old == 4'b0010 && btn_new == 4'b0001) direction <= btn_old;
		else if (btn_old == 4'b0001 && btn_new == 4'b0010) direction <= btn_old;
		else if (btn_new != 4'b0000) direction <= btn_new;
	end
endmodule