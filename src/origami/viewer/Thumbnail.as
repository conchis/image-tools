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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import origami.geometry.Dimensions;
	import origami.geometry.Point;
	import origami.geometry.Polygon;
	import origami.geometry.Transform;
	import origami.spatial.Viewport;
	
	/**
	 * A thumbnail view and allows the user to navigate using that view.
	 * 
	 * @author Jonathan A. Smith
	 */

	public class Thumbnail extends UIComponent
	{
		/** Width of thumbail image. */
		public static const THUMBNAIL_WIDTH: int = 150;
		
		/** Viewport model for this viewer controled by this view. */
		private var __viewport: Viewport;
		
		/** URL of the thumbnail image. */
		private var __thumbnail_url: String;
		
		/** Image loader. */
		private var loader: Loader;
		
		/** Thumbnail iamge. */
		private var thumbnail: Bitmap;
		
		/** Canvas for drawing selection rectangle. */
		private var selection_canvas: Canvas;
		
		/** Transform from scene to naviagtor coordinates. */
		private var navigator_transfrom: Transform;
		
		/** Transform from navigator to scene coordinates. */
		private var scene_transform: Transform;
		
		/**
		 * Constructs a thumbnail.
		 */
		
		public function Thumbnail()
		{
			super();
			width = THUMBNAIL_WIDTH;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);			
		}
		
		/**
		 * Sets the viewport model for this control
		 * 
		 * @param viewport viewport model
		 */
		
		public function set viewport(viewport: Viewport): void
		{
			viewport.addEventListener(Viewport.CHANGED, onUpdate);
			viewport.addEventListener(Viewport.UPDATE, onUpdate);
			
			__viewport = viewport;
			onUpdate(null);
		}
		
		/**
		 * Returns the viewport model for this control.
		 * 
		 * @return viewport model
		 */
		
		public function get viewport(): Viewport
		{
			return __viewport;
		}
		
		/**
		 * Sets the URL used to obtain the thumbnail.
		 * 
		 * @param thumbnail_url URL of the thumbnail
		 */
		
		public function set thumbnail_url(thumbnail_url: String): void
		{
			__thumbnail_url = thumbnail_url;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onImageLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(new URLRequest(thumbnail_url));
		}
		
		/**
		 * Returns the URL of the thumbnail.
		 * 
		 * @return image url
		 */
		
		public function get thumbnail_url(): String
		{
			return __thumbnail_url;
		}
		
		/**
		 * Method called when thumbnail is loaded.
		 * 
		 * @param event image loaded event
		 */
		
		private function onImageLoaded(event: Event): void
		{
			if (thumbnail) removeChild(thumbnail);
			
			// Add thumbnail graphics
			thumbnail = Bitmap(loader.content);
			addChild(thumbnail);
			
			// Add canvas for drawing selection
			selection_canvas = new Canvas();
			selection_canvas.blendMode = BlendMode.INVERT;
			addChild(selection_canvas);
			
			this.width = thumbnail.width;
			this.height = thumbnail.height;
			
			// Force parent view to redraw with thumbnail in correct position
			UIComponent(parent).invalidateDisplayList();
			
			// Dispatch complete event.
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Sets the thumbnail bitmap data.
		 * 
		 * @param data New bitmap data.
		 */
		 
		public function setBitmapData (data: BitmapData): void
		{
			thumbnail.bitmapData = data;
		}
		
		/**	Handles IO error events.
		 * 
		 *  @param	event		IO error event.
		 */
		 
		private function onIOError (event: IOErrorEvent): void
		{
			dispatchEvent(event);
		}
		
		/**
		 * Respond to changes in view.
		 * 
		 * @param event change event
		 */
		 
		private function onUpdate(event: Event): void
		{
			updateTransforms();
			invalidateDisplayList();
		}
		
		/**
		 * Update transforms used to go from navigator to scene coordinates
		 * and back.
		 */
		 
		private function updateTransforms(): void
		{	
			var scene_size: Dimensions = viewport.initial_scene_size;
			var scale: Number = THUMBNAIL_WIDTH / scene_size.width;
			navigator_transfrom = Transform.makeScale(scale, scale);
			scene_transform = navigator_transfrom.inverse();
		}
		
		// **** Drawing
		
		/**
		 * Draw the selection rectnagle over the thumbnail.
		 * 
		 * @param width unscaled view width
		 * @param height unscaled view height
		 */
		
		override protected function updateDisplayList(width: Number, height: Number): void
		{
			super.updateDisplayList(width, height);
			if (viewport == null || __thumbnail_url == null || selection_canvas == null
				|| navigator_transfrom == null) return;
			
			var graphics: Graphics = selection_canvas.graphics;
			graphics.clear();		
			var view_polygon: Polygon = viewport.clipped_view_polygon.project(navigator_transfrom);
			graphics.lineStyle(1);			
			view_polygon.drowOn(selection_canvas.graphics);
		}
		
		// **** Mouse Tracking
		
		public function onMouseDown(event: MouseEvent): void
		{			
			parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			event.stopPropagation();
			
			onMouseMove(event);
		}
		
		/**
		 * Tracks mouse movements and pans the viewport.
		 * 
		 * @param event mouse event
		 */
		
		private function onMouseMove(event: MouseEvent): void
		{
			var scroll_point: Point = 
					scene_transform.project(Point.makeXY(mouseX, mouseY));
			viewport.updateView(viewport.scale, scroll_point);
			viewport.dispatchEvent(new Event(Viewport.CHANGED));
		}
		
		/**
		 * Finishes tracking the mouse by removing listeners.
		 * 
		 * @param event mouse event
		 */
		
		private function onMouseUp(event: MouseEvent): void
		{
			// Remove mouse listeners
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			parent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Tell viewport of change
			viewport.dispatchEvent(new Event(Viewport.CHANGED));
		}
		
	}
}