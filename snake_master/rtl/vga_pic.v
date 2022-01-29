`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : vga_pic
// Project Name  : hdmi_colorbar
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 图像数据生成模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  vga_pic
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [11:0]  pix_x       ,   //输入VGA有效显示区域像素点X轴坐标
    input   wire    [11:0]  pix_y       ,   //输入VGA有效显示区域像素点Y轴坐标
	 input	wire				 flag			 ,
	 input	wire	  [3:0]	 direction	 ,
	 
    output  reg     [15:0]  pix_data        //输出像素点色彩信息
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   H_VALID =   12'd640 ,   //行有效数据
            V_VALID =   12'd480 ;   //场有效数据

parameter   RED     =   16'hF800,   //红色
            ORANGE  =   16'hFC00,   //橙色
            YELLOW  =   16'hFFE0,   //黄色
            GREEN   =   16'h07E0,   //绿色
            CYAN    =   16'h07FF,   //青色
            BLUE    =   16'h001F,   //蓝色
            PURPPLE =   16'hF81F,   //紫色
            BLACK   =   16'h0000,   //黑色
            WHITE   =   16'hFFFF,   //白色
            GRAY    =   16'hD69A;   //灰色

//********************************************************************//
wire				wall_on;
wire				apple_on;
wire				death;
wire				snake_head;

reg	[11:0]	size;
reg				apple_eaten;
reg				game_over;
reg	[11:0]	apple_x;
reg	[11:0]	apple_y;
reg	[11:0]	rand_x;
reg	[11:0]	rand_y;
reg	[11:0]	snake_x;
reg	[11:0]	snake_y;


//***************************** Main Code ****************************//
//********************************************************************//
//pix_data:输出像素点色彩信息,根据当前像素点状态指定当前像素点颜色数据
always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		pix_data    <= 16'd0;
	else	if(game_over == 1'b1)
		pix_data    <=  RED;	
	else	if(wall_on == 1'b1)
		pix_data    <=  BLUE;
	else	if(snake_head == 1'b1)
		pix_data    <=  GREEN;
	else	if(apple_on == 1'b1)
		pix_data    <=  RED;
	
	else
		pix_data    <=  BLACK;
		
//wall_on：这是墙
assign	wall_on = (((pix_x >=0) && (pix_x < 10) && (pix_y >= 20)) || 
							((pix_x >= 630) && (pix_x < 640) && (pix_y >= 20)) || 
							((pix_y >= 20) && (pix_y < 30)) || 
							((pix_y >= 470) && (pix_y < 480)));
							
//apple_x,apple_y:当apple被吃后，取随机数确定苹果坐标
always@(posedge vga_clk)			
	if(sys_rst_n == 1'b0)
		begin
			apple_x = 300;
			apple_y = 200;
		end
	else	if(apple_eaten == 1'b1)
		begin
			if((rand_x < 30) ||	(rand_x >620))
				apple_x = 300;
			else
				apple_x = rand_x;	
			if((rand_y < 40) ||	(rand_y >460))
				apple_y = 200;
			else	
				apple_y = rand_y;
		end
		
//不间断产生随机数
always@(posedge vga_clk or negedge sys_rst_n)			
	if(sys_rst_n == 1'b0)
		begin
			rand_x = 300;
			rand_y = 200;
		end
	else
		begin
			if(rand_x > 620)
				rand_x = 30;
			else
				rand_x = rand_x + 30;
				
			if(rand_y > 460)
				rand_y = 40;
			else
				rand_y = rand_y + 10;
		end
		
//这是苹果		
assign	apple_on = ((pix_x >= apple_x) && (pix_x < (apple_x + 10))) && 
							((pix_y >= apple_y) && (pix_y < (apple_y + 10)));


always@(posedge flag or negedge sys_rst_n)			
	begin
		if(sys_rst_n == 1'b0)
			begin
				snake_x <= 400;
				snake_y <= 200;
			end
		else	
			case (direction)
				4'b1000: snake_x <= (snake_x - 10);
				4'b0100: snake_x <= (snake_x + 10);
				4'b0010: snake_y <= (snake_y - 10);
				4'b0001: snake_y <= (snake_y + 10);
			endcase
	end							
							
							
//这是蛇
assign	snake_head = ((pix_x >= snake_x) && (pix_x < (snake_x + 10))) && 
							((pix_y >= snake_y) && (pix_y < (snake_y + 10)));


assign	death = wall_on && snake_head;
	
always @(posedge vga_clk or negedge sys_rst_n)
	begin
		if (sys_rst_n == 1'b0) 
			game_over <= 1'b0;
		else if (death) 
			game_over <= 1'b1;
	end




							
always @(posedge vga_clk or negedge sys_rst_n)
	begin
		if (sys_rst_n == 1'b0) 
			begin
				apple_eaten <= 1'b0; 
				size <= 1;
			end
		else	if ((snake_x == apple_x) && (snake_y == apple_y))
			begin
				apple_eaten <= 1'b1;
				size <= size + 1;
			end
		else
			apple_eaten <= 1'b0;
	end	



			
endmodule
