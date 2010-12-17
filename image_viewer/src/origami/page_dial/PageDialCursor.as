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
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.core.UIComponent;

	/**
	 * Cursor that displays information about the item selected by the current
	 * mouse position.
	 *
	 * @author Jonathan A. Smith
	 */

	public class PageDialCursor extends UIComponent
	{
		private var label: String;

		private var label_field: Text;

		/** Background of label. */
		private var background: Canvas;

	    /** Offset of text from left edge of background graphic. */
	    private static var TEXT_OFFSET:    Number  =  4;

	    /** Buffer between right edge of PageDial and label. */
	    private static var RIGHT_BUFFER:    Number = 20;

	    /** Space from center occupired by the selector graphic. */
	    private static var SELECTOR_OFFSET: Number =  4;

		public function PageDialCursor()
		{
			super();
		}

		override protected function createChildren():void
		{
			super.createChildren();

			background = new Canvas();
			background.setStyle("backgroundColor", 0xFFFFFF);;
			background.setActualSize(500, 16)
			addChild(background);

			label_field = new Text();
			label_field.setActualSize(500, 16);
			addChild(label_field);
		}

		public function set text(text: String): void
		{
			label_field.width = 500;
			label_field.text = text;

			var label_width: Number = label_field.textWidth + 2 * TEXT_OFFSET;
			var right_space: Number = parent.parent.width - this.x - RIGHT_BUFFER;

			//label_field.setActualSize(label_width + 10, 20);
			//background.width = 500; //setActualSize(label_width, 16);
			background.width = label_width;

	        // If no space to right of pointer, flip label to left
	        if (right_space < label_field.width)
	        {
	            background.x = -label_width - SELECTOR_OFFSET;
	            label_field.x = TEXT_OFFSET - label_width - SELECTOR_OFFSET;
	        }
	        else
	        {
	            background.x = SELECTOR_OFFSET;
	            label_field.x = SELECTOR_OFFSET + TEXT_OFFSET;
	        }
		}

		override protected function updateDisplayList(unscaledWidth: Number, unscaledHeight: Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

	        graphics.clear();
	        graphics.lineStyle(0, 0xEE0000, 100);
	        var top: Number = 10;
	        graphics.moveTo( 0, top);
	        graphics.lineTo( 4, top + 4);
	        graphics.lineTo(-4, top + 4);
	        graphics.lineTo( 0, top);
		}

	}
}