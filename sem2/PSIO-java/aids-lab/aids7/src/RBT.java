import java.util.Comparator;

public class RBT <T> extends Tree<T>{
    private static class NilNode<T> extends Node {
        private NilNode() {
            super(null);
            this.setBlack();
        }
    }
    public RBT(Comparator<T> comparator) {
        super(comparator);
    }
    private void rotateRight(Node node) {
        Node parent = node.getParent();
        Node leftChild = node.getLeft();

        node.setLeft(leftChild.getRight());
        if (leftChild.getRight() != null) {
            leftChild.getRight().setParent(node);
        }

        leftChild.setRight(node);
        node.setParent(leftChild);

        replaceParentsChild(parent, node, leftChild);
    }
    private void rotateLeft(Node node) {
        Node parent = node.getParent();
        Node rightChild = node.getRight();

        node.setRight(rightChild.getLeft());
        if (rightChild.getLeft() != null) {
            rightChild.getLeft().setParent(node);
        }

        rightChild.setLeft(node);
        node.setParent(rightChild);

        replaceParentsChild(parent, node, rightChild);
    }
    private void replaceParentsChild(Node parent, Node oldChild, Node newChild) {
        if (parent == null) {
            root = newChild;
        } else if (parent.getLeft() == oldChild) {
            parent.setLeft(newChild);
        } else if (parent.getRight() == oldChild) {
            parent.setRight(newChild);
        } else {
            throw new IllegalStateException("Node is not a child of its parent");
        }

        if (newChild != null) {
            newChild.setParent(parent);
        }
    }
    public T find(T key) {
        Node<T> node = root;
        while (node != null) {
            int cmp = comparator.compare(key, node.getData());
            if (cmp == 0) {
                return node.getData();
            } else if (cmp < 0) {
                node = node.getLeft();
            } else {
                node = node.getRight();
            }
        }

        return null;
    }
    public void insert(T key) {
        Node<T> node = root;
        Node<T> parent = null;

        // Traverse the tree to the left or right depending on the key
        while (node != null) {
            parent = node;
            int cmp = comparator.compare(key, node.getData());
            if (cmp < 0) {
                node = node.getLeft();
            } else if (cmp > 0) {
                node = node.getRight();
            } else {
                throw new DuplicateElementException(key.toString());
            }
        }

        // Insert new node
        Node<T> newNode = new Node(key);
        newNode.setRed();
        if (parent == null) {
            root = newNode;
        } else if (comparator.compare(key, parent.getData()) < 0) {
            parent.setLeft(newNode);
        } else {
            parent.setRight(newNode);
        }
        newNode.setParent(parent);

        fixRedBlackPropertiesAfterInsert(newNode);
    }
    private void fixRedBlackPropertiesAfterInsert(Node node) {
        Node parent = node.getParent();

        // Case 1: Parent is null, we've reached the root, the end of the recursion
        if (parent == null) {
            // Uncomment the following line if you want to enforce black roots (rule 2):
            node.setBlack();
            return;
        }

        // Parent is black --> nothing to do
        if (parent.isBlack()) {
            return;
        }

        // From here on, parent is red
        Node grandparent = parent.getParent();

        // Case 2:
        // Not having a grandparent means that parent is the root. If we enforce black roots
        // (rule 2), grandparent will never be null, and the following if-then block can be
        // removed.
        if (grandparent == null) {
            // As this method is only called on red nodes (either on newly inserted ones - or -
            // recursively on red grandparents), all we have to do is to recolor the root black.
            parent.setBlack();
            return;
        }

        // Get the uncle (may be null/nil, in which case its color is BLACK)
        Node uncle = getUncle(parent);

        // Case 3: Uncle is red -> recolor parent, grandparent and uncle
        if (uncle != null && uncle.isRed()) {
            parent.setBlack();
            grandparent.setRed();
            uncle.setBlack();

            // Call recursively for grandparent, which is now red.
            // It might be root or have a red parent, in which case we need to fix more...
            fixRedBlackPropertiesAfterInsert(grandparent);
        }

        // Parent is left child of grandparent
        else if (parent == grandparent.getLeft()) {
            // Case 4a: Uncle is black and node is left->right "inner child" of its grandparent
            if (node == parent.getRight()) {
                rotateLeft(parent);

                // Let "parent" point to the new root node of the rotated sub-tree.
                // It will be recolored in the next step, which we're going to fall-through to.
                parent = node;
            }

            // Case 5a: Uncle is black and node is left->left "outer child" of its grandparent
            rotateRight(grandparent);

            // Recolor original parent and grandparent
            parent.setBlack();
            grandparent.setRed();
        }

        // Parent is right child of grandparent
        else {
            // Case 4b: Uncle is black and node is right->left "inner child" of its grandparent
            if (node == parent.getLeft()) {
                rotateRight(parent);

                // Let "parent" point to the new root node of the rotated sub-tree.
                // It will be recolored in the next step, which we're going to fall-through to.
                parent = node;
            }

            // Case 5b: Uncle is black and node is right->right "outer child" of its grandparent
            rotateLeft(grandparent);

            // Recolor original parent and grandparent
            parent.setBlack();
            grandparent.setRed();
        }
    }
    private Node getUncle(Node parent) {
        Node grandparent = parent.getParent();
        if (grandparent.getLeft() == parent) {
            return grandparent.getRight();
        } else if (grandparent.getRight() == parent) {
            return grandparent.getLeft();
        } else {
            throw new IllegalStateException("Parent is not a child of its grandparent");
        }
    }
    public void remove(T key) {
        Node<T> node = root;
        // Find the node to be deleted
        while (node != null && comparator.compare(node.getData(), key) != 0) {
            // Traverse the tree to the left or right depending on the key
            int cmp = comparator.compare(node.getData(), key);
            if (cmp > 0) {
                node = node.getLeft();
            } else {
                node = node.getRight();
            }
        }

        // Node not found?
        if (node == null) {
            return;
        }



        // At this point, "node" is the node to be deleted

        // In this variable, we'll store the node at which we're going to start to fix the R-B
        // properties after deleting a node.
        Node<T> movedUpNode;
        boolean isDeletedNodeRed;

        // Node has zero or one child
        if (node.getLeft() == null || node.getRight() == null) {
            movedUpNode = deleteNodeWithZeroOrOneChild(node);
            isDeletedNodeRed = node.isRed();
        }

        // Node has two children
        else {
            // Find minimum node of right subtree ("inorder successor" of current node)
            Node<T> inOrderSuccessor = findMinimum(node.getRight());

            // Copy inorder successor's data to current node (keep its color!)
            node.setData(inOrderSuccessor.getData());

            // Delete inorder successor just as we would delete a node with 0 or 1 child
            movedUpNode = deleteNodeWithZeroOrOneChild(inOrderSuccessor);
            isDeletedNodeRed = inOrderSuccessor.isRed();
        }

        if (!isDeletedNodeRed) {
            fixRedBlackPropertiesAfterDelete(movedUpNode);

            // Remove the temporary NIL node
            if (movedUpNode.getClass() == NilNode.class) {
                replaceParentsChild(movedUpNode.getParent(), movedUpNode, null);
            }
        }
    }


