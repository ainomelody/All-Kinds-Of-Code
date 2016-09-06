`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/29 20:11:44
// Design Name: 
// Module Name: tablets
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tablets(
    input origCP,
    input readyToInput,
    input [3 : 0]highBCD,
    input [3 : 0]lowBCD,
    output [7 : 0]anodes,
    output [7 : 0]cathnodes,
    output [2 : 0]workLeds, //顺序RGB
    output [2 : 0]errLeds,
    output bottleFull,
    output startWork
);
    wire [5 : 0] tabPerBottle, chooserOut, bottlesNum, curTabs;
    wire inputErr, startWork;              //输入是否正确
    wire allFinished;           //18瓶是否装完
    reg bottleFull;            //当前瓶是否装满，比较器输出
    wire [3 : 0] num2High, num2Low, num3High, num3Mid, num3Low, inputHigh, inputLow;
    wire [7 : 0] num2Ten, num2One, num3Hund, num3Ten, num3One, inputTen, inputOne;
    wire [9 : 0] totalCount;    //总药片数
    wire tabCounting;           //药片计数的脉冲
    wire convOK;
    
    conv2ToBCD dutConvInput(tabPerBottle, inputHigh, inputLow);
    inputReg unitInput(readyToInput,highBCD, lowBCD, tabPerBottle, inputErr, startWork);
    timeCounter #(2) tabDripping(origCP, (~startWork) | allFinished | bottleFull, tabCounting); //药片下落停止条件加入瓶满
    chooser selectNum(1, bottlesNum, curTabs, chooserOut);
    conv2ToBCD dutConv2(chooserOut, num2High, num2Low);
    conv3ToBCD dutConv3(totalCount, num3High, num3Mid, num3Low);
    showColor isWorking(startWork, ~bottleFull, workLeds);                              
    showColor wrongInput(~startWork & inputErr, ~inputErr, errLeds);
    decoder dec1(num2High, num2Ten);
    decoder dec2(num2Low, num2One);
    decoder dec3(num3High, num3Hund);
    decoder dec4(num3Mid, num3Ten);
    decoder dec5(num3Low, num3One);
    decoder dec6(inputLow, inputOne);
    decoder dec7(inputHigh, inputTen);
    display segDisplay(origCP, num2One,num2Ten, inputOne, inputTen, num3One, num3Ten, num3Hund, anodes, cathnodes);
    conveyer unitConvey(bottleFull & (~allFinished) & startWork, origCP, convOK);
    counter #(6) tabInBottle(tabCounting, convOK, curTabs);
    counter #(9) totalTabs(tabCounting, 0, totalCount);
    counter #(6) bottleCounts(bottleFull, 0, bottlesNum);
    comp isCompleted(bottlesNum, 18, allFinished);
    
    always @(curTabs)
    begin
        if (curTabs == tabPerBottle)
            bottleFull = 1;
        else
            bottleFull = 0;
    end
endmodule

module comp(
    input [5 : 0] a,
    input [5 : 0] b,
    output reg c
);
    always @(a or b)
        if (a >= b && a != 0)
            c = 1;
        else
            c = 0;
endmodule

module counter(cp, reset, result);   //计数器，用于对药片数、瓶数进行计数
parameter N = 8;                            //测试通过
input cp, reset;
output reg [N - 1 : 0] result;

initial
    result = 0;

always @(posedge reset or posedge cp)
    if (reset)
        result = 0;
    else
        result = result + 1;       //测试通过
endmodule

module display(
    input cp,
    input [7 : 0]num2Low,
    input [7 : 0]num2High,
    input [7 : 0]inputLow,
    input [7 : 0]inputHigh,
    input [7 : 0]num3Low,
    input [7 : 0]num3Mid,
    input [7 : 0]num3High,
    output reg [7 : 0]anodes,
    output reg [7 : 0]cathnodes
);

    wire outCP;
    reg [2 : 0] num;
    
    freqDiv #(100000, 17) dut(cp, 0, outCP);
    
    always @(posedge outCP)
    begin
        num = num + 1;
        if (num > 6)
            num = 0;
        case (num)
            0: begin anodes = 8'b11111110; cathnodes = num2Low; end
            1: begin anodes = 8'b11111101; cathnodes = num2High; end
            2: begin anodes = 8'b11101111; cathnodes = num3Low; end
            3: begin anodes = 8'b11011111; cathnodes = num3Mid; end
            4: begin anodes = 8'b10111111; cathnodes = num3High; end
            5: begin anodes = 8'b11111011; cathnodes = inputLow; end
            6: begin anodes = 8'b11110111; cathnodes = inputHigh; end
        endcase
    end
endmodule

module timeCounter(input cp, input stop, output pulse);
    parameter SECONDS = 2;
    wire out1, out2;
    
    freqDiv #(5000, 13) c1(cp, stop, out1);
    freqDiv #(2500, 12) c2(out1, stop, out2);
    freqDiv #(SECONDS, 4) c3(out2, stop, pulse);
endmodule

module freqDiv(cp, stop, pulse);  //测试通过
parameter NUM = 10000;
parameter N = 9;

input cp;
reg [N - 1 : 0] numCount;
input stop;
output reg pulse;

always @(posedge cp)
begin
    if (~stop)
        numCount = numCount + 1;
    if (numCount == NUM)
    begin
        pulse = ~pulse;
        numCount = 0;
    end
end
endmodule

module chooser(
    input signal,
    input [5 : 0] bottles,
    input [5 : 0] tabCount,
    output reg [5 : 0] result
);
    always @(signal or bottles or tabCount)
        if (signal)
            result = bottles;
        else
            result = tabCount;
endmodule

module inputReg(            //输入每瓶药片数，并存储
    input cp,
    input [3 : 0] highBCD,
    input [3 : 0] lowBCD,
    output reg [5 : 0] result, 
    output reg err,
    output reg startWork
);
    reg [6 : 0] num;
    
    initial
        num = 0;
    
    always @(posedge cp)
    if (num == 0)
    begin
        num = highBCD * 10 + lowBCD;
        if (highBCD > 9 || lowBCD > 9 || num > 50 || num == 0)
        begin
            err = 1;
            startWork = 0;
            num = 0;
        end
        else
        begin
            result = num;
            err = 0;
            startWork = 1;          
        end
    end
endmodule

module conv2ToBCD(
    input [5 : 0] num,
    output [4 : 0] tens,
    output [4 : 0] ones 
);
    assign tens = num / 10;
    assign ones = num % 10;
endmodule

module conv3ToBCD(
    input [8 : 0] num,
    output [4 : 0] hundreds,
    output [4 : 0] tens,
    output [4 : 0] ones
);
    assign hundreds = num / 100;
    assign tens = num / 10 % 10;
    assign ones = num % 10;
endmodule

module decoder(
    input [3 : 0] num,
    output reg [7 : 0] cathnodes            //手残将位数写错
);
    always @(num)
        case(num)
            0: cathnodes = 8'b00000011;
            1: cathnodes = 8'b10011111;
            2: cathnodes = 8'b00100101;
            3: cathnodes = 8'b00001101;
            4: cathnodes = 8'b10011001;
            5: cathnodes = 8'b01001001;
            6: cathnodes = 8'b01000001;
            7: cathnodes = 8'b00011111;
            8: cathnodes = 8'b00000001;
            9: cathnodes = 8'b00001001;
        endcase
endmodule

module showColor(
    input working,
    input state,
    output reg [2 : 0]color
);
    always @(working or state)
        if (!working)
            color = 0;
        else if (state)
            color = 3'b010;
        else
            color = 3'b100;
endmodule

module conveyer(
    input run,
    input cp,       //接100MHz，用于计时
    output reg getReady
);
    wire timeOut;
    
    timeCounter #(4) dut(cp, ~run, timeOut);
    always @(posedge timeOut or negedge run)
    if (~run)
        getReady = 0;
    else
        getReady = 1;
endmodule