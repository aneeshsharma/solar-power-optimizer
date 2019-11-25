module stimulus;

wire base, arm, panelBase, panelArm;
reg[9:0] ldr;

master m1(base, arm, panelBase, panelArm, ldr);

endmodule
