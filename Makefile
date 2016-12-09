# Team Swear Jar
# Makefile

# This stuff shouldn't change
CC=gcc
CXX=g++
CXXFLAGS=-Wall -g -std=c++11
CFLAGS=-Wall -g -std=c++11
SRCDIR=src
BINDIR=bin

#To work with our Git Submodules
LEXDIR=compiler_scanner
PARSEDIR=compiler_parser
SEMDIR=compiler_semantics
CODEDIR=compiler_codegen
TESTDIR=compiler_tests

#Lexical Stuff
LEX = flex
LEXFILE = ${LEXDIR}/cool.l
LEXC = ${BINDIR}/lex.yy.c
LEXO = ${BINDIR}/lex.yy.o
LEXFLAGS =

#Parsing Files
PARSERCPP=${BINDIR}/parser_cool.cpp 
PARSERH=${BINDIR}/parser_cool.h
PARSERO=${BINDIR}/parser_cool.o
PARSERYPP=${PARSEDIR}/cool.ypp

#Semantic Analysis
SEMCPP=${SEMDIR}/semant.cpp 
SEMH=${SEMDIR}/semant.h 
SEMO=${SEMDIR}/semant.o

SEM_SYMBOLTABLECPP=${SEMDIR}/symbolTable.cpp
SEM_SYMBOLTABLEH=${SEMDIR}/symbolTable.h
SEM_SYMBOLTABLEO=${SEMDIR}/symbolTable.o

SEM_CLASSINHERITANCECPP=${SEMDIR}/classInheritance.cpp
SEM_CLASSINHERITANCEH=${SEMDIR}/classInheritance.h
SEM_CLASSINHERITANCEO=${SEMDIR}/classInheritance.o

SEM_SCOPINGCPP=${SEMDIR}/scoping.cpp
SEM_SCOPINGH=${SEMDIR}/scoping.h
SEM_SCOPINGO=${SEMDIR}/scoping.o

SEM_TYPECPP=${SEMDIR}/typeCheck.cpp
SEM_TYPEH=${SEMDIR}/typeCheck.h
SEM_TYPEO=${SEMDIR}/typeCheck.o

SEM_UCECPP=${SEMDIR}/unreachable.cpp
SEM_UCEO=${SEMDIR}/unreachable.o
SEM_UCEH=${SEMDIR}/unreachable.h

#Code Generation
CGENCPP=${CODEDIR}/codegen.cpp
CGENH=${CODEDIR}/codegen.h
CGENO=${BINDIR}/codegen.o

CGEN_IRCPP=${CODEDIR}/linearIR.cpp
CGEN_IRH=${CODEDIR}/linearIR.h
CGEN_IRO=${BINDIR}/linearIR.o

CGEN_VTCPP=${CODEDIR}/vTable.cpp
CGEN_VTH=${CODEDIR}/vTable.h
CGEN_VTO=${BINDIR}/vTable.o

CGEN_ILCPP=${CODEDIR}/InstructionList.cpp
CGEN_ILH=${CODEDIR}/InstructionList.h
CGEN_ILO=${BINDIR}/InstructionList.o

SHELL='/bin/bash'
REF_COMPILER="ref_cool"

# Change the name of your compiler here.
COMPILER_BIN="swearjar"

# As you create more classes, add them here to make sure they get compiled and linked.
# Arguments are compiled in order, from left to right.
OBJECTS = tree ast testtree

# The rest of this shouldn't change.
_TARGETS=$(addprefix $(BINDIR)/, $(addsuffix .o, ${OBJECTS}))


${BINDIR}/%.o: ${SRCDIR}/%.cpp ${SRCDIR}/%.h
	@echo Building $*
	${CXX} ${CXXFLAGS} -c ${SRCDIR}/$*.cpp -o $@
	
all: compiler
	@echo -e "\033[0;32m    Build successful. ${COMPILER_BIN} compiler ready for use. \033[0m"

compiler: preliminary ${LEXO} ${PARSERO} ${_TARGETS} ${BINDIR}/driver.o ${SEMO} ${SEM_SYMBOLTABLEO} ${SEM_CLASSINHERITANCEO} ${SEM_SCOPINGO} ${SEM_TYPEO} ${SEM_UCEO} ${CGENO} ${CGEN_VTO} ${CGEN_IRO} ${CGEN_ILO}
	@echo Done compiling individual objects. Assembling pieces...
	${CXX} ${CXXFLAGS} -o ${COMPILER_BIN} ${LEXO} ${PARSERO} ${SEMO} ${SEM_SYMBOLTABLEO} ${SEM_CLASSINHERITANCEO} ${SEM_SCOPINGO} ${SEM_TYPEO} ${SEM_UCEO} ${CGENO} ${CGEN_VTO} ${CGEN_IRO} ${CGEN_ILO} ${_TARGETS} ${BINDIR}/driver.o

