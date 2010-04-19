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

package origami.viewer
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.managers.CursorManager;
	
	import origami.geometry.Rectangle;

	public class SelectionRectangle extends Canvas
	{
		/** Arrow mouse cursor. */
		[Embed(source="../assets/viewer.swf", symbol="viewerArrowPointer")] 
		private var arrowPointer: Class;
		
		/** ID of current mouse pointer. */
		private var cursor_id: Number;
		
		/**	Rectangle color. */
		private var color: int = 0x00ff00;
		
		/**
		 * Constructs a SelectionRectangle.
		 */
		
		public function SelectionRectangle()
		{
			super();
		}
		
		/**
		 * Shows the selection rectangle at a specified location and starts tracking
		 * the mouse to find the selection size.
		 *
		 * @param x x position of selection
		 * @param y y position of selections
		 */
		
		public function showAt(x: Number, y: Number): void
		{
			this.x = x;
			this.y = y;
			this.width = 0;
			this.height = 0;
			visible = true;
			parent.setChildIndex(this, parent.numChildren - 1);
			
			parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			updateDisplayList(width, height);
			cursor_id = CursorManager.setCursor(arrowPointer, 1);
		}
		
		/**
		 * Tracks mouse movements by adjusting the size of the selection rectangle.
		 * 
		 * @param event mouse event
		 */
		
		private function onMouseMove(event: MouseEvent): void
		{
			width = mouseX;
			height = mouseY;
			updateDisplayList(width, height);
		}
		
		/**
		 * Finishes tracking the mouse, making the seleciton rectangle invisible. 
		 * Dispatches a SelectionEvent with the selection rectangle.
		 * 
		 * @param event mouse event
		 */
		
		private function onMouseUp(event: MouseEvent): void
		{
			// Hide selection rectangle
			visible = false;
			
			// Remove listeners
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			parent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Reset mouse pointer
			CursorManager.removeCursor(cursor_id);
			
			// Signal selection to listeners
			this.dispatchEvent(
				new SelectionEvent(Rectangle.makeLeftTopWidthHeight(x, y, width, height)));
		}
		
		/**
		 * Draws the view.
		 */
		 
		override protected function updateDisplayList(width: Number, height: Number): void
		{
			graphics.clear();
			graphics.lineStyle(1, color);
			graphics.moveTo(    0,      0);
			graphics.lineTo(width,      0);
			graphics.lineTo(width, height);
			graphics.lineTo(    0, height);
			graphics.lineTo(    0,      0);
		}
		
		/**
		 * Sets the rectangle color.
		 */
		 
		public function setColor (color: int): void
		{
			this.color = color;
		}
		
	}
}