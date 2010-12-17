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
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.containers.Canvas;

	public class PageDialRuler extends Canvas
	{
	    /** Position of top of tick mark. */
	    public static const MARK_TOP: int =  32;

	    /** Left margin. */
	    public static const MARK_LEFT: int =  12;

	    /** Maximum spread between marks. */
	    public static const MAXIMUM_SPREAD: int =  8;

		/** Cursor. */
		private var cursor: PageDialCursor;

		/** Pointer. */
		private var pointer: PageDialPointer;

		/** Background. */
		private var background: Canvas;

		/** Canvas for tick marks. */
		private var dial: Canvas;

		/** Outline displayed. */
		private var __outline: Outline;

		/** Longest chapter length. */
		private var longest_chapter_length: int;

		/** Width of tick items. */
		private var __item_width: int;

		/** Width of dial. */
		private var __dial_width: int;

		/** Length of dial in items. */
		private var __dial_length: int;

		/** Index of first item in current chapter. */
		private var chapter_index: int;

		/** Index of last item in current chapter. */
		private var chapter_end: int;

		/** Items shown in dial. */
		private var items: Array = new Array();

		/** Chapter header. */
		private var chapter_item: OutlineItem;

		/**
		 * Constructs a PageDialRuler.
		 */

		public function PageDialRuler()
		{
			super();

			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);

		}

		// **** Create Child Views

		override protected function createChildren():void
		{
			super.createChildren();

			background = new Canvas();
			background.percentWidth = 100;
			background.percentHeight = 100;
			background.setStyle("backgroundColor", 0xFFFFFF);
			addChild(background);

			dial = new Canvas();
			dial.percentWidth = 100;
			dial.percentHeight = 100;
			addChild(dial);

			cursor = new PageDialCursor();
			cursor.x = MARK_LEFT;
			cursor.y = MARK_TOP - 7;
			addChild(cursor);

			pointer = new PageDialPointer();
			pointer.x = MARK_LEFT;
			pointer.y = MARK_TOP - 7;
			addChild(pointer);
		}

		public function set outline(outline: Outline): void
		{
			__outline = outline;
			__outline.addEventListener(Event.CHANGE, onSelectionChange);

			measureChapters();
			computeItemWidth();

			onSelectionChange();
		}

		private function measureChapters(): void
		{
			longest_chapter_length = 0;
			for each (var chapter: OutlineItem in __outline.root.children)
			{
				var chapter_length: int = chapter.children.length;
				longest_chapter_length = Math.max(longest_chapter_length, chapter_length);
			}
			if (longest_chapter_length == 0)
				longest_chapter_length = __outline.root.children.length;
		}

		private function computeItemWidth(): void
		{
	        __dial_width = width - MARK_LEFT;
	        __item_width = __dial_width / (longest_chapter_length - 1);
	        if (__item_width > MAXIMUM_SPREAD)
	            __item_width = MAXIMUM_SPREAD;
	        __dial_length = Math.floor(__dial_width / __item_width);
		}

		// ****

		private function collectItems(): void
		{
			items = new Array();
			var chapter: OutlineItem = __outline.selected_chapter;

			// If no chapter, items is empty
			if (chapter == null)
				return;

			// Get items; get and remove chapter item
			items = chapter.descendents();
			if (items != null && items.length > 1)
			{
				var last_index: int = items.length - 1;
				chapter_item = items[last_index];
				items.splice(last_index, 1);
			}

			// Measure chapter
			chapter_index = chapter.item_index;

			//
			if (items.length > 0)
				chapter_end   = OutlineItem(items[items.length - 1]).item_index;
			else
				chapter_end = chapter_index;
		}

		private function indexOfItem(item: OutlineItem): int
		{
			return items.indexOf(item);
		}

		// **** Drawing

		override protected function updateDisplayList(width: Number, height: Number): void
		{
			super.updateDisplayList(width, height);
			if (__outline == null) return;
			drawDial();
		}

	    /**
	     * Draw tick marks.
	     */

	    private function drawDial(): void
	    {
	    	var graphics: Graphics = dial.graphics;
	    	graphics.clear();

	    	graphics.lineStyle(0, 0x000000, 100);
	    	graphics.drawRect(0, MARK_TOP - 12,
	    		items.length * __item_width + MARK_LEFT, height - MARK_TOP + 10);

	    	var left: int = MARK_LEFT;
	    	for each (var item: OutlineItem in items)
	    	{
		        if (item.hasChildren())
		        {
		            graphics.lineStyle(0, 0xEE0000, 100);
		            graphics.moveTo(left, MARK_TOP - 2);
		            graphics.lineTo(left, MARK_TOP + 2);
		        }
		        else
		        {
		            graphics.lineStyle(0, 0x000000, 100);
		            graphics.moveTo(left, MARK_TOP - 1);
		            graphics.lineTo(left, MARK_TOP + 1);
		        }
	    		left += __item_width;
	    	}

	    	drawChapterGuidelines();
	    }

	    private function drawChapterGuidelines(): void
	    {
	    	if (items.length == 0) return;

	    	var graphics: Graphics = dial.graphics;
			var selected_chapter: OutlineItem = __outline.selected_chapter;

			const from_x: int = (chapter_index * width) / __outline.items.length;
			const to_x: int = (chapter_end * width) / __outline.items.length;
			const FILL_COLOR: int = 0x0000FF;

            graphics.lineStyle(0, FILL_COLOR, 0);

            graphics.moveTo(0, MARK_TOP - 11);
			graphics.beginFill(FILL_COLOR, 0.2);
            graphics.lineTo(from_x, 0);
            graphics.lineTo(to_x, 0);
            graphics.lineTo(items.length * __item_width + MARK_LEFT, MARK_TOP - 11);
            graphics.lineTo(0, MARK_TOP - 11);

            graphics.endFill();
	    }

		// **** Mouse Tracking

		private function onMouseMove(event: MouseEvent): void
		{
	        if (__outline == null) return;

	        if (mouseX >= 5 && mouseX < (width - 5) && mouseY >= 5 && mouseY < (height - 5))
	        {
		        var index: int = mouseToItemIndex();
		        if (index < 0 || index >= items.length) return;
		        cursor.x = MARK_LEFT + index * __item_width;
		        cursor.text = OutlineItem(items[index]).title;
	        }
	        else
	        {
	        	cursor.x = MARK_LEFT + indexOfItem(__outline.selected) * __item_width;
	        	cursor.text = __outline.selected.title;
	        }
		}

	    /**
	     * Return an item index for a specified mouse position.
	     *
	     * @return item index for mouse position.
	     */

	    private function mouseToItemIndex(): int
	    {
	        // Compute item index
	        var index: Number = Math.round((mouseX - MARK_LEFT) / __item_width);
	        index = Math.max(0, Math.min(index, items.length - 1));
	        return index;
	    }

	    private function onMouseOut(event: MouseEvent): void
	    {
	    	onMouseMove(event);
	    }

	    private function onClick(event: MouseEvent): void
	    {
	    	if (__outline == null) return;
	    	var index: int = mouseToItemIndex();
	    	if (index >= 0 && index < items.length)
	    		__outline.selected = items[index];
	    }

	    private function onSelectionChange(event: Event = null): void
	    {

	    	const selected: OutlineItem = __outline.selected;
	    	var index: int = indexOfItem(selected);
	    	if (index < 0)
	    	{
	    		collectItems();
	    		index = indexOfItem(selected);
	    	}

			const x: int = MARK_LEFT + index * __item_width;
	    	pointer.x = x;
		    cursor.x = x;
		    cursor.text = selected.title;

		    invalidateDisplayList();
	    }

	}
}