`timescale 1ns / 1ps
module nForkgen (
  input [7:0] SW,
  input core_CLK,
  input core_nReset,
  output logic nfork
);
  parameter n = 32768;
  logic [23:0] count;
  logic [6:0] nfork_timer; // Added a 7-bit counter for 65 time cycle duration
  logic [7:0] SW_prev; // Added to store previous SW value

  always_ff @(posedge core_CLK, negedge core_nReset) begin
    if (!core_nReset) begin
      count <= 0;
      nfork_timer <= 0; // Reset nfork_timer
		nfork <= 1'b1;
    end
    else if (count == (SW * 3277-65) && (SW != 0)) begin
        nfork <= 0;
        count <= 0;
        nfork_timer <= 65; // Start nfork_timer when nfork goes low
      end
    else if (SW == 0) begin
        nfork <= 1;
        count <= 0;
        nfork_timer <= 0; // Reset nfork_timer
      end
    else if (nfork_timer > 0) begin // Added condition to control nfork duration
        nfork <= 0;
        nfork_timer <= nfork_timer - 1'b1;
      end
	 else if (SW != SW_prev) begin
      count <= 0;
    end
    else begin
        nfork <= 1;
        count <= count + 1'b1;
      end
  end
  
    always_ff @(posedge core_CLK, negedge core_nReset) begin
    if (!core_nReset) begin
	   SW_prev <= '0;
    end
	 else begin
	   SW_prev <= SW; // Update SW_prev at every clock cycle
	 end
  end

endmodule