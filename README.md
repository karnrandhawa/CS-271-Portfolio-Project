# CS-271-Portfolio-Project

Implements two macros for string processing.

Implements two procedures for signed integers which use string primitive instructions. 

Invokes a macro to get user input in the form of a string of digits. Converts (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc). Stores this one value in a memory variable (output parameter, by reference). 

Converts a numeric SDWORD value (input parameter, by value) to a string of ASCII digits. Invokes macro to print the ASCII representation of the SDWORD value to the output.

Program takes 10 signed integers from a user (small enough to fit in a 32-bit register), validates the input, prints the input, and prints the sum and truncated average. 
