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

package origami.spatial
{
	import origami.geometry.*;
	
	/**
	 * Coordinate model of a tiled object.
	 * 
	 * @author Jonathan A. Smith
	 * @version 22 April 2008
	 */
	 
	public class Pyramid 
	{
		/** Image size. */
		private var __image_size: Dimensions;
		
		/** Tile dimensions. */
		private var __tile_size: Dimensions = Dimensions.makeWidthHeight(256, 256);
		
		/** Resolution multiplier. */
		private var __resolution_multiplier: Number = Math.SQRT2;

		/** Number of layers. */
		private var __layer_count: Number;
		
		/** True when initialized. */
		protected var __is_initialized: Boolean;
		
		// **** Constructors and Initialization
		
		/**
		 * Constructs a Pyramid.
		 * 
		 * @param image_size dimensions of original image
		 * @param tile_size size of image tiles
		 * @param resolution_multiplier scale difference between layers
		 */
		 
		public function Pyramid(initial_image_size: Dimensions = null, 
				initial_tile_size: Dimensions = null, initial_resolution_multiplier: Number = 0)
		{
			if (initial_image_size)
				image_size = initial_image_size;
			if (initial_tile_size)
				tile_size = initial_tile_size;
			if (initial_resolution_multiplier != 0)
				resolution_multiplier = initial_resolution_multiplier;
		}			
		
		/**
		 * Initializes computed members of the pyramid, including the number of 
		 * layers in the tiled image.
		 */
		
		private function initialize(): void
		{
			// If we do not yet know the image size, return
			if (__image_size == null) return;
				
			// Compute layer count
		 	var log_multiplier: Number = Math.log(__resolution_multiplier);
			var l_width: Number = 
				(Math.log(__image_size.width) - Math.log(__tile_size.width)) 
					/ log_multiplier;
			var l_height: Number = 
				(Math.log(__image_size.height) - Math.log(__tile_size.height)) 
					/ log_multiplier;
			__layer_count = Math.ceil(Math.max(l_width, l_height)) + 1;
			
			// Mark object as initialized
			__is_initialized = true;
		}
		
		// **** Accessors 
		
		/**
		 * Sets the tile size, initializes if ready.
		 * 
		 * @param size dimensions of unscaled tile image
		 */
		
		public function set tile_size(size: Dimensions): void
		{
			__tile_size = size;
			initialize();
		}
		
		/**
		 * Returns the unscaled dimensions of a tile.
		 * 
		 * @return the unscaled dimensions of a tile image
		 */
		 
		public function get tile_size(): Dimensions
		{
			return __tile_size;
		}
		
		/**
		 * Sets the original image size (in pixels).
		 * 
		 * @param image_size size of original image
		 */
		 
		public function set image_size(image_size: Dimensions): void
		{
			__image_size = image_size;
			initialize();
		}
		
		/**
		 * Returns the image size (in pixels).
		 * 
		 * @return size of original image
		 */
		 
		public function get image_size(): Dimensions
		{
			return __image_size;
		}
		
		/**
		 * Sets the resolution multiplier, the relative size of the area covered
		 * by a tile in each layer of the pyramid.
		 * 
		 * @param multiplier
		 */
		
		public function set resolution_multiplier(multiplier: Number): void
		{
			__resolution_multiplier = multiplier;
			initialize();
		}
		
		/**
		 * Returns the resolution multiplier: the relative size of the area covered
		 * by each tile in each successive layer of the pyramid.
		 * 
		 * @return resolution multiplier
		 */
		 
		public function get resolution_multiplier(): Number
		{
			return __resolution_multiplier;
		}
		
		/**
		 * Returns the number of layers in the image pyrimid.
		 */
		 
		public function get layer_count(): int
		{
			if (!__is_initialized)
				throw new Error("Pyramid is not initialized");
			return __layer_count;
		}
		
		// **** Layers
		 
		 /**
		  * Returns a layer number for a specified scale. The layer will be at or
		  * just higher resolution than needed to display the image at the 
		  * specified resolution.
		  * 
		  * @param scale scale of visible image
		  * @return layer index for display at scale
		  */
		  
		 public function layerForScale(scale: Number): Number
		 {
		 	var last_layer: Number = layer_count - 1;
		 	var level: Number = Math.log(scale) / -Math.log(__resolution_multiplier);
		 	level = Math.max(level, 0);
		 	return Math.max(last_layer - Math.floor(level + 0.0000001), 0);
		 }
		 
		 /**
		  * Returns a scale ratio for a specified layer number.
		  * 
		  * @param layer_number layer number
		  * @return scale of image in specified layer
		  */
		 
		 public function scaleForLayer(layer_number: Number): Number
		 {
		 	var layer_index: Number = layer_count - layer_number - 1;
		 	return 1 / Math.pow(__resolution_multiplier, layer_index);
		 }
		 
		// **** Tile Size
	
		/** 
		 * Returns the (width, height) of the image area covered by a tile.
		 * 
		 * @param layer_number layer number
		 * @return Dimensions of area covered by a tile
		 */
		
		public function tileExtent(layer_number: Number): Dimensions
		{
			var layer_index: Number = layer_count - layer_number - 1;
			var tile_width: Number = __tile_size.width;
			var tile_height: Number = __tile_size.height;
			var scale: Number = Math.pow(__resolution_multiplier, layer_index);
			return Dimensions.makeWidthHeight(
				Math.floor(tile_width * scale), Math.floor(tile_height * scale));
		}
	
		/**
		 * Returns the number of tile (columns, rows) in a layer.
		 * 
		 * @param layer_number layer number
		 * @return Dimensions, number of columns and rows in a layer
		 */
	
		public function tileGridSize(layer_number: Number): Dimensions
		{
			var extent: Dimensions = tileExtent(layer_number);
			return Dimensions.makeWidthHeight(
				Math.ceil(__image_size.width  / extent.width),
				Math.ceil(__image_size.height / extent.height) );
		}
		
		/**
		 * Returns the area of the original image covered by a tile.
		 * 
		 * @param column tile column number
		 * @param row tile row number
		 * @param layer_number layer number
		 * @return Rectangle in original image coordinates
		 */
		 
		public function tileSourceRectangle(column: Number, row: Number, 
				layer_number: Number): Rectangle
		{
			var layer_index: Number = layer_count - layer_number - 1;
			var scale: Number = Math.pow(__resolution_multiplier, layer_index);
			var extent_width: Number = Math.floor(__tile_size.width * scale);
			var extent_height: Number = Math.floor(__tile_size.height * scale);
			return Rectangle.makeLeftTopWidthHeight(
				extent_width * column, extent_height * row, 
				extent_width, extent_height);
		}
		
		/**
		 * Returns the clipped dimensions of a tile (clipped to the image),
		 * in the tile coordinate system.
		 * 
		 * @param column tile column number
		 * @param row tile row number
		 * @param layer_number layer number
		 * @return Clipped dimensions of the tile.
		 */
		
		public function getClippedDimensions (column: Number, row: Number,
			layer_number: Number): Dimensions
		{
			var layer_index: Number = layer_count - layer_number - 1;
			var scale: Number = Math.pow(__resolution_multiplier, layer_index);
			var tileRect: Rectangle = tileSourceRectangle(column, row, layer_number);
			var sceneRect: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0,
				image_size.width, image_size.height);
			var clippedTile: Rectangle = tileRect.intersect(sceneRect);
			var clippedWidth: int = Math.ceil(clippedTile.width/scale);
			var clippedHeight: int = Math.ceil(clippedTile.height/scale);
			return Dimensions.makeWidthHeight(clippedWidth, clippedHeight);
		}
				
		// **** Tile Indexing
		 
		 /**
		  * Converts an x-coordinate and layer number to a tile column number.
		  *
		  * @param x x-coordinate
		  * @param layer_number layer number
		  * @return tile column number
		  */
		  
		 public function tileColumn(x: Number, layer_number: Number): Number
		 {
		 	var layer_index: Number = layer_count - layer_number - 1;
		 	var extent: Number = __tile_size.width 
		 			* Math.pow(__resolution_multiplier, layer_index);
		 	return Math.floor(x / extent);
		 }
		 
		 /** 
		  * Converts a y-coordinate and layer number to a tile row number.
		  *
		  * @param y y-coordinate
		  * @param layer_number layer number
		  * @return tile row number
		  */ 
		  
		 public function tileRow(y: Number, layer_number: Number): Number
		 {
		 	var layer_index: Number = layer_count - layer_number - 1;
		 	var extent: Number = __tile_size.height 
		 			* Math.pow(__resolution_multiplier, layer_index);
		 	return Math.floor(y / extent);
		 }
		 
		 // **** Iteration
		 
		 /**
		  * Executes a closure for all tiles under a specified rectangle 
		  * at a specified layer.
		  * 
		  * @param rectangle rectangle to be covered
		  * @param layer_number layer number
		  * @param closure closure to be executed for each tile position
		  */
		  
		public function forTiles(rectangle: Rectangle, layer_number: Number, 
				closure: Function): void
		{
			var grid_size: Dimensions = tileGridSize(layer_number);
					
			var left: Number = tileColumn(rectangle.left, layer_number);
			left = Math.max(0, Math.min(left, grid_size.width - 1));
			
			var right: Number = tileColumn(rectangle.right, layer_number);
			right = Math.max(0, Math.min(right, grid_size.width - 1));
			
			var top: Number = tileRow(rectangle.top, layer_number);
			top = Math.max(0, Math.min(top, grid_size.height - 1));
			
			var bottom: Number = tileRow(rectangle.bottom, layer_number);
			bottom = Math.max(0, Math.min(bottom, grid_size.height - 1));
					
			for (var row: Number = top; row <= bottom; row += 1)
			{
				for (var column: Number = left; column <= right; column += 1)
					closure(column, row, layer_number, this);
			}
		}
		
	}

}