/*
 * Team Literally Cool
 * tests.cpp
 *
 * This is our unit testing Framework
 */

#include <stdio.h>
#include <string>
#include "driver.h"
#include "ast.h"
#include "testtree.h"

using namespace std;

void pass(const char *);
void fail(const char *);
void test(void *, void *, const char *);

int checkAST();
int checkTree();
int retval;

int main(void)
{
	int numFails = 0;
	printf("----------Starting C++ tests.----------\n");
	numFails += checkTree();
	numFails += checkAST();

	printf("\nNumber of failed C++ tests: %d\n", numFails);
	printf("----------Done with C++ tests.----------\n");

	return numFails;
}

int checkTree()
{
	retval = 0;
	TestTree *root = new TestTree();
	test(root->getParent(), NULL, "Tree: getParent with root");
	test(root->getChild(), NULL, "Tree: getChild returns NULL");
	test(root->getLeftChild(), NULL, "Tree: getLeftChild returns NULL");
	test(root->getRightChild(), NULL, "Tree: getRightChild returns NULL");

	TestTree *left = new TestTree();
	root->setLeftChild(left);
	test(root->getParent(), NULL, "Tree: setLeftChild, root parent persisted.");
	test(root->getLeftChild(), left, "Tree: getLeftChild after setLeftChild");
	test(root->getChild(), left, "Tree: getChild after setLeftChild");
	test(root->getRightChild(), NULL, "Tree: getRightChild still null after setLeftChild");
	test(left->getParent(), root, "Tree: getParent after setLeftChild");

	TestTree *right = new TestTree();
	root->setRightChild(right);
	test(root->getParent(), NULL, "Tree: setRightChild, root parent persisted.");
	test(root->getRightChild(), right, "Tree: getRightChild after setRightChild");
	test(root->getLeftChild(), left, "Tree: setRightChild didn't tamper with getLeftChild");
	test(left->getParent(), root, "Tree: getParent after setRightChild");

	TestTree *first = new TestTree();
	root->setFirstChild(first);
	test(root->getParent(), NULL, "Tree: setFirstChild, getParent of root");
	test(first->getParent(), root, "Tree: setFirstChild, first parent pointer");
	test(root->getLeftChild(), first, "Tree: setFirstChild and getLeftChild");
	test(root->getRightChild(), left, "Tree: setFirstChild and getRightChild");
	test(root->getChildren().at(2), right, "Tree: setFirstChild and getChildren");
	TestTree *last = new TestTree();
	root->addChild(last);
	test(root->getChildren().at(3), last, "Tree: addChild and getChildren.at");
	delete root;

	if (retval == 0)
		pass("Generic Tree");
	return retval;
}

int checkAST()
{
	// Check the AST for proper functionality.
	retval = 0;
	Node *root = new Node(AST_ROOT);

	if (root->getType() == AST_ROOT)
		pass("AST: Node identifier persistent.");
	else
		fail("AST: Node identifier not persistent");

	delete root;
	root = new Node(AST_TEST, "root");
	Node *left = new Node(AST_TEST, "left");
	Node *right = new Node(AST_TEST, "right");

	root->addChild(left);
	if (root->getLeftChild() == left)
		pass("AST: addChild and getLeftChild");
	else
		fail("AST: addChild and getLeftChild not same");
	if (root->getRightChild() == NULL)
		pass("AST: addChild and getRightChild is null");
	else
		fail("AST: addChild and getRightChild was changed (should be null)");

	root->addChild(right);
	if (root->getLeftChild() == left)
		pass("AST: addChild(2) and getLeftChild persistent");
	else
		fail("AST: addChild(2) and getLeftChild was changed");
	if (root->getRightChild() == right)
		pass("AST: addChild(2) and getRightChild persistent");
	else
		fail("AST: addChild(2) and getRightChild was not same");

	Node *third = new Node(AST_TEST, "third");
	root->addChild(third);
	if (root->getLeftChild() == left)
		pass("AST: addChild(3) and getLeftChild persistent");
	else
		fail("AST: addChild(3) and getLeftChild was changed");
	if (root->getRightChild() == right)
		pass("AST: addChild(3) and getRightChild persistent");
	else
		fail("AST: addChild(3) and getRightChild was not same");
	if (root->getChildren().at(0) == left)
		pass("AST: getChildren().at(0)");
	else
		fail("AST: getChildren().at(0) is not left");
	if (root->getChildren().at(1) == right)
		pass("AST: getChildren().at(1)");
	else
		fail("AST: getChildren().at(1) is not right");
	if (root->getChildren().at(2) == third)
		pass("AST: getChildren().at(2)");
	else
		fail("AST: getChildren().at(2) is not third");

	Node *first = new Node(AST_TEST, "first");
	root->setFirstChild(first);
	if (root->getLeftChild() == first)
		pass("AST: insertFirst became first");
	else
		fail("AST: setFirstChild didn't become first!");
	if (root->getRightChild() == left)
		pass("AST: insertFirst, old 1st became 2nd");
	else
		fail("AST: insertFirst, old 1st didn't become 2nd");
	if (root->getChildren().at(2) == right)
		pass("AST: insertFirst, old 2nd became 3rd");
	else
		fail("AST: insertFirst, old 2nd didn't become 3rd");
	if (root->getChildren().at(3) == third)
		pass("AST: insertFirst, old 3rd became 4th");
	else
		fail("AST: insertFirst, old 3rd didn't become 4th");

	// Variable length constructor
	delete root;
	left = new Node(AST_TEST, "left");
	root = new Node(AST_TEST, "root", 1, left);
	test(root->getLeftChild(), left, "AST: multilength constructor (1), left==left");
	test(root->getRightChild(), NULL, "AST: multilength constructor (1), right==null");
	test(left->getParent(), root, "AST: multilength constructor(1), left parent==root");

	delete root;

	left = new Node(AST_TEST, "left");
	right = new Node(AST_TEST, "right");
	root = new Node(AST_TEST, "root", 2, left, right);
	test(root->getLeftChild(), left, "AST: multilength constructor (2), left==left");
	test(root->getRightChild(), right, "AST: multilength constructor (2), right==right");
	test(right->getParent(), root, "AST: multilength constructor (2), right parent==root");
	delete root;

	left = new Node(AST_TEST, "left");
	right = new Node(AST_TEST, "right");
	third = new Node(AST_TEST, "third");
	root = new Node(AST_TEST, "root", 3, left, right, third);
	test(root->getLeftChild(), left, "AST: multilength constructor (3), left==left");
	test(root->getRightChild(), right, "AST: multilength constructor (3), right==right");
	test(root->getChildren().at(2), third, "AST: multilength constructor (3), third==third");
	test(third->getParent(), root, "AST: multilength constructor(3), third parent==root");
	delete root;

	if (retval == 0)
		pass("Abstract Syntax Tree");
	return retval;
}

void test(void *a, void *b, const char *test)
{
	if (a == b)
		pass(test);
	else
		fail(test);
}
void pass(const char *test)
{
	printf("[\033[32mPASS\033[0m] %s\n", test);
}

void fail(const char *err)
{
	fprintf(stderr, "[\033[22;41;30mFAIL\033[0m] %s\n", err);
	retval++;
}
