#!/bin/bash

COMPILER_CMD="./holiman"
PASS="[\033[32mPASS\033[0m]"
PASSMODULE="[\033[32mPASS MODULE\033[0m]"
FAIL="[\033[22;41;30mFAIL\033[0m]"
REF_COMPILER="./ref_cool"
LEXER_CMD="${COMPILER_CMD} --lex"
PARSER_CMD="${COMPILER_CMD} --parse"
TYPE_CHECKER_CMD="${COMPILER_CMD} --type"
IR_CMD="${COMPILER_CMD} --ir"
CODEGEN_CMD="${COMPILER_CMD} --asm"
TESTS="compiler_tests"
LEXER_DIR="lexer"
GOODCL="good"
BADCL="bad"
ELSECL="else"
LEXGOOD=`find $TESTS/$LEXER_DIR/$GOODCL -iname *.cl`
LEXBAD=`find $TESTS/$LEXER_DIR/$BADCL -iname *.cl`
ELSEFILES=`find $TESTS/$ELSECL -iname *.cl`

fail_tests=0

acceptFunc ()
{
	# echo "Testing $1 for return status 0."
	OUTPUT=$($1)
	if [ $? -eq 0 ]; then
		echo -e ${PASS} $2
	else
		echo -e "${FAIL} $2 (should accept)"
		echo -e "-----Message:"
		echo -e ${OUTPUT}
		echo -e "-----End Message"
		let fail_tests=fail_tests+1
	fi
}

rejectFunc ()
{
	# echo "Testing $1 for return status 1."
	OUTPUT=$($1 2> /dev/null)
	RET=$?
    if [ $RET -eq 0 ]; then
		echo -e "${FAIL} $2 (should reject)"
		echo -e "-----Message:"
		echo -e ${OUTPUT}
		echo -e "-----End Message"
		let fail_tests=fail_tests+1
    else
		echo -e ${PASS} $2
	fi
}

failExit ()
{
	echo "Number of failed shell tests: ${fail_tests}"
	echo "----------Done with shell tests.----------"
	rm `find . -iname *-lex*`
	exit $((fail_tests))
}

echo "-----Converting to Unix Newlines.--------"

if [ `ls *.cl 2> /dev/null | wc -l` -gt 0 ]; then
	echo "There are .cl files in your aggregate direcotory. This file will not work with them there. Exiting."
	exit 1
fi
 
dos2unix -q `find ${TESTS} -iname *.cl`

echo "----------Starting shell tests.----------"

# Insert tests here.

echo "Starting good lexical tests."
for file in $LEXGOOD; do
	acceptFunc "${LEXER_CMD} ${file}" "lexer: $file "
done

echo "Starting bad lexical tests."
for file in $LEXBAD; do
	rejectFunc "${LEXER_CMD} ${file}" "lexer: $file "
done

# Comment following line to keep the lexer output.
rm -f cool-examples/*-lex-meh cool-examples/*-lex

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Parser
else
	failExit
fi

# Parser Tests
echo "Testing parser return status vs COOL reference compiler."
for file in $ELSEFILES
do
	${REF_COMPILER} --parse $file &> /dev/null
	if [ -e "${file}-ast" ]; then
		# echo "${file}-ast exists, so it passed reference compiler."
		acceptFunc "${PARSER_CMD} ${file}" "parser: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		rejectFunc "${PARSER_CMD} ${file}" "parser: $file "
	fi
	rm -f ${file}-ast ${file}-ast-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Parser
else
	failExit
fi
# Type Checker Tests

# Test against reference compiler

echo "Testing type checker return status vs COOL reference compiler."
for file in $ELSEFILES
do
	${REF_COMPILER} --type $file &> /dev/null
	if [ -e "${file}-type" ]; then
		acceptFunc "${TYPE_CHECKER_CMD} ${file}" "type checker: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		rejectFunc "${TYPE_CHECKER_CMD} ${file}" "type checker: $file "
	fi
	rm -f ${file}-type ${file}-type-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Parser
else
	failExit 
fi

exit

#IR Generation Tests

# Test against reference compiler

echo "Testing IR generation return status vs COOL reference compiler."
for file in $ELSEFILES
do
	${REF_COMPILER} --ir $file &> /dev/null
	if [ -e "${file}-ir" ]; then
		acceptFunc "${IR_CMD} ${file}" "ir generation: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		rejectFunc "${IR_CMD} ${file}" "ir generation: $file "
	fi
	rm -f ${file}-type ${file}-type-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} IR Generation
else
	failExit
fi

#Code Generation Tests

# Test against reference compiler

echo "Testing Code generation return status vs COOL reference compiler."
for file in $ELSEFILES
do
	${REF_COMPILER} --ir $file &> /dev/null
	if [ -e "${file}-s" ]; then
		acceptFunc "${IR_CMD} ${file}" "code gen: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		rejectFunc "${TYPE_CHECKER_CMD} ${file}" "code gen: $file "
	fi
	rm -f ${file}-type ${file}-type-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Parser
else
	failExit
fi

echo "Number of failed shell tests: ${fail_tests}"
echo "----------Done with shell tests.----------"
