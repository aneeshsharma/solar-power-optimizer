`timescale 1us / 10ns

module pwmOut(pwm, angle);

input[7:0] angle;
output reg pwm;

integer width, i;
reg cycle;

initial cycle = 0;

always #20000 cycle = ~cycle;

always @(cycle)
begin
    // According to SG90 servo specification
    // servo accepts 20ms pwm period with 1-2ms duty cycle
    width = angle * (1000/180) + 1000;
    pwm = 1'b1;
    // duty cycle
    for(i=0;i<width;i=i+1) #1;
    pwm = 1'b0;
end

endmodule
