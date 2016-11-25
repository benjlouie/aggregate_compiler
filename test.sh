#!/bin/bash
#Modified by Matthew Karasz

COMPILER_CMD="./swearjar"
PASS="[\033[32mPASS\033[0m]"
PASSMODULE="[\033[32mPASS MODULE\033[0m]"
FAIL="[\033[22;41;30mFAIL\033[0m]"
MAYBE="[\033[FF;80;00mMAYBE\033[0m]"
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
CGENCL="codegen"
CGENUICL="codegen_input"
TESTFILEDIR="$TESTS/testFiles"
REFOUTFILE="$TESTFILEDIR/refOut.txt"
SJOUTFILE="$TESTFILEDIR/sjOut.txt"
LEXGOOD=`find $TESTS/$LEXER_DIR/$GOODCL -iname *.cl`
LEXBAD=`find $TESTS/$LEXER_DIR/$BADCL -iname *.cl`
ELSEFILES=`find $TESTS/$ELSECL -iname *.cl`
CGENFILES=`find $TESTS/$CGENCL -iname *.cl`
CGENUIFILES=`find $TESTS/$CGENUICL -iname *.cl`

fail_tests=0

#Assumes the test will pass and errors if it doesn't.
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

#Assumes the test will fail and errors if it doesn't.
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

#General function to tell us info about failures.
failExit ()
{
	echo "Number of failed shell tests: ${fail_tests}"
	echo "----------Done with shell tests.----------"
	rm `find . -iname *-lex*`
	exit $((fail_tests))
}


    if [ `ls *.cl 2> /dev/null | wc -l` -gt 0 ]; then
    	echo "There are .cl files in your aggregate direcotory. This file will not work with them there. Exiting."
	    exit 1
    fi

#see if the system has dos2unix cause we all like to switch between Linux and Windows intermittently
type dos2unix &> /dev/null

if [ $? -eq 0 ]; then
    echo "-----Converting to Unix Newlines.--------"
    dos2unix -q `find ${TESTS} -iname *.cl`

else
    echo "I'm assuming your files all have the correct line ending. Please install 'dos2unix' if they do not."
fi

echo "----------Starting shell tests.----------"

#Lexical tests
echo "Starting good lexical tests."
for file in $LEXGOOD; do
	acceptFunc "${LEXER_CMD} ${file}" "lexer: $file "
done

echo "Starting bad lexical tests."
for file in $LEXBAD; do
	rejectFunc "${LEXER_CMD} ${file}" "lexer: $file "
done

# Comment following line to keep the lexer output.
LEXOUTFILES=`find $TESTS/$LEXER_DIR/ -iname *.cl-lex*`
for file in $LEXOUTFILES; do
    rm -f $file
done


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

#Code Generation Tests

mkdir $TESTFILEDIR

# Test against reference compiler
echo "Testing Code generation with no user input vs COOL reference compiler."
for file in $CGENFILES
do
	echo $file
	${REF_COMPILER} $file > $REFOUTFILE
	REFOUTRES=$?
	echo "Done."
	${COMPILER_CMD} --run $file > $SJOUTFILE
	SJOUTRES=$?
	DIFFOUT=`diff $REFOUTFILE $SJOUTFILE`
	if [ $REFOUTRES -ne $SJOUTRES ]; then 
		echo "Check $file, number $fail_tests"
		mv $REFOUTFILE $TESTFILEDIR/$fail_tests-refoutput
		mv $SJOUTFILE $TESTFILEDIR/$fail_tests-sjoutput
		let fail_tests=fail_tests+1
		continue
	fi

	if [ "$DIFFOUT" != "" ]; then
		if [ $REFOUTRES -eq 1 ]; then
			echo -e $MAYBE 
			echo "Check to make sure these say about the same thing\n"
			echo $DIFFOUT
			echo "If they don't, check $file, number $fail_tests"
			mv $REFOUTFILE $TESTFILEDIR/$fail_tests-refoutput
			mv $SJOUTFILE $TESTFILEDIR/$fail_tests-sjoutput
			let fail_tests=fail_tests+1
		else
			echo -e ${FAIL} $file
			let fail_tests=fail_tests+1
			mv $REFOUTFILE $TESTFILEDIR/$fail_tests-refoutput
			mv $SJOUTFILE $TESTFILEDIR/$fail_tests-sjoutput
			echo $DIFFOUT
		fi
	else
		echo -e ${PASS} $file
	fi

done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Code Generation - No User Input
else
	failExit
fi

echo "Testing Code generation with no user input vs COOL reference compiler."
for file in $CGENUIFILES
do
	${REF_COMPILER} $file < $file-in > $REFOUTFILE
	REFOUTRES=$?
	${COMPILER_CMD} --run $file < $file-in > $SJOUTFILE
	SJOUTRES=$?
	DIFFOUT=`diff $REFOUTFILE $SJOUTFILE`
	if [ $REFOUTRES -ne $SJOUTRES ]; then 
		echo "Check $file"
		mv $REFOUTFILE $TESTFILEDIR/$file-refoutput
		mv $SJOUTFILE $TESTFILEDIR/$file-sjoutput
		continue
	fi

	if [ $DIFFOUT != "" ]; then
		if [ $REFOUTRES -eq 1 ]; then
			echo -e $MAYBE 
			echo "Check to make sure these say about the same thing\n"
			echo $DIFFOUT
			echo "If they don't, check $file"
			let fail_tests=fail_tests+1
		else
			echo -e ${FAIL} $file
			let fail_tests=fail_tests+1
			echo $DIFFOUT
		fi
	else
		echo -e ${PASS} $file
	fi

done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Code Generation - No User Input
else
	failExit
fi


echo "Number of failed shell tests: ${fail_tests}"
echo "----------Done with shell tests.----------"