    private Node deleteNodeWithZeroOrOneChild(Node node) {
        // Node has ONLY a left child --> replace by its left child
        if (node.getLeft() != null) {
            replaceParentsChild(node.getParent(), node, node.getLeft());
            return node.getLeft(); // moved-up node
        }

        // Node has ONLY a right child --> replace by its right child
        else if (node.getRight() != null) {
            replaceParentsChild(node.getParent(), node, node.getRight());
            return node.getRight(); // moved-up node
        }

        // Node has no children -->
        // * node is red --> just remove it
        // * node is black --> replace it by a temporary NIL node (needed to fix the R-B rules)
        else {
            Node newChild = node.isBlack() ? new NilNode() : null;
            replaceParentsChild(node.getParent(), node, newChild);
            return newChild;
        }
    }
    private Node findMinimum(Node node) {
        while (node.getLeft() != null) {
            node = node.getLeft();
        }
        return node;
    }
    private void fixRedBlackPropertiesAfterDelete(Node node) {
        // Case 1: Examined node is root, end of recursion
        if (node == root) {
            // Uncomment the following line if you want to enforce black roots (rule 2):
            node.setBlack();
            return;
        }

        Node sibling = getSibling(node);

        // Case 2: Red sibling
        if (sibling.isRed()) {
            handleRedSibling(node, sibling);
            sibling = getSibling(node); // Get new sibling for fall-through to cases 3-6
        }

        // Cases 3+4: Black sibling with two black children
        if ((sibling.getLeft() == null || sibling.getLeft().isBlack()) && (sibling.getRight() == null || sibling.getRight().isBlack())) {
            sibling.setRed();

            // Case 3: Black sibling with two black children + red parent
            if (node.getParent().isRed()) {
                node.getParent().setBlack();
            }

            // Case 4: Black sibling with two black children + black parent
            else {
                fixRedBlackPropertiesAfterDelete(node.getParent());
            }
        }

        // Case 5+6: Black sibling with at least one red child
        else {
            handleBlackSiblingWithAtLeastOneRedChild(node, sibling);
        }
    }
    private Node getSibling(Node node) {
        Node parent = node.getParent();
        if (node == parent.getLeft()) {
            return parent.getRight();
        } else if (node == parent.getRight()) {
            return parent.getLeft();
        } else {
            throw new IllegalStateException("Parent is not a child of its grandparent");
        }
    }
    private void handleRedSibling(Node node, Node sibling) {
        // Recolor...
        sibling.setBlack();
        node.getParent().setRed();

        // ... and rotate
        if (node == node.getParent().getLeft()) {
            rotateLeft(node.getParent());
        } else {
            rotateRight(node.getParent());
        }
    }
    private void handleBlackSiblingWithAtLeastOneRedChild(Node node, Node sibling) {
        boolean nodeIsLeftChild = (node == node.getParent().getLeft());

        // Case 5: Black sibling with at least one red child + "outer nephew" is black
        // --> Recolor sibling and its child, and rotate around sibling
        if (nodeIsLeftChild && (sibling.getRight() == null || sibling.getRight().isBlack())) {
            sibling.getLeft().isBlack();
            sibling.setRed();
            rotateRight(sibling);
            sibling = node.getParent().getRight();
        } else if (!nodeIsLeftChild && (sibling.getLeft() == null || sibling.getLeft().isBlack())) {
            sibling.getRight().setBlack();
            sibling.setRed();
            rotateLeft(sibling);
            sibling = node.getParent().getLeft();
        }

        // Fall-through to case 6...

        // Case 6: Black sibling with at least one red child + "outer nephew" is red
        // --> Recolor sibling + parent + sibling's child, and rotate around parent

        if(node.getParent().isBlack())
            sibling.setBlack();
        else
            sibling.setRed();

        node.getParent().setBlack();
        if (nodeIsLeftChild) {
            sibling.getRight().setBlack();
            rotateLeft(node.getParent());
        } else {
            sibling.getLeft().setBlack();
            rotateRight(node.getParent());
        }
    }
}
