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
#include "ast.h"

extern int yylineno;
extern int nelements;
extern FILE *yyin;
extern FILE *yyout;
extern Node *root;


FILE *infile = NULL;
fstream outfile;
char *outname = NULL;
char *filename_append = NULL;

void printHelp(char *);
int yylex(void);
int yyparse(void);
void yylex_destroy(void);

#endif /* __DRIVER_H_ */
