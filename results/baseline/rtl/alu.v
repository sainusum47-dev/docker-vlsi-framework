module alu (
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  ALU_Sel,
    output reg [31:0] ALU_Out,
    output reg        Carry_Out
);

always @(*) begin

    ALU_Out   = 32'b0;
    Carry_Out = 1'b0;

    case (ALU_Sel)

        3'b000: begin
            {Carry_Out, ALU_Out} = A + B;
        end

        3'b001: begin
            ALU_Out = A - B;
        end

        3'b010: begin
            ALU_Out = A & B;
        end

        3'b011: begin
            ALU_Out = A | B;
        end

        3'b100: begin
            ALU_Out = A ^ B;
        end

        3'b101: begin
            ALU_Out = ~A;
        end

        3'b110: begin
            ALU_Out = A << 1;
        end

        3'b111: begin
            ALU_Out = A >> 1;
        end

    endcase
end

endmodule
