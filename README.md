Intra-Function Code Generation
Author: Jin Chul Ann
Email: jinchulann93@gmail.com
Language: Ruby

Line Count For Implementation 1095

		22	token.rb
		303 scanner.rb
		770 parser.rb

Run:
	./parser.rb input_files
	OR
	./parser.rb input_files output_files

	NOTE:if no output_files is given, puts output in "output.c" by default if parsing was successful

Functionality:

		The parser implements LL(1) grammar (some parts LL(3)) using recursive descent method. The grammar is same as the previous part of the assignment but only has change of removing while and if statements to gotos, and only using gvar and lvar.
		If the parsing was sucessful it returns number of functions, variables and statements in the input_file. However, when it fails, it returns error and does not produce an output file.

	Design decision:

		The grammar was slightly modified to allow as much LL(1) possible. Some grammar includes "_tail"

	Test Cases:

		Test Cases including output files

		➜  jann_intracode  ./parser.rb ab.c
		Pass
			Variables: 3
			Functions: 1
			Statements: 4
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		19 s= 1
		➜  jann_intracode  ./parser.rb automaton.c
		Pass
			Variables: 5
			Functions: 6
			Statements: 48
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		Give me a number (-1 to quit): 1
		Give me a number (-1 to quit): 1
		Give me a number (-1 to quit): 0
		Give me a number (-1 to quit): 0
		Give me a number (-1 to quit): -1
		You gave me an even number of 0's.
		You gave me an even number of 1's.
		I therefore accept this input.
		➜  jann_intracode  ./parser.rb binrep.c
		Pass
			Variables: 2
			Functions: 2
			Statements: 21
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		Give me a number: 255
		The binary representation of: 255
		is: 11111111

		➜  jann_intracode  ./parser.rb fibonacci.c
		Error1
		➜  jann_intracode  ./parser.rb loop_while.c
		Pass
			Variables: 1
			Functions: 1
			Statements: 5
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		hello
		hello
		hello
		hello
		hello
		hello
		hello
		hello
		hello
		hello
		➜  jann_intracode  ./parser.rb mandel.c
		Pass
			Variables: 8
			Functions: 6
			Statements: 34
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output


		                                                  X
		                                               XXXXX
		                                               XXXXX
		                                               XXXXX
		                                                   X
		                                       XX   XXXXXXXXXXXX
		                                       XX XXXXXXXXXXXXXXXX XX
		                                       XXXXXXXXXXXXXXXXXXXXXX
		                                     XXXXXXXXXXXXXXXXXXXXXXX
		                                      XXXXXXXXXXXXXXXXXXXXXXX
		                                     XXXXXXXXXXXXXXXXXXXXXXXXXX
		                                    XXXXXXXXXXXXXXXXXXXXXXXXXX
		                        X XXX      XXXXXXXXXXXXXXXXXXXXXXXXXXX
		                        XXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXX
		                      XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                   XX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                   XX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                      XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		                        XXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXX
		                       XX XXX      XXXXXXXXXXXXXXXXXXXXXXXXXXX
		                                    XXXXXXXXXXXXXXXXXXXXXXXXXX
		                                     XXXXXXXXXXXXXXXXXXXXXXXXXX
		                                      XXXXXXXXXXXXXXXXXXXXXXX
		                                     XXXXXXXXXXXXXXXXXXXXXXX
		                                        XXXXXXXXXXXXXXXXXXXXX
		                                       XXXXXXXXXXXXXXXXXXX XX
		                                       XX   XXXXXXXXXXXX

		                                                XXXX
		                                               XXXXX
		                                               XXXXX
		                                                  X

		➜  jann_intracode  ./parser.rb MeaningOfLife.c
		Pass
			Variables: 1
			Functions: 2
			Statements: 7
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		Magic positive number is 42
		The meaning of Life is 42
		➜  jann_intracode  ./parser.rb tax.c
		Pass
			Variables: 26
			Functions: 2
			Statements: 101
		➜  jann_intracode  gcc -o output output.c
		➜  jann_intracode  ./output
		Welcome to the United States 1040 federal income tax program.
		(Note: this isn't the real 1040 form. If you try to submit your
		taxes this way, you'll get what you deserve!

		Answer the following questions to determine what you owe.

		Total wages, salary, and tips? 20000
		Taxable interest (such as from bank accounts)? 200
		Unemployment compensation, qualified state tuition, and Alaska
		Permanent Fund dividends? 20
		Your adjusted gross income is: 20220
		Enter <1> if your parents or someone else can claim you on their return.
		Enter <0> otherwise: 0
		Enter <1> if you are single, <0> if you are married: 1
		Your taxable income is: 7270
		Enter the amount of Federal income tax withheld: 2100
		Enter <1> if you get an earned income credit (EIC); enter 0 otherwise: 0
		Your total tax payments amount to: 2100
		Your total tax liability is: 2036
		Congratulations, you get a tax refund of $64
		7270
		2100
		2036
		0
		159698944
		32767
		0
		0
		Thank you for using ez-tax.

		NOTE that tax.c is a bit off. fibonacci.c cannot be compiled.


Files:

		MeaningOfLife.c
	-	ParserGrammar.txt
	-	README
		ab.c
		automaton.c
		binrep.c
		fibonacci.c
		loop_for.c
		loop_while.c
		mandel.c
	-	parser.rb
	-	scanner.rb
		tax.c
	-	token.rb

	"-" noted files are implemented/written files; whereas the other files are testing .c files.
