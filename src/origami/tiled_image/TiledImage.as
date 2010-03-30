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
 
package origami.tiled_image
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import origami.geometry.Angles;
	import origami.geometry.Dimensions;
	import origami.geometry.Point;
	import origami.geometry.Transform;
	import origami.spatial.Viewport;
	
	/**
	 * Pyramid tiled zooming image.
	 * 
	 * @author Jonathan A. Smith
	 */

	public class TiledImage extends UIComponent
	{
		/** Model of tiled image. */
		private var __image_model: ImageModel;
		
		/** Size of tiles. */
		public const TILE_SIZE: Dimensions = Dimensions.makeWidthHeight(256, 256);
		
		/** Tiled image layers. */
		private var layers: Array;
		
		/** Viewport controling this component's view. */
		private var __viewport: Viewport;
		
		/** Set to true only after initialization is complete. */
		private var is_initialized: Boolean = false;
		
		/**	Palette map. */
		private var __redArray: Array = null;
		private var __greenArray: Array = null;
		private var __blueArray: Array = null;
		
		/**
		 * Constructs a TimedImage.
		 */
		
		public function TiledImage()
		{
			super();
			addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
		// **** Image Model
		
		/**
		 * Sets the image model.
		 * 
		 * @param image_model new image model
		 */
		 
		public function set image_model(image_model: ImageModel): void
		{
			__image_model = image_model;
			initializeView();
			invalidateDisplayList();
		}
		
		/**
		 * Returns the image model.
		 * 
		 * @return the ImageModel
		 */
		 
		public function get image_model(): ImageModel
		{
			return __image_model;
		}
		
		// **** Viewport
		
		/**
		 * Sets the image viewport.
		 * 
		 * @param viewport Viewport object controling this view.
		 */
		 
		public function set viewport(viewport: Viewport): void
		{
			viewport.addEventListener(Viewport.CHANGED, onChanged);
			viewport.addEventListener(Viewport.UPDATE, onUpdate);			
			
			__viewport = viewport;
		}
		
		/**
		 * Returns the viewport.
		 * 
		 * @return viewport controling this view
		 */
		 
		public function get viewport(): Viewport
		{
			return __viewport;
		}
		
		// **** Initialization
		
		/**
		 * Initializes the view if not yet initialized. This includes setting up the viewpart,
		 * the Pyramid model, and creating tiled layers.
		 */
		
		private function initializeView(): void
		{
			// Postpone if not ready
			if (is_initialized || __image_model == null || width == 0) 
				return;
				
			// Set view and image size
			viewport.setSceneSize(__image_model.image_size);
			
			// Initialize layers and start tile load
			makeLayers();
			load();
			
			// Refresh display later
			is_initialized = true;
			invalidateDisplayList();
		}
		
		/**
		 * Creates image layers.
		 */
		
		private function makeLayers(): void
		{
			var layer_count: int = __image_model.layer_count;
			layers = new Array(layer_count);
			for (var layer_number: int = 0; layer_number < layer_count; layer_number += 1)
			{
				var layer: TiledImageLayer = new TiledImageLayer();
				addChild(layer);
				layers[layer_number] = layer;			
				layer.setImage(this, layer_number);
			}
		}
		
		// **** Resize View
		
		/**
		 * Called when view is resized.
		 */
		
		private function onResize(event: ResizeEvent): void
		{
			initializeView();
			
			if (is_initialized)
			{
				load();
			}
			
			invalidateDisplayList();
		}
		
		// **** Load Tiles and Refresh View
		
		/**
		 * Loads the visible contents of the view.
		 *
		 * @param __viewport Viewport describing the visible area of the image
		 */
		 
		public function load(): void
		{
			// Compute layer for view
			var layer_number: int = __image_model.layerForScale(__viewport.scale);
														
			// Load tiles in view
			layers[layer_number].load(__viewport);
		}
		
		/**
		 * Draws the view. Note that this occurs after tile loading is underway.
		 *
		 * @param width new view width
		 * @param height new view height
		 */
		 
		override protected function updateDisplayList(width: Number, height: Number): void
		{
			if (!is_initialized) return;

			// Reset view position and rotation
			rotation = 0;
			x = 0;
			y = 0;
			
			// Compute layer for view
			var layer_number: int = __image_model.layerForScale(__viewport.scale);
			
			// Hide more detailed layers
			for (var index: int = layer_number + 1; index < layers.length; index += 1)
				layers[index].visible = false;
				
			//var origin = __viewport.view_polygon.bounds.top_left.project(__viewport.view_transform2);
			
			var dimensions: Dimensions = 
				__viewport.view_polygon.bounds.dimensions.scale(__viewport.scale);
			var layer_x: Number = (width - dimensions.width) /2; // FIXME make this clearer
			var layer_y: Number = (height - dimensions.height) / 2;
				
			// Draw the layer and larger (rougher) tiles behind while this loads
			for (var layer_index: int = layer_number; layer_index >= 0; layer_index -= 1)
			{
				var layer: TiledImageLayer = layers[layer_index];
				layer.display(__viewport);
				layer.x = layer_x;
				layer.y = layer_y;
			}
			
			// Rotate view
			rotateView();
		}
		
		private function rotateView(): void
		{
			var radians: Number = __viewport.rotation;
			var degrees: Number = Angles.toDegrees(radians);
			
			// Offset to rotate center point
			var center: Point = Point.makeXY(width/2, height/2).project(Transform.makeRotate(radians));
			x = (width / 2) - center.x;
			y = (height / 2) - center.y;
			
			// Apply rotation
			rotation = degrees;
		}
		
		// **** Viewport and Viewport Event Handling
		
		/**
		 * Responds to an update event from the __viewport by immedeatly redrawing the view.
		 * 
		 * @param event update event
		 */
		 
		private function onUpdate(event: Event): void
		{
			if (is_initialized) updateDisplayList(width, height);
		}
		
		/**
		 * Responds to a changed event from the viewport by loading new exposed tiles
		 * and updating the view.
		 * 
		 * @param event changed event
		 */
		 
		private function onChanged(event: Event): void
		{
			if (is_initialized)
			{
				load();
				invalidateDisplayList();
			}
		} 
		
		/**
		 * Sets the palette map.
		 * 
		 * @param redArray Red map.
		 * @param greenArray Green map.
		 * @param blueArray Blue map.
		 */
		 
		public function setPaletteMap (redArray: Array, greenArray: Array, 
			blueArray: Array): void
		{
			__redArray = redArray;
			__greenArray = greenArray;
			__blueArray = blueArray;
			for (var i: int = 0; i < layers.length; i++)
			{
				layers[i].setPaletteMap();
			}
		}
		
		/**
		 * Gets the palette map red array.
		 * 
		 * @return The palette map red array.
		 */
		 
		public function get redArray (): Array
		{
			return __redArray;
		}
		
		/**
		 * Gets the palette map green array.
		 * 
		 * @return The palette map green array.
		 */
		 
		public function get greenArray (): Array
		{
			return __greenArray;
		}
		
		/**
		 * Gets the palette map blue array.
		 * 
		 * @return The palette map blue array.
		 */
		 
		public function get blueArray (): Array
		{
			return __blueArray;
		}
		
	}
}