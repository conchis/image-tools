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
	import flash.display.Sprite;
	
	import origami.geometry.Dimensions;
	import origami.geometry.Point;
	import origami.geometry.Rectangle;
	import origami.spatial.Pyramid;
	import origami.spatial.Viewport;

	public class TiledImageLayer extends Sprite
	{
		/** TiledImage that contains this layer. */
		private var tiled_image: TiledImage;
		
		/** Image model. */
		private var image_model: ImageModel;
		
		/** Layer number for this layer. */
		private var layer_number: Number;
		
		/** Scale for this layer. */
		private var scale: Number;
		
		/** Size of grid at current scale. */
		private var grid_size: Dimensions;
		
		/** Tiles on layer indexed by row * grid_size.width + column. */
		private var tiles: Array;
		
		/** Last visible rectangle used to display tiles. */
		private var visible_rectangle: Rectangle;
		
		/**
		 * Constructs a TiledImageLayer.
		 */
		 
		public function TiledImageLayer()
		{
			super();
		}
		
		/**
		 * Sets the tiled image that contains this layer and the layer number.
		 *
		 * @param tiled_image TiledImage that includes this layer
		 * @param layer_number number of layer in image
		 */
		
		public function setImage(tiled_image: TiledImage, layer_number: int): void
		{
			this.tiled_image  = tiled_image;
			this.layer_number = layer_number;
			
			this.image_model = tiled_image.image_model;
			this.scale        = image_model.scaleForLayer(layer_number);
	    	this.grid_size    = image_model.tileGridSize(layer_number);
	    	this.tiles        = new Array(grid_size.width * grid_size.height);
		}
		
		/**
		 * Requests that the layer load images for all tiles within the current goal
		 * rectangle.
		 * 
		 * @param viewport Viewport describing the visible area of the image
		 */
		
		public function load(viewport: Viewport): void
		{
			var goal_rectangle: Rectangle = viewport.view_polygon.bounds;
			var me: TiledImageLayer = this;
			image_model.forTiles(goal_rectangle, layer_number,
				function (column: Number, row: Number, layer_number: Number, pyramid: Pyramid): void
				{
					me.createTile(column, row);
				});
		}
		
		/**
		 * Creates a tile at a specified row and column.
		 *
		 * @param column column number for new tile
		 * @param row row number for new tile
		 */
		
		private function createTile(column: Number, row: Number): void
		{
			var index: Number = row * grid_size.width + column;
			if (tiles[index] != null) return;
			
			var tile_clip: Tile = new Tile(tiled_image);
			addChild(tile_clip);
			tile_clip.visible = false;
			tile_clip.display(image_model, layer_number, column, row);
			tiles[index] = tile_clip;
		}
		
		/**
		 * Requests that the layer display tiles visible within the visible area
		 * in a viewport.
		 * 
		 * @param viewport Viewport describing the visible area of the image
		 */
		
		public function display(viewport: Viewport): void
		{
			visible = true;
			var view_rectangle: Rectangle = viewport.view_polygon.bounds;
			var desired_scale: Number = viewport.scale;
			
			// Hide currently visible tiles
			hide();
			
			// Save view rectangle for update
			visible_rectangle = Rectangle.makeRectangle(view_rectangle);
			
			// Top left tile position column, row
			var origin: Point = computeOrigin();
			var scaled_tile_size: Dimensions = 
				image_model.tile_size.scale(desired_scale / scale);
				
			var offset: Point = computeOffset(origin, scaled_tile_size, desired_scale);
				
			var me: TiledImageLayer = this;
			image_model.forTiles(view_rectangle, layer_number,
				function (column: Number, row: Number, layer_number: Number, pyramid: Pyramid): void
				{
					me.displayTile(column, row, origin, scaled_tile_size, offset);
				});
		}
		
		/**
		 * Hide all visible tiles within the last displayed visible rectangle.
		 */
		
		private function hide(): void
		{
			if (visible_rectangle == null) 
				return;
				
			var grid_size: Dimensions = this.grid_size;
			var tiles: Array = this.tiles;
			image_model.forTiles(visible_rectangle, layer_number,
				function (column: Number, row: Number, layer_number: Number, pyramid: Pyramid): void
				{
					var index: Number = row * grid_size.width + column;
					if (tiles[index] != null)
						tiles[index].visible = false;
				});
				
			visible_rectangle = null;
		}
		
		/**
		 * Compute (column, row) of top left tile area that will be displayed.
		 */
		
		private function computeOrigin(): Point
		{
			var left: Number = image_model.tileColumn(visible_rectangle.left, layer_number);
			left = Math.max(0, Math.min(left, grid_size.width - 1));
			var top:  Number = image_model.tileRow(visible_rectangle.top, layer_number);
			top = Math.max(0, Math.min(top, grid_size.height - 1));
			return Point.makeXY(left, top);
		}
		
		/**
		 * Compute the pixel offset of tile corners relative to the origin of
		 * the view.
		 */
		
		private function computeOffset(origin: Point, 
				scaled_tile_size: Dimensions, desired_scale: Number): Point
		{
			var left: Number = (origin.x * scaled_tile_size.width)  
					- visible_rectangle.left * desired_scale;
			var top: Number  = (origin.y * scaled_tile_size.height) 
					- visible_rectangle.top  * desired_scale;
			return Point.makeXY(left, top);
		}
	
		/**
		 * Position and size a tile for display.
		 *
		 * @param column tile column number
		 * @param row tile row number
		 * @param origin upper left tile row and column in the current view
		 * @param scaled_tile_size size of tile at current zoom scale
		 * @param offset position offset in view pixels of upper left corner
		 */
		
		public function displayTile(column: Number, row: Number,
			origin: Point, scaled_tile_size: Dimensions, offset: Point): void
		{
			// If no tile at location, return
			var index: Number = row * grid_size.width + column;
			var tile: Tile = tiles[index];
			if (tile == null) return;
			
			// Position tile
			tile.setSize(scaled_tile_size);
			tile.x = (column - origin.x) * scaled_tile_size.width  + offset.x;
			tile.y = (row    - origin.y) * scaled_tile_size.height + offset.y;
	
			// Make tile visible
			tile.makeVisible();
			
		}
		
		/**
		 * Sets the palette map.
		 */
		 
		public function setPaletteMap (): void
		{
			for (var i: int = 0; i < tiles.length; i++)
			{
				var tile: Tile = tiles[i];
				if (tile == null) continue;
				tile.setPaletteMap();
			}
		}
		
	}
}