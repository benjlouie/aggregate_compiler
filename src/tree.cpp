/*
 * Team Literally Cool
 *
 * tree.cpp
 *
 * Super cool generic multi-child tree implementation.
 */

#include "tree.h"

Tree::Tree()
{
	// This constructor is called even if children are called."
	this->parent = NULL;
}

void Tree::setParent(Tree *p)
{
	this->parent = p;
}

Tree *Tree::getParent()
{
	return this->parent;
}

void Tree::setLeftChild(Tree *n)
{
	if (this->children.size() == 0)
		this->children.push_back(n);
	else
		this->children[0] = n;
	n->setParent(this);
}

void Tree::setRightChild(Tree *n)
{
	if (this->children.size() == 0)
	{
		this->children.push_back(NULL);
		this->children.push_back(n);
	}
	else if (this->children.size() == 1)
		this->children.push_back(n);
	else
		this->children[1] = n;
	n->setParent(this);
}

void Tree::setFirstChild(Tree *n)
{
	this->children.insert(this->children.begin(), n);
	n->setParent(this);
}

void Tree::addChild(Tree *n)
{
	this->children.push_back(n);
	n->setParent(this);
}

Tree *Tree::getLeftChild()
{
	if (this->children.size() == 0)
		return NULL;
	else
		return this->children.at(0);
}

Tree *Tree::getChild()
{
	return this->getLeftChild();
}

Tree *Tree::getRightChild()
{
	if (this->children.size() <= 1)
		return NULL;
	else
		return this->children.at(1);
}

bool Tree::replaceChild(Tree *oldChild, Tree *newChild)
{
	for (size_t i = 0; i < children.size(); i++) {
		if (children[i] == oldChild) {
			children[i] = newChild;
			return true;
		}
	}
	return false;
}

bool Tree::deleteChild(Tree *child)
{
	for (auto it = children.begin(); it != children.end(); it++) {
		if (*it == child) {
			children.erase(it);
			return true;
		}
	}
	return false;
}

bool Tree::replaceSelf(Tree *newNode)
{
	return this->parent->replaceChild(this, newNode);
}

bool Tree::deleteSelf(void)
{
	return this->parent->deleteChild(this);
}

vector<Tree *> Tree::getChildren()
{
	return this->children;
}

Tree::~Tree()
{
	for (Tree *n : this->getChildren())
		delete n;
}
