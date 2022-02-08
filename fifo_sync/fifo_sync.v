
module fifo_sync #(
	parameter size_p = 8,
	parameter depth_p = 255,
	parameter aw_p = $clog2(depth_p)+1
) (
	input clk,
	input rst,

	input [size_p-1:0] data_i,
	input valid_i,
	output reg ready_o,

	output reg [size_p-1:0] data_o,
	output reg valid_o,
	input ready_i
);


//Memory Array
reg [size_p-1:0] mem[depth_p];

//Pointers
reg [aw_p-1:0] wr_ptr, rd_ptr, count, next_count;

//Interface conditions.
assign valid_write = valid_i & ready_o;
assign valid_read = valid_o & ready_i;

//Write logic
always @(posedge clk or posedge rst)
	if(rst)
		wr_ptr <= 0;
	else if(valid_write)
		wr_ptr <= wr_ptr + 1'b1;

always @(posedge clk)
	if(valid_write)
		mem[wr_ptr] <= data_i;

//Read Logic
always @(posedge clk or posedge rst)
	if(rst)
		rd_ptr <= 0;
	else if(valid_read)
		rd_ptr <= rd_ptr + 1'b1;

always @(*)
	data_o = mem[rd_ptr];


//Flag Logic

always @(*) begin
	if(valid_read & valid_write)
		next_count = count;
	else if(valid_read)
		next_count = count - 1'b1;
	else if(valid_write)
		next_count = count + 1'b1;
	else
		next_count = count;
end

always @(posedge clk or posedge rst) 
	if(rst)
		count <= 0;
	else
		count <= next_count;
		

always @(posedge clk or posedge rst)
	if(rst)
		{ready_o, valid_o} <= '0;
	else begin
		ready_o <= !(next_count == depth_p-1);
		valid_o <= !(next_count == 1'b0);
	end


endmodule		
