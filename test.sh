#!/bin/bash

COMPILER_CMD="./meh"
PASS="[\033[32mPASS\033[0m]"
PASSMODULE="[\033[32mPASS MODULE\033[0m]"
FAIL="[\033[22;41;30mFAIL\033[0m]"
REF_COMPILER="./ref_cool"
LEXER_CMD="${COMPILER_CMD} --lex"
PARSER_CMD="${COMPILER_CMD} --parse"
TYPE_CHECKER_CMD="${COMPILER_CMD} --type"

fail_tests=0

test0 ()
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

test1 ()
{
	# echo "Testing $1 for return status 1."
	OUTPUT=$($1)
	if [ $? -eq 1 ]; then
		echo -e ${PASS} $2
	else
		
		echo -e "${FAIL} $2 (should reject)"
		echo -e "-----Message:"
		echo -e ${OUTPUT}
		echo -e "-----End Message"
		let fail_tests=fail_tests+1
	fi
}

echo "----------Starting shell tests.----------"

# Insert tests here.

# Lexer tests
echo "Testing Lexer with test code."
test0 "${LEXER_CMD} cool-examples/invalid_char_in_string.cl" "lexer: invalid char in string."
test0 "${LEXER_CMD} cool-examples/invalid_chars_in_comments.cl" "lexer: invalid chars in comments.cl"
test0 "${LEXER_CMD} cool-examples/unicode_in_string.cl" "lexer: unicode in string."
test1 "${LEXER_CMD} cool-examples/hello-world-fail.cl" "lexer: hello-world-fail.cl"
test1 "${LEXER_CMD} cool-examples/invalid_chars_as_id.cl" "lexer: invalid chars as ID"
test1 "${LEXER_CMD} cool-examples/unicode_as_id.cl" "lexer: unicode as id."
test0 "${LEXER_CMD} cool-examples/all_ids.cl" "lexer: all valid identifiers."
test1 "${LEXER_CMD} cool-examples/eof_within_comment.cl" "lexer: eof before closing comment"
test1 "${LEXER_CMD} cool-examples/eof_within_string.cl" "lexer: eof within string"

echo "Testing Lexer with valid COOL code."
test0 "${LEXER_CMD} cool-examples/arith.cl" "lexer: arith.cl"
test0 "${LEXER_CMD} cool-examples/atoi.cl" "lexer: atoi.cl"
test0 "${LEXER_CMD} cool-examples/cells.cl" "lexer: cells.cl"
test0 "${LEXER_CMD} cool-examples/factorial.cl" "lexer: factorial.cl"
test0 "${LEXER_CMD} cool-examples/hello-world.cl" "lexer: hello-world.cl"
test0 "${LEXER_CMD} cool-examples/hs.cl" "lexer: hs.cl"
test0 "${LEXER_CMD} cool-examples/list.cl" "lexer: list.cl"
test0 "${LEXER_CMD} cool-examples/new-complex.cl" "lexer: new-complex.cl"
test0 "${LEXER_CMD} cool-examples/primes.cl" "lexer: primes.cl"
test0 "${LEXER_CMD} cool-examples/print-cool.cl" "lexer: print-cool.cl"
test0 "${LEXER_CMD} cool-examples/sort-list.cl" "lexer: sort-list.cl"

echo "Testing Lexer output vs COOL reference compiler output."
for file in `ls cool-examples/*.cl`
do
	${LEXER_CMD} $file &> /dev/null
	if [ $? -eq 0 ]; then
		${REF_COMPILER} --lex $file &> /dev/null
		test0 "diff ${file}-lex-meh ${file}-lex" "lexer: $file compared to reference compiler."
	fi
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Lexer
fi

# Comment following line to keep the lexer output.
rm -f cool-examples/*-lex-meh cool-examples/*-lex

# Parser Tests
echo "Testing parser return status vs COOL reference compiler."
for file in `ls cool-examples/*.cl`
do
	${REF_COMPILER} --parse $file &> /dev/null
	if [ -e "${file}-ast" ]; then
		# echo "${file}-ast exists, so it passed reference compiler."
		test0 "${PARSER_CMD} ${file}" "parser: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		test1 "${PARSER_CMD} ${file}" "parser: $file "
	fi
	rm -f ${file}-ast ${file}-ast-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Parser
fi

# Type Checker Tests

# Test against reference compiler

echo "Testing type checker return status vs COOL reference compiler."
for file in `ls cool-examples/*.cl`
do
	${REF_COMPILER} --type $file &> /dev/null
	if [ -e "${file}-type" ]; then
		test0 "${TYPE_CHECKER_CMD} ${file}" "type checker: $file "
	else
		# echo "${file}-ast doesn't exist, so it failed reference compiler."
		test1 "${TYPE_CHECKER_CMD} ${file}" "type checker: $file "
	fi
	rm -f ${file}-type ${file}-type-meh
done

if [ $fail_tests -eq 0 ]; then
	echo -e ${PASSMODULE} Type Checker
fi

echo "Number of failed shell tests: ${fail_tests}"
echo "----------Done with shell tests.----------"
exit $((fail_tests))
