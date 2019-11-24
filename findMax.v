`timescale 1ms / 100us

// Module to find angle with maximum angle
// Output - base    -   angle of base motor
//          arm     -   angle of amr motor
//          status  -   outputs 1 when the process if complete
// Input -  trigger -   triggers the process
//          ldr     -   light intensity
//          speed   -   time in which angle changes by 1 degreed
module findMax(base, arm, status, ldr, trigger, speed);

input[9:0] ldr;
input[31:0] speed;
input trigger;
output reg[7:0] base, arm;
output reg status;

reg[8:0] maxA, maxB;
reg[10:0] maxI;

integer i, j;

initial
begin 
    base = 0;
    arm = 0;
end

// When posedge of trigger is encountered find maximum angle
always @(posedge trigger)
begin
    status = 1'b0;
    maxA = 0;
    maxB = 0;
    arm = 0;
    base = 0;
    maxI = 0;
    #100; // short delay
    $monitor("ldr=%10d, maxI=%3d, maxA=%8d, maxB=%8d, arm=%3d, base=%3d", ldr, maxI, maxA, maxB, arm, base); 
    for(i=0;i<=180;i=i+1)
    begin
        base = i;
        if (maxI < ldr)
        begin
            maxI = ldr;
            maxB = base;
        end
        for(j=0;j<speed;j=j+1) #1;
    end
    base = maxB;
    arm = 0;
    maxA = 0;
    maxI = 0;
    #100;
    for(i=0;i<=180;i=i+1)
    begin
        arm = i;
        if (maxI < ldr)
        begin
            maxI = ldr;
            maxA = arm;
        end
        for(j=0;j<speed;j=j+1) #1;
    end
    arm = maxA;
    status = 1'b1;
end

endmodule