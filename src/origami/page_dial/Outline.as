/**
 * Copyright 2004 - 2010 Northwestern University and Jonathan A. Smith
 *
 * <p>Licensed under the Educational Community License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at</p>
 *
 * http://www.osedu.org/licenses/ECL-2.0
 *
 * <p>Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS"
 * BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * permissions and limitations under the License.</p>
 */

package origami.page_dial
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * An outline is a tree-structured index of web-based materials that may
	 * be navigated using the PageDial.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Outline implements IEventDispatcher
	{
		/** Root of item tree. */
		private var __root: OutlineItem = null;

		/** Flattened array of items. */
		private var __items: Array;

		/** Index of first selectable item. */
		private var __first_selectable: int;

		/** Index of last selectable item. */
		private var __last_selectable: int;

		/** Selected item index. */
		private var __selected_index: int = 0;

	    /** Event dispatcher. */
	    private var dispatcher: EventDispatcher = new EventDispatcher();

		/**
		 * Constructs an Outline.
		 */

		public function Outline()
		{
			super();
		}

		// **** Accessors

		/**
		 * Returns the root of the tree of OutlineItems.
		 *
		 * @return root OutlineItem
		 */

		public function get root(): OutlineItem
		{
			return __root;
		}

		/**
		 * Sets the index of a selected item. If the item at the specified index
		 * is not selectable (that is has no attached resource URL), the selection
		 * is skipped ahead to the first item that allows selection.
		 *
		 * @param index index of new selected item
		 */

		public function set selected_index(index: int): void
		{
			const items: Array = this.items;
			const last_index: int = items.length - 1;

			index = Math.max(0, Math.min(last_index, index));

	    	while (index < last_index && items[index].resource == null)
	    		index += 1;
	    	if (index != __selected_index)
	    	{
				__selected_index = index;
				dispatchEvent(new Event(Event.CHANGE));
	    	}
		}

		/**
		 * Returns the index of the selected item in the items array.
		 *
		 * @return index of selected item
		 */

		public function get selected_index(): int
		{
			return __selected_index;
		}

		/**
		 * Sets the selected item.
		 *
		 * @param item the item to select
		 */

		public function set selected(item: OutlineItem): void
		{
			selected_index = item.item_index;
		}

		/**
		 * Returns the selected OutlineItem in the outline.
		 *
		 * @return selected OutlineItem
		 */

		public function get selected(): OutlineItem
		{
			return items[__selected_index];
		}

		/**
		 * Selects an item in the outline given the item's id string.
		 *
		 * @param id id of desired selection (from outline XML).
		 */

		public function selectById(id: String): void
		{
			const items: Array = this.items;
			var index: int = 0;
			for each (var item: OutlineItem in items)
			{
				if (item.id == id)
				{
					selected_index = index;
					return;
				}
				index += 1;
			}
		}

		/**
		 * Returns an array of items. If first time, computes first and last
		 * selectable item.
		 *
		 * @return Array of outline items.
		 */

		public function get items(): Array
		{
			if (__items != null)
				return __items;
			if (__root == null)
				return [];

			__first_selectable = -1;
			__items = new Array();
			var examine: OutlineItem = __root;
			while (examine != null)
			{
				examine.item_index = __items.length;
				__items.push(examine);
				if (__first_selectable == -1 && examine.resource != null)
					__first_selectable = __items.length - 1;
				if (examine.resource != null)
					__last_selectable = __items.length - 1;
				examine = OutlineItem(examine.next());
			}

			return __items;
		}

		/**
		 * Returns true only if a specified item is the selected item of an
		 * ancestor of the selected item.
		 *
		 * @param item item to test
		 * @return true if item is on selected path, false otherwise.
		 */

		public function isOnSelectedPath(item: OutlineItem): Boolean
		{
			var examine: OutlineItem = this.selected;
			while (examine != null)
			{
				if (examine === item) return true;
				examine = OutlineItem(examine.parent);
			}
			return false;
		}

		/**
		 * Returns the current selection's chapter node. A node's chapter node is the
		 * ancesstor who's parent is the root node, or if the node is just under the
		 * root node, the node itself.
		 */

		public function get selected_chapter(): OutlineItem
		{
			var selected: OutlineItem = this.selected;
			if (selected == null) return null;
			return selected.chapter;
		}

		// **** Commands

		/**
		 * Returns true only if the selection may be moved to the first
		 * selectable item.
		 *
		 * @param true only if it is possible to return to first selectable item
		 */

		public function canFirst(): Boolean
		{
			if (__root == null) return false;
			return __selected_index > __first_selectable;
		}

		/**
		 * Returns selection to the first selectable item (if possible.) Note
		 * this method accepts an event argument so it may be used directly
		 * as a callback method.
		 *
		 * @param event control event
		 */

		public function first(event: Event = null): void
		{
			selected_index = __first_selectable;
		}

		/**
		 * Returns true only if it is possible to jump to the last selectable item
		 * in the outline.
		 *
		 * @return true only if possible to jump to last selectable item
		 */

		public function canLast(): Boolean
		{
			if (__root == null) return false;
			return __selected_index < __last_selectable;
		}

		/**
		 * Moves the selection to the last selectable item in the outline.
		 * This method accepts an optional event argument so it may be used
		 * as a control callback.
		 *
		 * @param event control event.
		 */

		public function last(event: Event = null): void
		{
			selected_index = __last_selectable;
		}

		/**
		 * Returns true only if possible to avance the selection to the next
		 * item in the outline.
		 *
		 * @return true only if possible to advance to the last selectable item
		 */

		public function canNext(): Boolean
		{
			if (__root == null) return false;
			return __selected_index < __last_selectable;
		}

		/**
		 * Advance the selection to the next selectable item in the outline.
		 * This method accepts an optional event argument so it may be used
		 * as a control callback.
		 *
		 * @param event control event.
		 */

		public function next(event: Event = null): void
		{
			selected_index += 1;
		}

		/**
		 * Returns true only if possible to move the selection to the previous
		 * item in the outline.
		 *
		 * @return true only if possible to advance to a previous selectable item
		 */

		public function canPrevious(): Boolean
		{
			if (__root == null) return false;
			return __selected_index > __first_selectable;
		}

		/**
		 * Move the selection to the previous selectable item in the outline.
		 * This method accepts an optional event argument so it may be used
		 * as a control callback.
		 *
		 * @param event control event.
		 */

		public function previous(event: Event = null): void
		{
			var index: int = __selected_index - 1;
			while (index > __first_selectable && items[index].resource == null)
				index -= 1;
			selected_index = index;
		}

		// **** Event Dispatch

		/**
		 * Registers an event listener object with an EventDispatcher object so
		 * that the listener receives notification of an event.
		 */

		public function addEventListener(type: String, listener: Function, use_capture: Boolean = false,
				priority: int = 0, use_weak_reference: Boolean = false): void
		{
			dispatcher.addEventListener(type, listener, use_capture, priority,
					use_weak_reference);
		}

		/**
		 * Dispatches an event into the event flow.
		 */

		public function dispatchEvent(event: Event): Boolean
		{
			return dispatcher.dispatchEvent(event);
		}

		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 */

		public function hasEventListener(type: String): Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 */

		public function removeEventListener(type: String, listener: Function,
				use_capture: Boolean = false): void
		{
			dispatcher.removeEventListener(type, listener, use_capture);
		}

		/**
		 * Checks whether an event listener is registered with this
		 * EventDispatcher object or any of its ancestors for the
		 * specified event type.
		 */

		public function willTrigger(type: String): Boolean
		{
			return dispatcher.willTrigger(type);
		}

		// **** XML and String Conversion

		/**
		 * Constructs a new Outline object from an XML representation.
		 *
		 * @param xml XML representation of the outline.
		 */

		public static function fromXML(xml: XML): Outline
		{
			var outline: Outline = new Outline();
			var root_xml: XML = xml.item[0];
			outline.__root = OutlineItem.fromXML(root_xml);
			outline.selected_index = 0;
			return outline;
		}

		/**
		 * Returns an XML DOM tree representing this outline.
		 *
		 * @return outline XML
		 */

		public function toXML(): XML
		{
			var outline_xml: XML = <outline />;
			if (__root != null)
				outline_xml.appendChild(__root.toXML());
			return outline_xml;
		}

		/**
		 * Returns a string representation of this outline.
		 *
		 * @return XML string representation of outline
		 */

		public function toString(): String
		{
			return toXML().toXMLString();
		}

	}
}