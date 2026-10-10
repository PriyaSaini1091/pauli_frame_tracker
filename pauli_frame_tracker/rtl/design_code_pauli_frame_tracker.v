// Code your design here
`timescale 1ns/1ps
//design.sv
module pauli_tracker_2q (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  op_code,   // 00: IDLE, 01: INJECT, 10: H, 11: CNOT
    input  wire        target_q,  // 0: Qubit 0, 1: Qubit 1
    input  wire        err_x,     // Bit-flip injection flag
    input  wire        err_z,     // Phase-flip injection flag
    output reg  [1:0]  x_frame,   // [1]: Q1 X-err, [0]: Q0 X-err
    output reg  [1:0]  z_frame    // [1]: Q1 Z-err, [0]: Q0 Z-err
);

    localparam OP_IDLE   = 2'b00;
    localparam OP_INJECT = 2'b01;
    localparam OP_H      = 2'b10;
    localparam OP_CNOT   = 2'b11; // Q0 = Control, Q1 = Target

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_frame <= 2'b00;
            z_frame <= 2'b00;
        end else begin
            case (op_code)
                OP_IDLE: begin
                    x_frame <= x_frame;
                    z_frame <= z_frame;
                end

                OP_INJECT: begin
                    if (target_q == 1'b0) begin
                        x_frame[0] <= x_frame[0] ^ err_x;
                        z_frame[0] <= z_frame[0] ^ err_z;
                    end else begin
                        x_frame[1] <= x_frame[1] ^ err_x;
                        z_frame[1] <= z_frame[1] ^ err_z;
                    end
                end

                OP_H: begin
                    if (target_q == 1'b0) begin
                        x_frame[0] <= z_frame[0];
                        z_frame[0] <= x_frame[0];
                    end else begin
                        x_frame[1] <= z_frame[1];
                        z_frame[1] <= x_frame[1];
                    end
                end

                OP_CNOT: begin
   // Single-cycle GF(2) stabilizer propagation
                    x_frame[1] <= x_frame[1] ^ x_frame[0]; // X spreads forward
                    z_frame[0] <= z_frame[0] ^ z_frame[1]; // Z spreads backward
                end

                default: begin
                    x_frame <= x_frame;
                    z_frame <= z_frame;
                end
            endcase
        end
    end

endmodule
