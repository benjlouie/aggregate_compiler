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
			newChild->parent = this;
			return true;
		}
	}
	return false;
}

bool Tree::replaceDescendant(vector<size_t>& path, Tree * newChild)
{
	//follow path down
	Tree *cur = this;
	for (size_t childInd : path) {
		if (childInd >= cur->children.size()) {
			//error, ind is bad
			//throw "Tree::replaceDescendant(): child index too high, bad path";
			return false;
		}
		cur = cur->children[childInd];
	}

	return cur->replaceSelf(newChild);
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

vector<size_t> Tree::getPath(Tree *descendant)
{
	vector<size_t> pathReversed;
	//follow descendant up to ancestor
	while (descendant && descendant != this) {
		Tree *parent = descendant->parent;
		//get child index
		auto &kids = parent->children;
		size_t i = 0;
		for (; i < kids.size(); i++) {
			if (kids[i] == descendant) {
				pathReversed.push_back(i);
				descendant = parent;
				break;
			}
		}
		if (i == kids.size()) {
			//wasn't in parent children..ERROR
			throw "Tree::getPath(): child not in parent childList";
		}
	}
	if (descendant != this) {
		//did not get to ancestor
		throw "Tree::getPath(): descendant not beneath ancestor";
	}

	//reverse the path
	std::reverse(pathReversed.begin(), pathReversed.end());

	return pathReversed;
}

Tree * Tree::deepCopy(void)
{
	throw "Tree::deepCopy(): not implemented lol";
	return nullptr;
}

bool Tree::setChild(size_t childInd, Tree *newChild)
{
	if (childInd > this->children.size()) {
		//2+ over can't do it
		return false;
	}
	if (childInd == this->children.size()) {
		//at the end, just append
		this->addChild(newChild);
		return true;
	}
	//in the middle, replace
	Tree *oldChild = this->children[childInd];
	return this->replaceChild(oldChild, newChild);
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
