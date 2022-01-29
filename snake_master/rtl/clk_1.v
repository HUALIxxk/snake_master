module	clk_1
(
	input		wire		vga_clk     ,   //输入工作时钟,频率25MHz
	input		wire		sys_rst_n   ,   //输入复位信号,低电平有效
	
	output	reg		flag				
);

	reg	[24:0]		cnt;
	
always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt = 25'b0;
	else	if(cnt == 24_999_999 - 1)
		cnt = 25'b0;
	else
		cnt = cnt + 1'b1;

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		flag = 1'b0;
	else	if(cnt == 24_999_999 - 1)
		flag = 1'b1;
	else
		flag = 1'b0;		
		
endmodule