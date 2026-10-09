`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [2:0]  ALU_Sel;

    wire [31:0] ALU_Out;
    wire        Carry_Out;

    alu uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .Carry_Out(Carry_Out)
    );

    integer test_count;
    integer pass_count;
    integer fail_count;

    task check;
        input [31:0]  expected;
        input [127:0] name;
        begin
            test_count = test_count + 1;
            if (ALU_Out === expected) begin
                pass_count = pass_count + 1;
                $display("TEST %0d: %0s PASS", test_count, name);
            end else begin
                fail_count = fail_count + 1;
                $display("TEST %0d: %0s FAIL (expected %h, got %h)",
                         test_count, name, expected, ALU_Out);
            end
        end
    endtask

    initial begin

        $dumpfile("../waveforms/alu.vcd");
        $dumpvars(0, alu_tb);

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // ADD
        A = 32'd10;
        B = 32'd5;
        ALU_Sel = 3'b000;
        #10;
        $display("ADD: %d + %d = %d", A, B, ALU_Out);
        check(32'd15, "ADD");

        // SUBTRACT
        ALU_Sel = 3'b001;
        #10;
        $display("SUB: %d - %d = %d", A, B, ALU_Out);
        check(32'd5, "SUB");

        // AND
        ALU_Sel = 3'b010;
        #10;
        $display("AND: %h & %h = %h", A, B, ALU_Out);
        check(32'h00000000, "AND");

        // OR
        ALU_Sel = 3'b011;
        #10;
        $display("OR: %h | %h = %h", A, B, ALU_Out);
        check(32'h0000000F, "OR");

        // XOR
        ALU_Sel = 3'b100;
        #10;
        $display("XOR: %h ^ %h = %h", A, B, ALU_Out);
        check(32'h0000000F, "XOR");

        // NOT
        ALU_Sel = 3'b101;
        #10;
        $display("NOT: ~%h = %h", A, ALU_Out);
        check(32'hFFFFFFF5, "NOT");

        // LEFT SHIFT
        ALU_Sel = 3'b110;
        #10;
        $display("LEFT SHIFT: %h << 1 = %h", A, ALU_Out);
        check(32'h00000014, "LEFT SHIFT");

        // RIGHT SHIFT
        ALU_Sel = 3'b111;
        #10;
        $display("RIGHT SHIFT: %h >> 1 = %h", A, ALU_Out);
        check(32'h00000005, "RIGHT SHIFT");

        $display("--------------------------------");
        $display("TOTAL TESTS : %0d", test_count);
        $display("PASSED      : %0d", pass_count);
        $display("FAILED      : %0d", fail_count);
        $display("ALU TEST COMPLETED");
        $display("--------------------------------");

        $finish;
    end

endmodule
