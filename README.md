# NumberCruncher

Number cruncher is a program written in assembly. The program promps user to enter ten valid signed decimal integers which the program receives as a string. The string 
is converted to signed integers and validated. Once ten valid integers have been entered, the valid inputs will be displayed followed by the sum and average. 

This program utilizes macros and pushes all porcedure parameters onto the stack. 


An example of running program:

Please provide 10 signed decimal integers.
Each number needs to be small enough to fit inside a 32 bit register.
After you have finished inputting the raw numbers I will display a list
of the integers, their sum, and their average value.

Please enter an signed number: 156
Please enter an signed number: 51d6fd
ERROR: You did not enter a signed number or your number was too big.
Please try again: 34
Please enter a signed number: -186
Please enter a signed number: 115616148561615630
ERROR: You did not enter an signed number or your number was too big.
Please try again: -145
Please enter a signed number: 5
Please enter a signed number: +23
Please enter a signed number: 51
Please enter a signed number: 0
Please enter a signed number: 56
Please enter a signed number: 11

You entered the following numbers:
156, 34, -186, -145, 5, 23, 51, 0, 56, 11
The sum of these numbers is: 5
The rounded average is: 1

Thanks for playing!

