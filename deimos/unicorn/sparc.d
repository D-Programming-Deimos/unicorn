/* Unicorn Emulator Engine */
/* By Nguyen Anh Quynh <aquynh@gmail.com>, 2015 */

module unicorn.sparc;

import unicorn.unicorn;

extern(C):

/// SPARC registers
enum uc_sparc_reg {
	INVALID = 0,

	F0,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	F13,
	F14,
	F15,
	F16,
	F17,
	F18,
	F19,
	F20,
	F21,
	F22,
	F23,
	F24,
	F25,
	F26,
	F27,
	F28,
	F29,
	F30,
	F31,
	F32,
	F34,
	F36,
	F38,
	F40,
	F42,
	F44,
	F46,
	F48,
	F50,
	F52,
	F54,
	F56,
	F58,
	F60,
	F62,
	FCC0,	// Floating condition codes
	FCC1,
	FCC2,
	FCC3,
	G0,
	G1,
	G2,
	G3,
	G4,
	G5,
	G6,
	G7,
	I0,
	I1,
	I2,
	I3,
	I4,
	I5,
	FP,
	I7,
	ICC,	// Integer condition codes
	L0,
	L1,
	L2,
	L3,
	L4,
	L5,
	L6,
	L7,
	O0,
	O1,
	O2,
	O3,
	O4,
	O5,
	SP,
	O7,
	Y,

	// special register
	XCC,

	// pseudo register
	PC,   // program counter register

	ENDING,   // <-- mark the end of the list of registers

	// extras
	O6 = SP,
	I6 = FP,
}
