/*
 * Team Literally Cool
 *
 * tree.h
 *
 * This contains the header file of our basic generic multi-child tree.
 */
#ifndef __TREE_H_
#define __TREE_H_

#include <vector>
#include <cstdlib>

using namespace std;

class Visitor;
class Tree
{
private:
	vector<Tree *> children;
	Tree *parent;

public:
	/**
	 * Default constructor for tree. Parent will be null.
	 */
	Tree();

	/**
	 * Sets the parent of the tree.
	 * @param p parent of the tree, NULL if root.
	 */
	void setParent(Tree *p);

	/**
	 * Gets the parent of the tree. NULL if root.
	 * @return parent of tree, NULL if root.
	 */
	Tree *getParent();

	/**
	 * sets the left child of the Tree
	 * @param n Tree to set as left child
	 */
	void setLeftChild(Tree *n);

	/**
	 * sets the right child of the Tree
	 * @param n Tree to set as right child
	 */
	void setRightChild(Tree *n);

	/**
	 * sets the child to be the new first. everything else gets bumped one slot down
	 * @param n Tree to set as first.
	 */
	void setFirstChild(Tree *n);
	/**
	 * Adds a Tree as a child. Order is left child, then right child, then "other" children. If left or right are set, they are not overwritten.
	 * @param n Tree to add as child.
	 */
	void addChild(Tree *n);

	/**
	 * Gets the only child of the Tree. Analogous to getLeftChild. NULL if not set
	 * @return the sole child of the Tree.
	 */
	Tree *getChild();

	/**
	 * Gets the left child of the Tree. NULL if not set.
	 * @return the left child
	 */
	Tree *getLeftChild();

	/**
	 * Gets the right child of the Tree. NULL if not set.
	 * @return the right child
	 */
	Tree *getRightChild();

	/**
	 * Gets all the children of the Tree.
	 * @return vector of all children
	 */
	vector<Tree *> getChildren();

	virtual ~Tree();
};

#endif /* __TREE_H_ */
