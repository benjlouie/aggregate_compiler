/* Team Literally Cool
 *
 * driver.cpp
 *
 * This is the driver file that contains the main function.
 *
 */
#include "driver.h"

int main(int argc, char **argv)
{
	int i;

	// Steps to compiling
	bool lexOnly = false;
	bool parse = true;
	bool typeCheck = true;
	bool buildIR = true;
	bool buildASM = true;
	bool runGCC = true;
	
	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "--lex") == 0)
		{
			// --lex option given
			lexOnly = true;
			parse = false;
			typeCheck = false;
			buildIR = false;
			buildASM = false;
			runGCC = false;
			filename_append = "-lex-meh";
		}
		else if (strcmp(argv[i], "--parse") == 0)
		{
			lexOnly = false;
			parse = true;
			typeCheck = false;
			buildIR = false;
			buildASM = false;
			runGCC = false;
			filename_append = "-ast-meh";
		}
		else if (strcmp(argv[i], "--type") == 0)
		{
			// Type Check
			lexOnly = false;
			parse = true;
			typeCheck = true;
			buildIR = false;
			buildASM = false;
			runGCC = false;
			filename_append = "-type-meh";
		}
		else if (strcmp(argv[i], "--ir") == 0)
		{
			// Stop after IR generation
			lexOnly = false;
			parse = true;
			typeCheck = true;
			buildIR = true;
			buildASM = false;
			runGCC = false;
			filename_append = "-IR-meh";
		}
		else if (strcmp(argv[i], "--asm") == 0)
		{
			// Stop after assembly generation
			lexOnly = false;
			parse = true;
			typeCheck = true;
			buildIR = true;
			buildASM = true;
			runGCC = false;
			filename_append = "-meh.s";
		}
		else
		{
			// Treat as input file name.
			inputFileName = argv[i];
		}
	}

	if (inputFileName == NULL)
	{
		// No input files given
		printf("error: no input file given.\n");
		printHelp(argv[0]);
		exit(1);
	}
	else
	{
		// 1 or more input files given.
		infile = fopen(inputFileName, "r");
	}
	
	if (infile == NULL)
	{
		perror("Cannot open input file");
		exit(1);
	}

	// Set up the input file for the lexer/parser
	yyin = infile;

	// Set up the output file.
	if (filename_append.size() == 0)
		filename_append = "-meh.s";
	//outname = (char *)malloc(sizeof(char) * (strlen(inputFileName) + 10));
	outname = inputFileName;
	outname += filename_append;
	outfile.open(outname, std::fstream::out);

	// Give the outfile to the lexer/parser

	if (lexOnly)
	{
		// Lex Only.
		int lexerOutput;
		yyout = fopen(outname.c_str(), "w");
		if (yyout == NULL)
		{
			perror("Cannot open output file");
			exit(1);
		}
		while ((lexerOutput = yylex()) > 0)
		{
			// This will keep the lexer going.
		}
		fclose(yyout);
		yyout = NULL;
		if (numErrors > 0) {
			exit(1);
		}
	}
	if (parse)
	{
		// Lex and Parse
		if ((typeCheck) || (buildIR) || (buildASM))
		{
			#ifdef __linux__
			yyout = fopen("/dev/null", "w");
			#else
			yyout = fopen("nul", "w");
			#endif

			if (yyout == NULL)
			{
				perror("Cannot open output file");
				exit(1);
			}
			yyparse();
			fclose(yyout);
			yyout = NULL;
			if (numErrors > 0) {
				exit(1);
			}
		}
		else
		{
			yyout = fopen(outname.c_str(), "w");
			if (yyout == NULL)
			{
				perror("Cannot open output file");
				exit(1);
			}
			yyparse();
			fclose(yyout);
			yyout = NULL;
			if (numErrors > 0) {
				exit(1);
			}
		}
	}
	if (typeCheck)
	{
		semant();
		if (numErrors > 0) {
			exit(1);
		}
	}
	if (buildIR)
	{
		// Lex, Parse, Type Check are done.
		// TODO: Insert your calls to IR-building functions here.
		exit(1);
	}
	if (buildASM)
	{
		// Lex, Parse, Typecheck and IR are done.
		// TODO: Insert your calls to build machine assembly here.
		exit(1);
	}

	if (runGCC)
	{
		// This assembles and links your assembly to a binary.
		system("gcc -Wall -g a.s");
	}

	return 0;
}

/**
 * Prints the help and command line arguments for the user
 * @param programName name of the program as it is compiled (argv[0])
 */
void printHelp(char *programName)
{
	printf("%s Compiler, Version 1.0\n", programName);
	printf("Team Literally Cool\n");
	printf("USAGE: \n");
	printf("%s {options} {input_file}\n", programName);
	printf("Options: (all options are optional, but the one specified last takes precendence)\n");
	printf("\t--lex:    stop after lexing.\n");
	printf("\t--parse:  stop after parsing.\n");
	printf("\t--pretty: print the pretty AST.\n");
	printf("\t--type:   stop after type checking.\n");
	printf("\t--ir:     stop after intermediate representation substep of code gen\n");
	printf("\t--asm:    stop after generating assembly\n");
	printf("{input file} COOL source file to compile.\n");
	printf("\n");
}
