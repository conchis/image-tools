﻿/** * Copyright 2004 - 2010 Northwestern University and Jonathan A. Smith * * <p>Licensed under the Educational Community License, Version 2.0 (the * "License"); you may not use this file except in compliance with the * License. You may obtain a copy of the License at</p> * * http://www.osedu.org/licenses/ECL-2.0 * * <p>Unless required by applicable law or agreed to in writing, * software distributed under the License is distributed on an "AS IS" * BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express * or implied. See the License for the specific language governing * permissions and limitations under the License.</p> */package origami.trees{	/**	 * A generic tree node class that implements PropertyHolder. InternalNode instances	 * may have children.	 *	 * @author Jonathan A. Smith	 */	public class InternalNode extends LeafNode	{	    /** Child nodes. */		private var __children: Array;	    /**		 * Constructs an InternalNode.		 */		function InternalNode()		{			__children = null;		}		// **** Parents and Children	    /**		 * Returns true only if this node has children.		 *		 * @return True if node has children		 */		override public function hasChildren(): Boolean		{			if (__children == null)				return false;			return __children.length > 0;		}	    /**		 * Returns an array of child nodes.		 *		 * return Array of children. Note that the returned array is a copy.		 */		override public function get children(): Array		{			if (__children == null) return [];			return __children.slice();		}	    /**		 * Sets the array of child nodes.		 *		 * @param children actual Array of child nodes.		 */		public function set children(new_children: Array): void		{			// Remove children from former parents			var children: Array = this.children;			for each (var child: TreeNode in children)				child.remove();			// Set children array, tell each child it has been added			this.__children = new_children;			for each (var new_child: TreeNode in new_children)				new_child.addedTo(this);		}		// **** Add and Remove Children	    /**		 * Determines if a node can be a child of this node.		 *		 * @param child proposed child node		 * @return True if child may be added to this node, false otherwise		 */		override public function canAccept(child: TreeNode): Boolean		{			if (child == null)				throw new Error("child must be specified");			return child != this;		}	    /**		 * Adds a tree node to this node as a child.		 *		 * @param child TreeNode to be added as a child		 */		public function addChild(child: TreeNode): void		{			if (child == null)				throw new Error("child is null");			if (!canAccept(child))				throw new TreeStructureError("Unable to add child");			// Initialize children list if necessary			if (__children == null)				__children = new Array();			// If already child, return			if (__children.indexOf(child) != -1)				return;			// Add child to list, inform child of new parent node			__children.push(child);			child.addedTo(this);		}	    /**		 * Adds a sequence of child nodes.		 *		 * @param arguments child nodes to be added as children		 */		public function addChildren(...arguments: Array): void		{			for each (var child: TreeNode in arguments)				addChild(child);		}	    /**		 * Removes a child node from this node.		 *		 * @param child child node to remove		 * @return True if the child was found and removed from this parent		 */		public function removeChild(child: TreeNode): Boolean		{			if (child == null)				throw new Error("child is null");			// Remove child, inform child that it has been removed from parent			var index: int = __children.indexOf(child);			if (index > -1)			{				__children.splice(index, 1);				child.removedFrom(this);				return true;			}			// If not a child, return false			return false;		}	    /**		 * Replaces all the children of this node with one or more new children.		 *		 * @param arguments Child nodes to add after existing children are removed		 */		public function replaceChildren(...arguments :Array): void		{			// Remove current children			var children: Array = this.children;			for each (var child: TreeNode in children)			{				child.remove();			}			// Add arguments as children			for each (var argument: TreeNode in arguments)				addChild(argument);		}	    /**		 * Replaces a single child node with a specified node.		 *		 * @param child child node to replace existing child		 * @param index index of child to replace		 */		public function replaceChild(child: TreeNode, index: Number): void		{			if (child == null)				throw new Error("child is null");			var children: Array = __children;			// If beyond end by one, add child	        if (index == children.length)	        {	            addChild(child);	            return;	        }	        // If already in the indicated spot, return	        if (children[index] == child) return;	        // Inform existing child of removal	        children[index].removedFrom(this);	        // Set array element, tell new child of addition to parent	        children[index] = child;	        child.addedTo(this);		}		// **** Node Queries	    /**		 * Returns True only if a node is a child.		 *		 * @param child node to test		 * @return True if child is a child node of this node, false otherwise		 */		public function hasChild(child: TreeNode): Boolean		{			if (__children == null) return false;			return __children.indexOf(child) > -1;		}	    /**		 * Returns The index of a child node or -1 if not found.		 *		 * @param child child node to find in this node		 * @return Index of the child node in this node.		 */		public function indexOfChild(child: TreeNode): Number		{			if (__children == null) return -1;			return __children.indexOf(child);		}		// **** Insert or Move Child Node	    /**		 * Removes a node from its parent (if any) and inserts it at a specified index.		 * Note that this method will correctly move a child from one position to another.		 *		 * @param child Node to insert into the list of children		 * @param index index where the child is to be interted		 */		public function insert(child: TreeNode, index: Number): void		{			if (child == null)				throw new Error("child is null");			if (index < 0)				throw new TreeStructureError("index is out of bounds");			// If child has parent, remove it from the parent			var parent: TreeNode = this.parent;			if (parent != null)			{				// If child is to be moved down within parent, adjust index				if (parent == this && child.getIndex() < index)					index -= 1;				// Remove child				removeChild(child);			}			// If necessary, create new child list			if (__children == null)				__children = new Array();			// Add child node to list			__children.splice(index, 0, child);			child.addedTo(this);		}		// **** Child Class	    /**		 * Returns A child of a specified class or null.		 *		 * @param child_class class of child node method is to find		 * @return The first child of this node that is an instance of the		 *         specified class.		 */		public function getChildOfClass(child_class: Class): TreeNode		{			if (child_class == null)				throw new Error("Child class must be specifed");			if (__children == null)				return  null;			for each (var child: TreeNode in __children)			{				if (child is child_class)					return child;			}			return null;		}		// **** Descendants and Ancestors	    /**		 * Returns True only if one node is an ancestor of another.		 *		 * @param descendant possible descendant		 * @return True if descendant is actually a descendant, false otherwise		 */		override public function isAncestorOf(descendant: InternalNode): Boolean		{			if (descendant == null)				throw new Error("descendant is null");			var candidate: InternalNode = descendant.parent;			while (candidate != null && candidate != this)				candidate = candidate.parent;			return candidate == this;		}	    /**		 * Returns A list of descendsents of a specified node. The nodes in		 * the returned list are in post-order, that is leaf nodes before		 * parents.		 *		 * @return Array of all descendants of the node		 */		override public function descendents(): Array		{			var descendant_array: Array = new Array();			// Append all descendants from each child			for each (var child: TreeNode in __children)				descendant_array = descendant_array.concat(child.descendents());			// Add this node and return			descendant_array.push(this);			return descendant_array;		}	}}