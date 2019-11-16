module master;

wire[8:0] base, arm;
reg[10:0] ldr;
reg[32:0] speed;
wire status;
reg trigger;

findMax fm(base, arm, status, ldr, trigger, speed);

always @(base or arm) ldr = base + arm;

initial speed = 10;
initial trigger = 0;

always
begin
    #4000 trigger = ~trigger;
end

endmodule