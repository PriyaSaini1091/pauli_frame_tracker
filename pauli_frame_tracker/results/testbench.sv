// --- 2. THE TESTBENCH ---
module tb_pauli_tracker;
    reg        clk;
    reg        rst_n;
    reg [1:0]  op_code;
    reg        target_q;
    reg        err_x;
    reg        err_z;
    wire [1:0] x_frame;
    wire [1:0] z_frame;

    pauli_tracker_2q dut (
        .clk(clk), .rst_n(rst_n), .op_code(op_code), .target_q(target_q),
        .err_x(err_x), .err_z(err_z), .x_frame(x_frame), .z_frame(z_frame)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pauli_tracker);

        clk = 0; rst_n = 0; op_code = 0; target_q = 0; err_x = 0; err_z = 0;
        #20;
        rst_n = 1;
        #10;
        
        op_code = 2'b01; target_q = 0; err_x = 1; err_z = 0; // Inject X on Q0
        #10;
        op_code = 2'b00; err_x = 0;
        #20;
        
        op_code = 2'b11; // CNOT Q0 -> Q1
        #10;
        op_code = 2'b00; 
        #20;
        
        op_code = 2'b10; target_q = 1; // Hadamard Q1
        #10;
        op_code = 2'b00;
        #30;
        
        $finish;
    end
endmodule


