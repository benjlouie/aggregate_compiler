/* Team Literally Cool
 *
 * driver.h
 *
 * This is the header file for driver.
 *
 */

#ifndef __DRIVER_H_
#define __DRIVER_H_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vector>
#include <fstream>
#include <unordered_map>
#include "../compiler_semantics/semant.h"
#include "../src/ast.h"

extern int yylineno;
extern int nelements;
extern FILE *yyin;
extern FILE *yyout;
extern Node *root;


char * inputFileName = NULL;
FILE *infile = NULL;
fstream outfile;
string outname;
string filename_append;
//<className, inheritsFrom>
std::unordered_map<std::string, std::string> globalTypeList;
SymbolTable *globalSymTable;

void printHelp(char *);
int yylex(void);
int yyparse(void);
void yylex_destroy(void);

#endif /* __DRIVER_H_ */
