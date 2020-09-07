# NumberCruncher

Number cruncher is a program written in assembly. The program promps user to enter ten valid signed decimal integers which the program receives as a string. The string 
is converted to signed integers and validated. Once ten valid integers have been entered, the valid inputs will be displayed followed by the sum and average. 

This program utilizes macros and pushes all porcedure parameters onto the stack. <br/><br/>


An example of running program:<br/>

Please provide 10 signed decimal integers. <br/>
Each number needs to be small enough to fit inside a 32 bit register.<br/>
After you have finished inputting the raw numbers I will display a list<br/>
of the integers, their sum, and their average value.<br/><br/>

Please enter an signed number: 156<br/>
Please enter an signed number: 51d6fd<br/>
ERROR: You did not enter a signed number or your number was too big.<br/>
Please try again: 34<br/>
Please enter a signed number: -186<br/>
Please enter a signed number: 115616148561615630<br/>
ERROR: You did not enter an signed number or your number was too big.<br/>
Please try again: -145<br/>
Please enter a signed number: 5<br/>
Please enter a signed number: +23<br/>
Please enter a signed number: 51<br/>
Please enter a signed number: 0<br/>
Please enter a signed number: 56<br/>
Please enter a signed number: 11<br/><br/>

You entered the following numbers:<br/>
156, 34, -186, -145, 5, 23, 51, 0, 56, 11<br/>
The sum of these numbers is: 5<br/>
The rounded average is: 1<br/>

Thanks for playing!