${LEXO}: ${LEXC} ${PARSERH}
	${CXX} ${CXXFLAGS} -c ${LEXC} -o ${LEXO}

${LEXC}: ${LEXFILE}
	$(LEX) -o $@ $(LEXFLAGS) $^
	
${PARSERCPP} ${PARSERH}: ${PARSERYPP}
	bison --defines=${PARSERH} ${PARSERYPP} -o ${PARSERCPP}

bisonerr: ${PARSERYPP}
	bison -v ${PARSERYPP}

#Semantic Analysis
${SEMO}: ${SEMCPP} ${SEMH} 
	${CXX} ${CXXFLAGS} -c ${SEMCPP} -o ${SEMO}
    
${SEM_SYMBOLTABLEO}: ${SEM_SYMBOLTABLEH} ${SEM_SYMBOLTABLECPP}
	${CXX} ${CXXFLAGS} -c ${SEM_SYMBOLTABLECPP} -o $@

${SEM_CLASSINHERITANCEO}: ${SEM_CLASSINHERITANCECPP} ${SEM_CLASSINHERITANCEH}
	${CXX} ${CXXFLAGS} -c ${SEM_CLASSINHERITANCECPP} -o $@
    
${SEM_SCOPINGO}: ${SEM_SCOPINGCPP} ${SEM_SCOPINGH}
	${CXX} ${CXXFLAGS} -c ${SEM_SCOPINGCPP} -o $@

${SEM_TYPEO}: ${SEM_TYPECPP} ${SEM_TYPEH}
	${CXX} ${CXXFLAGS} -c ${SEM_TYPECPP} -o $@

${SEM_UCEO}: ${SEM_UCECPP} ${SEM_UCEH}
	${CXX} ${CXXFLAGS} -c ${SEM_UCECPP} -o $@

#Code Generation
${CGENO}: ${CGENH} ${CGENCPP}
	${CXX} ${CXXFLAGS} -c ${CGENCPP} -o $@

${CGEN_IRO}: ${CGEN_IRH} ${CGEN_IRCPP}
	${CXX} ${CXXFLAGS} -c ${CGEN_IRCPP} -o $@

${CGEN_VTO}: ${CGEN_VTH} ${CGEN_VTCPP}
	${CXX} ${CXXFLAGS} -c ${CGEN_VTCPP} -o $@

${CGEN_ILO}: ${CGEN_ILH} ${CGEN_ILCPP}
	${CXX} ${CXXFLAGS} -c ${CGEN_ILCPP} -o $@
    
preliminary:
	@echo Checking if bin directory exists.
	@ if [ ! -d "bin" ]; then mkdir bin; fi
	@echo Checking for G++
	@ g++ --version > /dev/null
	@echo Checking for flex
	@ flex --version > /dev/null
	@echo Checking for bison
	@ bison --version > /dev/null
	@echo Checking for wget
	@ wget --version > /dev/null
	@echo Checking for reference compiler.
	@ if [ ! -e ${REF_COMPILER} ]; then if [ `uname -m` == "x86_64" ]; then echo "Downloading 64 bit reference compiler."; wget http://infohost.nmt.edu/~ssalinas/cool/cool64 -O ${REF_COMPILER}; else echo "Downloading 32 bit reference compiler"; wget http://infohost.nmt.edu/~ssalinas/cool/cool32 -O ${REF_COMPILER}; fi; fi; chmod +x ${REF_COMPILER};
	@echo Preliminary environment set up. Continuing compilation.

test: compiler
	#@echo Compiling unit tests...
	#${CXX} ${CXXFLAGS} ${SRCDIR}/tests.cpp ${_TARGETS} -o ${TESTDIR}/tests
	#@echo Running unit tests...
	#@echo
	#@ ${BINDIR}/tests
	@echo Running integration tests...
	@ ./test.sh
	@echo
	@echo -e "\033[0;32m   +=====================================+ \033[0m"
	@echo -e "\033[0;32m   |========= All Tests Passed. =========| \033[0m"
	@echo -e "\033[0;32m   +=====================================+ \033[0m"
	@echo

clean:
	rm -rf bin/ ${COMPILER_BIN} cool.output cool.tab.cpp ${SEMDIR}/*.o

