`timescale 1ms / 100us

module change(status, checkValue, actualValue, threshold);

input[7:0] actualValue, checkValue;
input[7:0] threshold;
output reg status;

always @(checkValue or actualValue)
begin
    if ((checkValue - actualValue) >= threshold || (actualValue - checkValue) >= threshold)
        status = 1'b1;
    else
        status = 1'b0;
end

endmodule

module master(base, arm, panelBase, panelArm, ldr);

output reg[7:0] base, arm;
output reg[7:0] panelBase, panelArm;
reg[9:0] ldr, _ldr;
reg[31:0] speed;
wire status, baseStatus, armStatus;
reg trigger;

findMax fm(base, arm, status, _ldr, trigger, speed);

change baseChange(baseStatus, base, panelBase, 8'd10);
change armChange(armStatus, arm, panelArm, 8'd10);

always @(base or arm) _ldr = 162 * base * (180 - base) + 162 * arm * (180 - arm); // replace with ADC when ready for deployement

initial
begin
    speed = 10;
    trigger = 0;
    panelArm = 0;
    panelBase = 0;
end

always
begin
    #3000 trigger = ~trigger;
end

always @(posedge status) 
begin
    #5; // short delay
    if (baseStatus == 1) panelBase = base;
    if (armStatus == 1) panelArm = arm;
end

endmodule