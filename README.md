# Solar Power Optimiser

The objective of this project is to use a hardware implementation in verilog to obtain the direction of sun rays in order to optimise the power output of a solar panel
## Procedure

The angle is determined by first checking along North-South axis and finding the position of maximum incident intensity. Then along the East-West axis.

2 Servo motors are placed perpendicular to one another to cover both the axis –
1. First the motor along the East-West axis is moved with a step size of 1° and a given speed (10ms for a degree by default) to rotate the LDR to find the maximum intensity position.
2. The first motor is then set to that maximum intensity angle and then the base motor is moved along the North-South axis to again rotate the LDR and find the maximum intensity position.
3. The final position is the overall position of maximum intensity.

The procedure above finds the direction of sun rays. To monitor the Sun’s position, this procedure is called at regular time intervals (interval depends on the application).
This direction output can be used to set the solar panels in the correct direction in order to maximize power output. The solar panels are moved only if the difference in their angle and the sun rays’ direction is significant enough. The small size of the actual hardware that determines the sun rays’ direction minimizes the power consumption and the solar panels have to be moved only when power gain is significant.

## Implementation

The given algorithm is implemented using Verilog Hardware Description Language with the help of behavioural level modelling. The advantage of using a Hardware Description Language is that – if we use hardware to implement this algorithm the power consumption would be drastically reduced, which is a great advantage for a project that’s based on power optimisation.

## The Modules

### The `findMax` module

The `findMax` module finds the angle which receives the maximum intensity. Its defination looks like -

`module findMax(base, arm, status, ldr, trigger, speed);`

Here,
Outputs base    -   output base motor angle
        arm     -   output arm motor angle
        status  -   output status of the process of finding the position of maximum intensity
                    1   -   process is complete
                    0   -   process is under progress

Inputs  ldr     -   input value of the relative intensity of light being received on the LDR
        trigger -   trigger input - the process start on positive edge of trigger - used to trigger the process
        speed   -   speed of motor rotation i.e. time for a degree change in angle

The module starts the process of finding the maximum intensity position as soon as a postive edge is received on trigger input. The status is set to 0 until the process is complete thereafter it is set to 1 indicating that the process is complete.

## The `pwmOut` module

The `pwmOut` module takes an angle value using an 8-bit number and outputs the corresponding PWM output that is required by the servo motor. The signal is according to the SG90 servo motor - <add link>
The defination look as -

`module pwmOut(pwm, angle);`

Here,
Output  pwm     -   the output PWM signal for the SG90 servo
Input   angle   -   the angle at which the motor is to be set

## The `controlUnit` module

As the name suggests this module controls the functionality of the system and is used to operate the `findMax` module and call it at regular intervals of time in order to keep track of sun rays' direction.
In the current implementation the `findMax` module is called every 18 seconds. The solar panel direction is update if and only if the difference in current position and the new position of the sun rays is greater then a certain threshold value (currently set to 10 degrees in the current implementation).

The defination of this module is -

`module controlUnit(base, arm, panelBase, panelArm, ldr);`

Here,
Output  base        -   the angle value of the base servo
        arm         -   the angle value of the arm servo
        panelBase   -   the angle value for the solar panel base
        panelArm    -   the angle value for the solar panel arm
Input   ldr         -   the relative intensity value received at the LDR

## The `master` module

The `master` module is the Top Level module for this project. It integrates the `controlUnit` with the `pwmOut` module and completes the system in order to correctly output the angles to the corresponding servos.

The defination is -

`module master(base, arm, panelBase, panelArm, ldr)`

Here,
Output  base        -   the PWM output for the base servo
        arm         -   the PWM output for the arm servo
        panelBase   -   the PWM output for the solar panel base servo
        panelArm    -   the PWM output for the solar panel arm servo
Input   ldr         -   the input value for the relative light intenisty received at the LDR

## How to simulate?

The project can be simulated using the Top Level module `master` itself. The code has been tested and verified using ModelSim.
