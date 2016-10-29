/* Team Literally Cool
 *
 * ast.cpp
 *
 * This is the source file that has the implementation for our Abstract Syntax Tree
 *
 */

#include "ast.h"
#include <iostream>

extern int yylineno;

Node::Node()
{
	this->type = AST_NULL;
    lineNumber = yylineno;
}

Node::Node(NodeType type)
{
	this->type = type;
    lineNumber = yylineno;
}

Node::Node(NodeType type, string value)
{
	this->type = type;
	this->value = value;
    lineNumber = yylineno;
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
    lineNumber = yylineno;
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
    lineNumber = yylineno;
}


NodeType Node::getType()
{
	return this->type;
}

Node::~Node()
{
	// LOL
}

