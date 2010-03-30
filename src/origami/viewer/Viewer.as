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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;
	
	import origami.framework.Component;
	import origami.geometry.Dimensions;
	import origami.geometry.Point;
	import origami.spatial.Viewport;

	public class Viewer extends Component
	{
		[Embed(source="../assets/viewer.swf", symbol="viewerZoomInPointer")] 
		private var zoomInPointer: Class; 
		
		[Embed(source="../assets/viewer.swf", symbol="viewerZoomOutPointer")] 
		private var zoomOutPointer: Class; 
		
		[Embed(source="../assets/viewer.swf", symbol="viewerPanPointer")] 
		private var panPointer: Class;  
		
		/** Id of current mouse pointer. */
		private var cursor_id: Number;
		
		/** Viewport controling this component's view. */
		public var viewport: Viewport;
		
		/** Visible rectangle used to select an area of the image. */
		private var selection_rectangle: SelectionRectangle;
		
		/** Viewer Model. */
		private var __viewer_model: ViewerModel;
		
		/** True only when Viewer is initialized. */
		private var is_initialized: Boolean = false;
		
		public function Viewer()
		{
			super();			
			__viewer_model = new ViewerModel();
			__viewer_model.addEventListener(Event.CHANGE, updateMousePointer);
			
			viewport = new Viewport();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(Event.MOUSE_LEAVE, onPanRelease);
			
			addEventListener(ResizeEvent.RESIZE, onResize);
			addEventListener(Event.ADDED_TO_STAGE, initializeKeyboard);
			
			// Change cursor on mouse over, out
			addEventListener(MouseEvent.MOUSE_OVER, updateMousePointer);
			addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
		}
		
		/**
		 * Create the viewport and initialize the view. Any additional views
		 * should be added after this is called.
		 */
		
		override protected function createChildren(): void
		{			
			super.createChildren();
			
			// Create selection rectangle
			selection_rectangle = new SelectionRectangle();
			selection_rectangle.addEventListener(SelectionEvent.SELECT, onSelect);
			addChild(selection_rectangle);
			
			// Initialize the mouse pointer
			updateMousePointer();
		}
		
		/**
		 * Adds listeners to respond to key press events.
		 * 
		 * @param event added to stage event
		 */
		
		private function initializeKeyboard(event: Event): void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		/**
		 * Returns the viewer model.
		 * 
		 * @return ViewerModel
		 */
		 
		public function get viewer_model(): ViewerModel
		{
			return __viewer_model;
		}
		
		/**
		 * Called when view is resized.
		 * 
		 * @param event resize event
		 */
		
		private function onResize(event: ResizeEvent): void
		{			
			if (!is_initialized)
			{
				addEventListener(Event.ENTER_FRAME, stepAnimation);			
				is_initialized = true;
			}
			
			viewport.setViewSize(Dimensions.makeWidthHeight(width, height));
			invalidateDisplayList();
		}
		
		// **** Mouse Tracking
		
		/**
		 * Display the selection rectangle at the current mouse position.
		 * 
		 * @param event mouse event
		 */
		
		private function onMouseDown(event: MouseEvent): void
		{
			if (!is_initialized) return;
			switch(__viewer_model.mode)
			{
				case ViewerModel.PAN_MODE:
					viewport.startPan(Point.makeXY(mouseX, mouseY));
					addEventListener(MouseEvent.MOUSE_MOVE, onPanMove);
					addEventListener(MouseEvent.MOUSE_UP, onPanRelease);
					break;
					
				case ViewerModel.ZOOM_IN_MODE:
				case ViewerModel.ZOOM_OUT_MODE:
					selection_rectangle.showAt(mouseX, mouseY);
					break;
			}
		}
		
		/**
		 * Track mouse movement
		 */
		 
		private function onPanMove(event: MouseEvent): void
		{
			viewport.pan(Point.makeXY(mouseX, mouseY));
		}
		
		/**
		 * Finish mouse tracking.
		 */
		 
		private function onPanRelease(event: MouseEvent): void
		{
			// if not pan in progress, return 
			if (!viewport.is_panning) return;
			
			// Finish pan, remove listeners
			viewport.finishPan();
			removeEventListener(MouseEvent.MOUSE_MOVE, onPanMove);
			removeEventListener(MouseEvent.MOUSE_UP, onPanRelease);	
			//drag_start = null;	
		}
		
		/**
		 * Respond to selection of an area by the user.
		 */
		 
		private function onSelect(event: SelectionEvent): void
		{
			if (!is_initialized) return;
			switch (__viewer_model.mode)
			{
				case ViewerModel.ZOOM_IN_MODE:
					viewport.zoomInBox(event.selection_rectangle);
					break;
				case ViewerModel.ZOOM_OUT_MODE:
					viewport.zoomOutBox(event.selection_rectangle);
					break;
			}

		}
		
		// **** Mouse Cursor
		
		/**
		 * Update the mouse pointer depending on mode.
		 */
		 
		private function updateMousePointer(event: Event = null): void
		{
			if (mouseX < 0 || mouseX > width) return;
			if (mouseY < 0 || mouseY > height) return;
			
			// Remove old cursor
			if (cursor_id)
				CursorManager.removeCursor(cursor_id);
				
			// Set new cursor depending on mode
			switch (__viewer_model.mode)
			{
				case ViewerModel.ZOOM_IN_MODE:
					cursor_id = CursorManager.setCursor(zoomInPointer);
					break;
				case ViewerModel.ZOOM_OUT_MODE:
					cursor_id = CursorManager.setCursor(zoomOutPointer);
					break;
				case ViewerModel.PAN_MODE:
					cursor_id = CursorManager.setCursor(panPointer);
					break;
			}
		}
		
		/**
		 * Removes the mouse pointer for this view.
		 * 
		 * @param event mouse event
		 */
		
		private function onRollOut(event: Event): void
		{
			if (!cursor_id) return;
			CursorManager.removeCursor(cursor_id);
			cursor_id = 0;
		}
		
		// **** Mode Changes

		/**
		 * Set pan or zoom mode.
		 * 
		 * @param mode PAN_MODE or ZOOM_MODE
		 */
		 
		public function setMode(mode: Number): void
		{
			__viewer_model.mode = mode;
			updateMousePointer();
		}
		
		/**
		 * Updates the viewer mode on key press.
		 */
		
		private function onKeyDown(event: KeyboardEvent): void
		{
			updateMode(event.shiftKey, event.altKey, event.ctrlKey);
		}
		
		/**
		 * Updates the viewer mode on key release.
		 */
		
		private function onKeyUp(event: KeyboardEvent): void
		{
			updateMode(event.shiftKey, event.altKey, event.ctrlKey);
		}
		
		/**
		 * Updates the mode on a key press or release.
		 */
		
		private function updateMode(shift_key: Boolean, alt_key: Boolean, control_key: Boolean): void
		{
			if (__viewer_model.isTemporaryMode())
				updateTemporaryMode(shift_key, alt_key, control_key);
			else
				updatePermenentMode(shift_key, alt_key, control_key);
		}
		
		/**
		 * Updates the mode on a key press or release.
		 */
		
		private function updatePermenentMode(shift_key: Boolean, alt_key: Boolean, control_key: Boolean): void
		{
			switch(__viewer_model.mode)
			{
				case ViewerModel.ZOOM_IN_MODE:
					if (shift_key) 
						__viewer_model.pushMode(ViewerModel.PAN_MODE);
					else if (alt_key || control_key)
						__viewer_model.mode = ViewerModel.ZOOM_OUT_MODE;
					break;
					
				case ViewerModel.ZOOM_OUT_MODE:
					if (shift_key) 
						__viewer_model.pushMode(ViewerModel.PAN_MODE);
					else if (!alt_key && !control_key)
						__viewer_model.mode = ViewerModel.ZOOM_IN_MODE;
					break;
					
				case ViewerModel.PAN_MODE:
					if (shift_key) 
					{
						if (alt_key || control_key)
							__viewer_model.pushMode(ViewerModel.ZOOM_OUT_MODE);
						else
							__viewer_model.pushMode(ViewerModel.ZOOM_IN_MODE);
					}
					break;
			}
		}
		
		/**
		 * Updates the mode on a key press or release.
		 */
		
		private function updateTemporaryMode(shift_key: Boolean, alt_key: Boolean, control_key: Boolean): void
		{
			switch(__viewer_model.mode)
			{
				case ViewerModel.ZOOM_IN_MODE:
					if (!shift_key) 
						__viewer_model.mode = ViewerModel.PAN_MODE;
					else if (alt_key || control_key)
						__viewer_model.pushMode(ViewerModel.ZOOM_OUT_MODE);
					break;
					
				case ViewerModel.ZOOM_OUT_MODE:
					if (!shift_key) 
						__viewer_model.mode = ViewerModel.PAN_MODE;
					else if (!alt_key && !control_key)
						__viewer_model.pushMode(ViewerModel.ZOOM_IN_MODE);
					break;
					
				case ViewerModel.PAN_MODE:
					if (!shift_key) 
					{
						if (alt_key || control_key)
							__viewer_model.mode = ViewerModel.ZOOM_OUT_MODE;
						else
							__viewer_model.mode = ViewerModel.ZOOM_IN_MODE;
					}
					break;
			}
		}
		
		// **** Animation
		
		/**
		 * Calls stepAnimation on the viewport to animate zooms.
		 * 
		 * @param event frame event
		 */
		 
		private function stepAnimation(event: Event): void
		{
			viewport.stepAnimation();
		}
		
	}
}