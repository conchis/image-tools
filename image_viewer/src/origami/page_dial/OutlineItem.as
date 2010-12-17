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
	import origami.trees.InternalNode;

	/**
	 * An item in an index for a a "volume" a collection of pages kept in a volume.
	 *
	 * @author Jonathan A. Smith
	 */

	public class OutlineItem extends InternalNode
	{
		/** Item id (must be uneque) or null. */
		private var __id: String;

		/** Human readable title of this node. */
		private var __title: String;

		/** URL of resource. */
		private var __resource: String;

		/** Index of item. */
		private var __item_index: int;

		/**
		 * Constructs a new outline item.
		 *
		 * @param id (optional) id of item
		 * @param title (optional) title of item
		 * @param resource (optional) URL of associated resource
		 */

		public function OutlineItem(id: String = null, title: String = null, resource: String = null)
		{
			super();
			__id = id;
			__title = title;
			__resource = resource;
		}

		// **** Accessors

		/**
		 * Sets the item id.
		 *
		 * @param id
		 */

		public function set id(id: String): void
		{
			this.__id = id;
		}

		/**
		 * Returns the item id.
		 *
		 * @return item id
		 */

		public function get id(): String
		{
			return this.__id;
		}

		/**
		 * Sets the item title.
		 *
		 * @param title item title
		 */

		public function set title(title: String): void
		{
			this.__title = title;
		}

		/**
		 * Returns the item title.
		 *
		 * @return title
		 */

		public function get title(): String
		{
			return this.__title;
		}

		/**
		 * Sets the resource URL associated with this item.
		 *
		 * @param resource resource URL asscocated with this item
		 */

		public function set resource(resource: String): void
		{
			this.__resource = resource;
		}

		/**
		 * Returns the resource URL associated with this item.
		 *
		 * @return resource URL assocated with the item
		 */

		public function get resource(): String
		{
			return this.__resource;
		}

		public function set item_index(index: int): void
		{
			__item_index = index;
		}

		public function get item_index(): int
		{
			return __item_index;
		}

		// **** Chapter

		public function get chapter(): OutlineItem
		{
			var examine: OutlineItem = OutlineItem(parent);
			if (examine == null || examine.isRoot())
				return this;

			while (!examine.parent.isRoot())
				examine = OutlineItem(examine.parent);

			return examine;
		}

		// **** XML Conversion

		/**
		 * Builds a new OutlineItem represenation from an XML representation.
		 *
		 * @param xml XML representation of an item
		 */

		public static function fromXML(xml: XML): OutlineItem
		{
			var item: OutlineItem = new OutlineItem();

			var id: String = xml.@id;
			if (id != "") item.__id = id;

			var title: String = xml.@title;
			if (title != "") item.__title = title;

			var resource: String = xml.@resource;
			if (resource != "") item.__resource = resource;

			for each (var child_xml: XML in xml.item)
				item.addChild(fromXML(child_xml));

			return item;
		}

		/**
		 * Returns an XML represenation of the item and children.
		 *
		 * @return XML represenation.
		 */

		public function toXML(): XML
		{
			var element: XML = <item />;

			// Attributes
			if (__id != null)
				element.@id = __id;
			if (__title != null)
				element.@title = __title;
			if (__resource != null)
				element.@resource = __resource;

			// Sub-items
			if (this.hasChildren())
			{
				var children: Array = this.children;
				for each (var child: OutlineItem in children)
					element.appendChild(child.toXML());
			}

			return element;
		}

		// **** String Representation

		/**
		 * Returns an XML string representation of the item (with children.)
		 *
		 * @return String representation
		 */

		override public function toString(): String
		{
			return toXML().toXMLString();
		}
	}
}