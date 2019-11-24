`timescale 1ms / 100us

// Module to check if deviation is greater than a given threshold
// Output - status = 1 if deviation is greater then threshold
// Output - status = 0 if deviation is smaller then threshold

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

// The top level master module
// Output - base        -   the angle of base motor
//          arm         -   the angle of arm motor
//          panelBase   -   the solar panel base angle
//          panelArm    -   the solar panel arm angle
// Input    ldr         -   the intensity of light incident on the LDR

module master(base, arm, panelBase, panelArm, ldr);

output[7:0] base, arm;
output reg[7:0] panelBase, panelArm;
input[9:0] ldr;
reg[9:0] _ldr;
reg[31:0] speed;
wire status, baseStatus, armStatus;
reg trigger;

findMax fm(base, arm, status, _ldr, trigger, speed);

// Use change module to figure out if the difference in angle is significant
change baseChange(baseStatus, base, panelBase, 8'd10);
change armChange(armStatus, arm, panelArm, 8'd10);

always @(base or arm) _ldr = base + arm; // replace with ADC when ready for deployement

initial
begin
    speed = 10;
    trigger = 0;
    panelArm = 0;
    panelBase = 0;
end

always
begin
    // Toggle trigger every 3000ms
    // i.e. trigger every 6000ms
    #3000 trigger = ~trigger;
end

always @(posedge status) 
begin
    #5; // short delay to make sure angle is refreshed
    if (baseStatus == 1) panelBase = base;
    if (armStatus == 1) panelArm = arm;
end

endmodule