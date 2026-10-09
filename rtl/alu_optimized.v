/* verilator lint_off DECLFILENAME */
module alu (
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  ALU_Sel,
    output reg [31:0] ALU_Out,
    output reg        Carry_Out
);

// One shared adder: SUB is A + ~B + 1, ADD is A + B + 0.
wire        sub   = (ALU_Sel == 3'b001);
wire [31:0] b_in  = B ^ {32{sub}};
wire [32:0] sum   = {1'b0, A} + {1'b0, b_in} + {32'b0, sub};

always @(*) begin

    ALU_Out   = 32'b0;
    Carry_Out = 1'b0;

    case (ALU_Sel)
        3'b000: begin
            ALU_Out   = sum[31:0];
            Carry_Out = sum[32];
        end
        3'b001: ALU_Out = sum[31:0];
        3'b010: ALU_Out = A & B;
        3'b011: ALU_Out = A | B;
        3'b100: ALU_Out = A ^ B;
        3'b101: ALU_Out = ~A;
        3'b110: ALU_Out = A << 1;
        3'b111: ALU_Out = A >> 1;
    endcase
end

endmodule
