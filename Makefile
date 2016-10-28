# Team Regi Holiman
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

LEX = flex
LEXFILE = ${LEXDIR}/cool.l
LEXC = ${BINDIR}/lex.yy.c
LEXO = ${BINDIR}/lex.yy.o
LEXFLAGS =

PARSERCPP=${BINDIR}/parser_cool.cpp 
PARSERH=${BINDIR}/parser_cool.h
PARSERO=${BINDIR}/parser_cool.o
PARSERYPP=${PARSEDIR}/cool.ypp

SHELL='/bin/bash'
REF_COMPILER="ref_cool"

# Change the name of your compiler here.
COMPILER_BIN="holiman"

# As you create more classes, add them here to make sure they get compiled and linked.
# Arguments are compiled in order, from left to right.
OBJECTS = tree ast testtree

# The rest of this shouldn't change.
_TARGETS=$(addprefix $(BINDIR)/, $(addsuffix .o, ${OBJECTS}))


${BINDIR}/%.o: ${SRCDIR}/%.cpp ${SRCDIR}/%.h
	@echo Building $*
	${CXX} ${CXXFLAGS} -c ${SRCDIR}/$*.cpp -o $@
	
all: clean compiler
	@echo -e "\033[0;32m    Build successful. Regi compiler ready for use. \033[0m"

compiler: preliminary ${LEXO} ${PARSERO} ${_TARGETS} ${BINDIR}/driver.o
	@echo Done compiling individual objects. Assembling pieces...
	${CXX} ${CXXFLAGS} -o ${COMPILER_BIN} ${LEXO} ${PARSERO} ${_TARGETS} ${BINDIR}/driver.o

${LEXO}: ${LEXC} ${PARSERH}
	${CXX} ${CXXFLAGS} -c ${LEXC} -o ${LEXO}

${LEXC}: ${LEXFILE}
	$(LEX) -o $@ $(LEXFLAGS) $^
	
${PARSERCPP} ${PARSERH}: ${PARSERYPP}
	bison --defines=${PARSERH} ${PARSERYPP} -o ${PARSERCPP}

bisonerr: ${PARSERYPP}
	bison -v ${PARSERYPP}

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
	@echo Compiling unit tests...
	${CXX} ${CXXFLAGS} ${SRCDIR}/tests.cpp ${_TARGETS} -o ${TESTDIR}/tests
	@echo Running unit tests...
	@echo
	@ ${BINDIR}/tests
	@echo Running integration tests...
	@ ./test.sh
	@echo
	@echo -e "\033[0;32m   +=====================================+ \033[0m"
	@echo -e "\033[0;32m   |========= All Tests Passed. =========| \033[0m"
	@echo -e "\033[0;32m   +=====================================+ \033[0m"
	@echo

clean:
	rm -rf bin/ ${COMPILER_BIN} cool.output cool.tab.cpp

