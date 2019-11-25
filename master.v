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

// The control unit module
// Output - base        -   the angle of base motor
//          arm         -   the angle of arm motor
//          panelBase   -   the solar panel base angle
//          panelArm    -   the solar panel arm angle
// Input    ldr         -   the intensity of light incident on the LDR
module controlUnit(base, arm, panelBase, panelArm, ldr);

output[7:0] base, arm;
output reg[7:0] panelBase, panelArm;
input[9:0] ldr;
reg[9:0] _ldr;
reg[31:0] speed;
wire status, baseStatus, armStatus;
reg trigger;

findMax fm(base, arm, status, ldr, trigger, speed);

// Use change module to figure out if the difference in angle is significant
change baseChange(baseStatus, base, panelBase, 8'd30);
change armChange(armStatus, arm, panelArm, 8'd30);

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
    #9000 trigger = ~trigger;
    $display("arm = %d, base = %d", arm, base);
end

always @(posedge status) 
begin
    #5; // short delay to make sure angle is refreshed
    if (baseStatus == 1) panelBase = base;
    if (armStatus == 1) panelArm = arm;
end

endmodule

// Top level master module
// Output - base        -   the pwm output for base motor
//          arm         -   the pwm output for arm motor
//          panelBase   -   the pwm output for solar panel base motor
//          panelArm    -   the pwm output for solar panel arm motor
// Input    ldr         -   the intensity of light incident on the LDR
module master(base, arm, panelBase, panelArm, ldr);

input[9:0] ldr;
reg[9:0] _ldr;
output base, arm, panelBase, panelArm;

wire[7:0] baseD, armD, panelBaseD, panelArmD;

controlUnit cu(baseD, armD, panelBaseD, panelArmD, _ldr);

pwmOut baseOut(base, baseD);
pwmOut armOut(arm, armD);
pwmOut panelBaseOut(panelBase, panelBaseD);
pwmOut panelArmOut(panelArm, panelArmD);

always @(baseD or armD) _ldr = baseD + armD;

endmodule