%{

/* This is a lexer that will lex and tokenize valid COOL files. */

// This is required to get the enumeration
#include "../src/ast.h"
#include "../bin/parser_cool.h"
#include <map>
#include <string>
#include <limits.h>

/* If you want to disable DEBUGGING, comment out the next line
	and uncomment the one after.
*/

// #define DEBUG(...) fprintf (stdout, __VA_ARGS__)
#define DEBUG(...)

// #define print(...) fprintf (stdout,"%i\n",yylineno); fprintf (stdout, __VA_ARGS__); fprintf(stdout,"\n\n");
#define print(...) fprintf (yyout,"%i\n",yylineno); fprintf(yyout, __VA_ARGS__); fprintf(yyout, "\n");


using namespace std;

// Put here any variables that you may need in the actions.
int num_comments = 0;
map<string, int> token_map = 
{
{"case", CASE },
{"class", CLASS },
{"else", ELSE },
{"esac", ESAC },
{"fi", FI },
{"if", IF },
{"in", IN },
{"inherits", INHERITS },
{"isvoid", ISVOID },
{"let", LET },
{"loop", LOOP },
{"new", NEW },
{"not", NOT },
{"of", OF },
{"pool", POOL },
{"then", THEN },
{"while", WHILE },

};


%}

%option yylineno
%option noyywrap

/* Chars allowable in element and attribute names */
NAME        [a-zA-Z][a-zA-Z0-9:._]*
END_CHAR    [^a-zA-Z0-9_]
TOKEN_WORDS (case|class|else|esac|fi|if|in|inherits|isvoid|let|loop|new|not|of|pool|then|while)
NEWLINE \r?\n
/* Start conditions */
%x COMMENT
%x LINECOMMENT

%%
 /* -----------------  RULES ---------------- */

 /*eats up the -- styles comments*/
-- { DEBUG("Found -- style comment on line %d.\n",yylineno); BEGIN(LINECOMMENT); }

 /* Eats (* style comments */
\(\* {
	num_comments++;
	BEGIN(COMMENT);
	DEBUG("Found start of (* style comment on line %d.\n",yylineno);
}




t(?i:rue) {
	print("true");
	return TRUE;
}

f(?i:alse) {
	print("false");
	return FALSE;
}

(?i:{TOKEN_WORDS}){END_CHAR} {
	char * text = strdup(yytext);
	int len = yyleng;
	if (text[len-1] == '\r')
	{
		text[len-1] = '\0';
		len--;
	}
	if (text[len-1] == '\n')
	{
		// DEBUG("In a token word, newline was next char. pushing back.\n");
		text[len-1] = '\0';
		len--;
		unput('\n');
	}
	if (text[len-1] == ';')
	{
		text[len-1] = '\0';
		len--;
		unput(';');
	}
	if (text[len-1] == ' ')
	{
		text[len-1] = '\0';
		len--;
	}
	if (text[len-1] == '\t')
	{
		text[len-1] = '\0';
		len--;
	}
	
	DEBUG("Found token word \"%s\" on line %d.\n",text,yylineno);
	for (int i = 0; i < len; i++)
		text[i] = tolower(text[i]);
	print("%s",text);
	int retval = token_map[text];
	free(text); 
	return retval;
}

 /* at "@" */
@ {
	print("at");
	return AT;
}

 /* colon  */
: {
	print("colon");
	return COLON;
}

 /* comma  */
, {
	print("comma");
	return COMMA;
}
 /* divide  */
\/ {
	print("divide");
	return DIVIDE;
}

 /* rarrow "=>" */
=> {
	print("rarrow");
	return RARROW;
}

 /* equals  */
= {
	print("equals");
	return EQUALS;
}

 /* identifier  */
[a-z][a-zA-Z0-9_]* {
	print("identifier\n%s",yytext);
	yylval.Name = strdup(yytext);
	return IDENTIFIER;
}

 /* Integers */
[0-9]+ {
	print("integer\n%s",yytext);
	long l = strtol(yytext,NULL,10);
	if ((errno) || (l > INT_MAX))
	{
		printf("ERROR: %d: Lexer: Integer Literal is out of range: \"%s\".\n",yylineno,yytext);
		exit(1);
	}
	else
	{
		yylval.Value = (int)l;
	}
	return INTEGERLITERAL;
}

 /* dot  */
\. {
	print("dot");
	return DOT;
}
 /* larrow "<-" */
\<- {
	print("larrow");
	return LARROW;
}

 /* lbrace "{" */
\{ {
	print("lbrace");
	return LBRACE;
}

 /* le "<=" */
\<= {
	print("le");
	return LE;
}

 /* lparen "(" */
\( {
	print("lparen");
	return LPAREN;
}

 /* lt "<" */
\< {
	print("lt");
	return LT;
}

 /* minus  */
- {
	print("minus");
	return MINUS;
}

 /* plus  */
\+ {
	print("plus");
	return PLUS;
}

 /* rbrace "}" */
\} {
	print("rbrace");
	return RBRACE;
}

 /* rparen ")" */
\) {
	print("rparen");
	return RPAREN;
}

 /*  semi ";" */
; {
	print("semi");
	return SEMI;
}

 /* string */
\"(?:[^"\\]|\\.)*\" {
	yytext[yyleng-1] = '\0';
	print("string\n%s",yytext+1);
	yylval.Name = strdup(yytext+1);
	return STRING;
}

 /* tilde "~" */
~ {
	print("tilde");
	return TILDE;
}


 /* times */
\* {
	print("times");
	return TIMES;
}

 /* type */
[A-Z][a-zA-Z0-9_]* {
	print("type\n%s",yytext);
	yylval.Name = strdup(yytext);
	return TYPE;
}

 /* Start condition for block comments. Be sure to catch ending block comment */
<COMMENT>
{
	\(\* {
		DEBUG("Found embedded (* comment on line %d\n",yylineno);
		num_comments++;
	}

	\*\) {
		DEBUG("Found end of *) style comment on line %d\n",yylineno);
		num_comments--;
		if(num_comments == 0){
			DEBUG("End of comments. Returning to standard parsing.\n");
			BEGIN(INITIAL);			}
	}

	{NEWLINE} { }

	<<EOF>> {
		printf("ERROR: %d: Lexer: Reached EOF before end of comment.\n",yylineno);
		exit(1);
	}

	. { }

} /* End of COMMENT start condition */

<LINECOMMENT>
{
	. { }
	{NEWLINE} {BEGIN(INITIAL);}
	<<EOF>> { DEBUG("Reached EOF in line comment.\n"); return 0; }
}

[ \t\n\r] {}

 /* End of File */
<<EOF>> {
	DEBUG("End of file. Parse successful.\n\n");
	return 0; // to tell the main that we are done.
}

 /* Match any other character. This should be the last thing in the file, as it represents a fail state. */
. {
	printf("ERROR: %d: Lexer: Invalid character \"%s\".\n",yylineno,yytext);
	exit(1);
}
%%
