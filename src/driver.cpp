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
	bool exec = false;
	bool prettyprint = false;

	
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
		else if (strcmp(argv[i], "--pretty") == 0) {
			prettyprint = true;
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
		}
		else if (strcmp(argv[i], "--run") == 0)
		{
			// Stop after assembly generation
			lexOnly = false;
			parse = true;
			typeCheck = true;
			buildIR = true;
			buildASM = true;
			runGCC = true;
			exec = true;
		}
		else
		{
			// Treat as input file name.
			inputFileName = argv[i];
			inFileName = inputFileName; //need a string for later operations, char * for existing ones
		}
	}

	if (inFileName == "")
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
	if (filename_append.size() == 0) {
		if (inFileName.substr(inFileName.length() - 3, 3) == ".cl")
			outname = inFileName.substr(0, inFileName.length() - 3) + ".s";
		else
			outname = inFileName + "-sj.s";
	} else {
		if (inFileName.substr(inFileName.length() - 3, 3) == ".cl") {
			outname = inFileName.substr(0, inFileName.length() - 3) + filename_append;
		} else {
			outname = inFileName + filename_append;
		}
	}

	outfile.open(outname, ios::out);

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
		if (prettyprint) {
			root->print();
		}
		if (numErrors > 0) {
			exit(1);
		}
		
	}

	//opts
	eliminateUnreachable();
	if (buildASM)
	{
		// Lex, Parse, Typecheck are done
		code(outfile);
	}
	outfile.close();

	if (runGCC)
	{
		// This assembles and links your assembly to a binary.
#ifdef __unix
		int pid = fork();
		if (pid == 0) {
			return system(("gcc -g -Wall " + outname).c_str());
		}
		else {
			if (exec) {
				int returnStatus;
				waitpid(pid, &returnStatus, 0);
				if (returnStatus == 0) {
					system("./a.out");
				}
				else {
					cerr << "Unable to assemble program " << returnStatus << endl;
				}
			}
		}
#else
		system(("gcc -g -Wall " + outname).c_str());
#endif
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
	printf("\t--run:    Generate assembly, assembly, and execute\n");
	printf("{input file} COOL source file to compile.\n");
	printf("\n");
}
