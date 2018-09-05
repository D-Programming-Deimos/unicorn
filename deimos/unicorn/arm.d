/* Unicorn Engine */
/* By Nguyen Anh Quynh <aquynh@gmail.com>, 2015 */

module unicorn.arm;

import unicorn.unicorn;

extern(C):

/// ARM registers
enum uc_arm_reg {
	INVALID = 0,
	APSR,
	APSR_NZCV,
	CPSR,
	FPEXC,
	FPINST,
	FPSCR,
	FPSCR_NZCV,
	FPSID,
	ITSTATE,
	LR,
	PC,
	SP,
	SPSR,
	D0,
	D1,
	D2,
	D3,
	D4,
	D5,
	D6,
	D7,
	D8,
	D9,
	D10,
	D11,
	D12,
	D13,
	D14,
	D15,
	D16,
	D17,
	D18,
	D19,
	D20,
	D21,
	D22,
	D23,
	D24,
	D25,
	D26,
	D27,
	D28,
	D29,
	D30,
	D31,
	FPINST2,
	MVFR0,
	MVFR1,
	MVFR2,
	Q0,
	Q1,
	Q2,
	Q3,
	Q4,
	Q5,
	Q6,
	Q7,
	Q8,
	Q9,
	Q10,
	Q11,
	Q12,
	Q13,
	Q14,
	Q15,
	R0,
	R1,
	R2,
	R3,
	R4,
	R5,
	R6,
	R7,
	R8,
	R9,
	R10,
	R11,
	R12,
	S0,
	S1,
	S2,
	S3,
	S4,
	S5,
	S6,
	S7,
	S8,
	S9,
	S10,
	S11,
	S12,
	S13,
	S14,
	S15,
	S16,
	S17,
	S18,
	S19,
	S20,
	S21,
	S22,
	S23,
	S24,
	S25,
	S26,
	S27,
	S28,
	S29,
	S30,
	S31,

	C1_C0_2,
	C13_C0_2,
	C13_C0_3,

	ENDING,		// <-- mark the end of the list or registers

	//> alias registers
	R13 = SP,
	R14 = LR,
	R15 = PC,

	SB = R9,
	SL = R10,
	FP = R11,
	IP = R12,
}
