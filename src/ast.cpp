/* Team Literally Cool
 *
 * ast.cpp
 *
 * This is the source file that has the implementation for our Abstract Syntax Tree
 *
 */

#include "../src/ast.h"
#include <iostream>
#include <string>

extern int yylineno;

Node::Node()
{
	this->type = AST_NULL;
	lineNumber = 0;
}

Node::Node(NodeType type)
{
	this->type = type;
    lineNumber = 0;
}

Node::Node(NodeType type, string value)
{
	this->type = type;
	this->value = value;
    lineNumber = 0;
}

Node::Node(NodeType type, string value, int numChildren, ...)
{
	this->type = type;
	this->value = value;
	Node *child = NULL;
	va_list ArgumentPointer;
	va_start(ArgumentPointer, numChildren);
	for (int i = 0; i < numChildren; i++)
	{
		child = va_arg(ArgumentPointer, Node *);
		// this->children.push_back(child);
		this->addChild(child);
	}
	va_end(ArgumentPointer);
    lineNumber = 0;
}

Node::Node(NodeType type, int numChildren, ...)
{
	this->type = type;
	Node *child = NULL;
	va_list ArgumentPointer;
	va_start(ArgumentPointer, numChildren);
	for (int i = 0; i < numChildren; i++)
	{
		child = va_arg(ArgumentPointer, Node *);
		this->addChild(child);
	}
	va_end(ArgumentPointer);
    lineNumber = 0;
}


NodeType Node::getType()
{
	return this->type;
}

Node::~Node()
{
	// LOL
}

string enum2string(NodeType n) {
	string ntype;
	switch (n) {
	case AST_IDENTIFIER:
		return "identifier";
	case AST_INTEGERLITERAL:
		return "integer literal";
	case AST_STRING:
		return "string literal";
	case AST_TYPE:
		return "Type";
	case AST_CASE:
		return "case";
	case AST_CASELIST:
		return "case list";
	case AST_FALSE:
		return "bool constant false";
	case AST_IF:
		return "if";
	case AST_ISVOID:
		return "isvoid";
	case AST_NEW:
		return "new";
	case AST_NOT:
		return "not";
	case AST_WHILE:
		return "while";
	case AST_TRUE:
		return "true";
	case AST_CLASS:
		return "class";
	case AST_DIVIDE:
		return "divide";
	case AST_EQUALS:
		return "equals";
	case AST_LARROW:
		return "assignment";
	case AST_LE:
		return "less than or equal";
	case AST_LET:
		return "let";
	case AST_MINUS:
		return "minus";
	case AST_PLUS:
		return "plus";
	case AST_TILDE:
		return "negation";
	case AST_TIMES:
		return "multiply";
	case AST_PROGRAM:
		return "program";
	case AST_NULL:
		return "null";
	case AST_FEATURESET:
		return "feature set";
	case AST_FEATURE_METHOD:
		return "feature method";
	case AST_FEATURE_ATTRIBUTE:
		return "feature attribute";
	case AST_FORMALLIST:
		return "formal list";
	case AST_FORMAL:
		return "formal";
	case AST_DISPATCH:
		return "dispatch";
	case AST_LT:
		return "less than";
	case AST_EXPRLIST:
		return "expression list";
	case AST_EXPRSEMILIST:
		return "block expression";
	case AST_IDTYPEEXPR:
		return "id, type, expression";
	case AST_IDTYPEEXPRLIST: //not used TODO delete
		return "id, type, expressionlist"; 
	case AST_CASESTATEMENT:
		return "case statement";
	case AST_LET_IDENTIFIER:
		return "let identifier";
	case AST_METHOD_IDENTIFIER:
		return "method identifier";
	case AST_CASE_IDENTIFIER:
		return "case identifier";
	default:
		return "Unknown node type";
	}
}

void Node::recursive_print(int level) {
	print(level);
	Node *child;
	for (auto c : getChildren()) {
		child = (Node *) c;
		child->recursive_print(level + 1);
	}
}

void Node::print() {
	recursive_print(0);
}

void Node::print(int level) {
	/* fields:
	 *	string value;
	 *	NodeType type;
	 *	string valType;
	 *	string reg = "";
	 *	int lineNumber;
	 */
	string tabs = string(level , '\t');
	cout << tabs << enum2string(type) << endl;
	cout << tabs << "type: " << valType << endl;
	cout << tabs << "Line number: " << lineNumber << endl << endl;
}

Node *deepCopy_recursive(Node *orig)
{
	Node *copy = new Node;
	//copy over the easy stuff
	copy->type = orig->type;
	copy->value = orig->value;
	copy->valType = orig->valType;
	copy->reg = orig->reg;
	copy->lineNumber = orig->lineNumber;

	//go through the children
	for (Tree *OrigChild : orig->getChildren()) {
		Node *copyChild = deepCopy_recursive((Node *)OrigChild);
		//add child to root
		copy->addChild(copyChild);
		//set child->parent to root
		copyChild->setParent(copy);
	}

	return copy;
}

Node * Node::deepCopy(void)
{
	return deepCopy_recursive(this);
}