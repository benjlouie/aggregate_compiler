/* Team Literally Cool
 *
 * ast.h
 *
 * This is the header file for our Abstract Syntax Tree
 *
 */

#ifndef __AST_H_
#define __AST_H_

#include <vector>
#include <string>
#include <stdarg.h>
#include "tree.h"

using namespace std;

enum NodeType
{
	AST_IDENTIFIER,
	AST_INTEGERLITERAL,
	AST_STRING,
	AST_TYPE,
	AST_CASE,
	AST_CASELIST,
	AST_FALSE,
	AST_IF,
	AST_ISVOID,
	AST_NEW,
	AST_NOT,
	AST_WHILE,
	AST_TRUE,
	AST_CLASS,
	AST_DIVIDE,
	AST_EQUALS,
	AST_LARROW,
	AST_LE,
	AST_LET,
	AST_MINUS,
	AST_PLUS,
	AST_TILDE,
	AST_TIMES,
	AST_PROGRAM,
	AST_NULL,
	AST_FEATURESET,
	AST_FEATURE_METHOD,
	AST_FEATURE_ATTRIBUTE,
	AST_FORMALLIST,
	AST_FORMAL,
	AST_DISPATCH,
	AST_LT,
	AST_EXPRLIST,
	AST_EXPRSEMILIST,
	AST_IDTYPEEXPR,
	AST_IDTYPEEXPRLIST,
	AST_CASESTATEMENT,
	AST_LET_IDENTIFIER,
	AST_METHOD_IDENTIFIER,
	AST_CASE_IDENTIFIER
};

string enum2string(NodeType);

class Node : public Tree
{

public:
	vector<Node *> children;
	string value;
	NodeType type;
	string valType;
	string reg = "";
    int lineNumber;

	Node();
	/**
	 * This creates a new node with NodeType type
	 * @param type NodeType of the node
	 */
	Node(NodeType type);

	/**
	 * This creates a new node with NodeType type and value value
	 * @param type NodeType of the node
	 * @param value stored value for this node
	 */
	Node(NodeType type, string value);

	/**
	 * This creates a new node with NodeType type, string value, and any number of node arguments afterwards
	 * @param type NodeType of the node
	 * @param value Value of the node
	 * @param ... any number of nodes to add as children, in order.
	 */
	Node(NodeType type, string value, int numChildren, ...);
	
	/**
	 * This creates a new node with NodeType type and any number of node arguments afterwards
	 * @param type NodeType of the node
	 * @param children number of nodes to add as children
	 * @param ... nodes to add as children, in order.
	 */
	Node(NodeType type, int numChildren, ...);

	/**
	 * Gets the Type
	 * @return type
	 */
	NodeType getType();

	/* auxillary functions */
	void print(int level);
	void recursive_print(int level);

	/* call this one, not the other one with a param */
	void print();
	
	virtual ~Node();
};

#endif /* __AST_H_ */