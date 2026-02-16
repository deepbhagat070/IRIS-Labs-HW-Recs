`timescale 1ns / 1ps

module data_proc #(
    parameter IMG_WIDTH = 32 
)(
    input clk,
    input rstn,
    input [7:0] pixel_in,
    input valid_in,
    input ready_in,
    output ready_out,
    output reg [7:0] pixel_out,
    output reg valid_out,
    input [1:0] cont
    );


    reg ready_enable;
    reg [7:0] safe_buffer;

    assign ready_out = ready_enable && !clk; 

    reg [7:0] lb0 [0:IMG_WIDTH-1]; 
    reg [7:0] lb1 [0:IMG_WIDTH-1]; 


    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    reg [9:0] x_pos; 
    reg [9:0] y_pos; 
    
    integer sum; 
    integer i;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_out    <= 0;
            ready_enable <= 1;
            pixel_out    <= 0;
            safe_buffer  <= 0;
            
            x_pos <= 0;
            y_pos <= 0;
            
            p00<=0; p01<=0; p02<=0;
            p10<=0; p11<=0; p12<=0;
            p20<=0; p21<=0; p22<=0;

            for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                lb0[i] <= 8'd0;
                lb1[i] <= 8'd0;
            end
        end 
        else begin
            
            if (ready_enable && valid_in) begin
                safe_buffer  <= pixel_in;      
                ready_enable <= 0;             
                valid_out    <= 0;

                
                p00 <= p01; p01 <= p02; p02 <= lb0[x_pos]; 
                p10 <= p11; p11 <= p12; p12 <= lb1[x_pos]; 
                p20 <= p21; p21 <= p22; p22 <= pixel_in;   

               
                lb0[x_pos] <= lb1[x_pos]; 
                lb1[x_pos] <= pixel_in;   

                if (x_pos == IMG_WIDTH-1) begin
                    x_pos <= 0;
                    y_pos <= y_pos + 1;
                end else begin
                    x_pos <= x_pos + 1;
                end
            end
            
            else if (!ready_enable) begin
                valid_out <= 1; 
                
                case (cont)
                    2'b00: pixel_out <= safe_buffer;
                    2'b01: pixel_out <= ~safe_buffer;
                    
                    2'b10: begin
                        if (y_pos >= 2 && x_pos >= 1) begin
                            sum = (p11 * 4) - (p01 + p10 + p12 + p21);
                            
                            if (sum < 0) pixel_out <= 0;
                            else if (sum > 255) pixel_out <= 255;
                            else pixel_out <= sum[7:0];
                        end 
                        else begin
                            pixel_out <= 8'h00; 
                        end
                    end
                    
                    default: pixel_out <= safe_buffer;
                endcase

                if (ready_in) ready_enable <= 1; 
            end
        end
    end
endmodule