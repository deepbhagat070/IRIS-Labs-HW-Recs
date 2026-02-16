`timescale 1ns / 1ps

module accelerator_wrapper (
    input clk,
    input rstn,
    
   
    input             iomem_valid, 
    output reg        iomem_ready,  
    input      [3:0]  iomem_wstrb,  
    input      [31:0] iomem_addr,  
    input      [31:0] iomem_wdata,  
    output reg [31:0] iomem_rdata   
);

   
    reg [1:0] cont_reg;    
    
    
    wire [7:0] prod_pixel;
    wire       prod_valid;
    wire       prod_ready; 
    
   
    wire [7:0] proc_pixel_out;
    wire       proc_valid_out;
    reg        proc_ready_in;  

   
    data_producer #(
        .IMAGE_SIZE(1024)
    ) producer_inst (
        .sensor_clk(clk),
        .rst_n(rstn),
        .ready(prod_ready),
        .pixel(prod_pixel),
        .valid(prod_valid)
    );

    
    data_proc #(
        .IMG_WIDTH(32) 
    ) processor_inst (
        .clk(clk),
        .rstn(rstn),
        .pixel_in(prod_pixel),
        .valid_in(prod_valid),
        .ready_in(proc_ready_in),
        .ready_out(prod_ready),   
        .pixel_out(proc_pixel_out),
        .valid_out(proc_valid_out),
        .cont(cont_reg)           
    );

   
    always @(posedge clk) begin
        if (!rstn) begin
            iomem_ready   <= 0;
            iomem_rdata   <= 0;
            cont_reg      <= 2'b00;
            proc_ready_in <= 0;
        end else begin
            iomem_ready   <= 0;
            proc_ready_in <= 0;

            if (iomem_valid && !iomem_ready) begin
                iomem_ready <= 1; 

               
                if (iomem_wstrb != 0) begin 
                    if (iomem_addr[3:0] == 4'h0) begin
                        cont_reg <= iomem_wdata[1:0];
                    end
                end 
                
                
                else begin
                    case (iomem_addr[3:0])
                      
                        4'h0: iomem_rdata <= {30'b0, cont_reg};
                        
                       
                        4'h4: iomem_rdata <= {31'b0, proc_valid_out};
                        
                        
                        4'h8: begin 
                            iomem_rdata <= {24'b0, proc_pixel_out};
                           
                            proc_ready_in <= 1; 
                        end
                        
                        default: iomem_rdata <= 32'h0;
                    endcase
                end
            end
        end
    end

endmodule