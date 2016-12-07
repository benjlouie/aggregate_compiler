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
#include <sys/types.h>
#include <vector>
#include <fstream>
#include <unordered_map>
#include "../compiler_semantics/semant.h"
#include "../src/ast.h"
#include "../compiler_codegen/codegen.h"
#include "../compiler_codegen/vTable.h"
#include "../compiler_semantics/unreachable.h"

#ifdef __unix
#include <sys/wait.h>
#include <unistd.h>
#endif

extern int yylineno;
extern int nelements;
extern FILE *yyin;
extern FILE *yyout;
extern Node *root;
extern int numErrors;


char * inputFileName;
string inFileName;
FILE *infile = NULL;
fstream outfile;
string outname;
string filename_append;
//<className, inheritsFrom>
std::unordered_map<std::string, std::string> globalTypeList;
SymbolTable *globalSymTable;
vTable *globalVTable;
unordered_map<size_t, string> globalStringTable;
int whileLabelCount = 0;
int ifLabelCount = 0;
int caseLabelCount = 0;

void printHelp(char *);
int yylex(void);
int yyparse(void);
void yylex_destroy(void);

#endif /* __DRIVER_H_ */
