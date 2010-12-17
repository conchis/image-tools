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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import origami.geometry.Dimensions;

	public class Tile extends Sprite
	{
		/** TiledImage that contains this tile. */
		private var tiled_image: TiledImage;
		
		/** Image loader. */
		private var loader: Loader;
		
		/** Desired size of clip. */
		private var tile_size: Dimensions;
		
		/** Bitmap object with tile data. */
		private var image_bitmap: Bitmap;
		
		/**	Original bitmap data, before any palette maps have been applied. */
		private var original_bitmap_data: BitmapData;
		
		/**	True if palette map is valid. */
		private var paletteValid: Boolean = false;
		
		/**	Clipped dimensions of tile. */
		private var clippedDimensions: Dimensions;
		
		public function Tile(tiled_image: TiledImage)
		{
			super();
			this.tiled_image = tiled_image
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onImageLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		/**
		 * Display a tile at a specified column and row.
		 * 
		 * @param base_url base URL of tiled image
		 * @param layer_number layer number
		 * @param column column number
		 * @param row row number
		 */
		
		internal function display(image_model: ImageModel, layer_number: Number, 
				column: Number, row: Number): void
		{
			if (image_bitmap) return;
			var tile_url: String = image_model.tileURL(column, row, layer_number);
			clippedDimensions = image_model.getClippedDimensions(column, row, layer_number);
			loader.load(new URLRequest(tile_url));
		}
		
		/**
		 * When image is loaded, resets size and adds the bitmap as a child.
		 */
		
		private function onImageLoaded(event: Event): void
		{
			if (image_bitmap)
				this.removeChild(image_bitmap);
			image_bitmap = Bitmap(loader.content);
			clipToScene();
			original_bitmap_data = image_bitmap.bitmapData;
			if (tile_size)
			{
				image_bitmap.width = tile_size.width;
				image_bitmap.height = tile_size.height;
			}
			if (visible && !paletteValid) {
				applyPaletteMap();
			}
			addChild(image_bitmap);
		}
		
		/**	Handles IO error events.
		 * 
		 *  @param	event		IO error event.
		 */
		 
		private function onIOError (event: IOErrorEvent): void
		{
			tiled_image.dispatchEvent(event);
		}
		
		/**
		 * Clips the tile to the scene: pixels outside the scene are made transparent.
		 */
		 
		private function clipToScene (): void
		{
			var data: BitmapData = image_bitmap.bitmapData;
			
			//	Return if the tile doesn't need clipping.
			
			if (clippedDimensions.width >= data.width &&
				clippedDimensions.height >= data.height) return;
				
			//	If the bitmap data doesn't support transparecy, replace it by a 
			//	copy that does support transparency.
				
			if (!data.transparent) {
				var w: int = data.width;
				var h: int = data.height;
				var newData: BitmapData = new BitmapData(w, h, true);
				var sourceRect: Rectangle = new Rectangle(0, 0, w, h);
				var destPoint: Point = new Point(0, 0);
				newData.copyPixels(data, sourceRect, destPoint);
				image_bitmap.bitmapData = data = newData;
			}
			
			//	Make the pixels that are outside the scene transparent.
			
			data.lock();
			if (clippedDimensions.width < data.width) {
				var r: Rectangle = new Rectangle(clippedDimensions.width, 0,
					data.width-clippedDimensions.width, data.height);
				data.fillRect(r, 0);
			}
			if (clippedDimensions.height < data.height) {
				r = new Rectangle(0, clippedDimensions.height,
					clippedDimensions.width, data.height-clippedDimensions.height);
				data.fillRect(r, 0);
			}
			data.unlock();
		}
		
		/** 
		 * Set the size of the tile. Will take effect when loaded if the
		 * image had not finished loading.
		 *
		 * @param tile_size dimensions of tile
		 */
		
		internal function setSize(tile_size: Dimensions): void
		{
			//this.tile_size = tile_size;
			
			// Round up tile width and height to avoid one pixel white line 
			// artifact between tiles.
			var tile_width: Number = Math.ceil(tile_size.width);
			var tile_height: Number = Math.ceil(tile_size.height);
			this.tile_size = Dimensions.makeWidthHeight(tile_width, tile_height);
				
			if (image_bitmap)
			{
				image_bitmap.width = tile_width;
				image_bitmap.height = tile_height;
			}
		}
		
		/**
		 * Removes this tile clip.
		 */
		 
		internal function remove(): void
		{
			this.parent.removeChild(this);
		}
		
		/**
		 * Sets the palette map.
		 */
		 
		public function setPaletteMap (): void
		{
			if (visible) {
				applyPaletteMap();
			} else {
				paletteValid = false;
			}
		}
		
		/**
		 * Makes the tile visible.
		 */
		
		public function makeVisible (): void
		{
			if (!paletteValid) applyPaletteMap();
			visible = true;
		}
		
		/**
		 * Applies the palette map.
		 */
		 
		private function applyPaletteMap (): void
		{
			if (image_bitmap == null) return;
			var redArray: Array = tiled_image.redArray;
			var greenArray: Array = tiled_image.greenArray;
			var blueArray: Array = tiled_image.blueArray;
			var w: int = original_bitmap_data.width;
			var h: int = original_bitmap_data.height;
			var newData: BitmapData = new BitmapData(w, h);
			var sourceRect: Rectangle = new Rectangle(0, 0, w, h);
			var destPoint: Point = new Point(0, 0);
			newData.paletteMap(original_bitmap_data, sourceRect, destPoint, 
				redArray, greenArray, blueArray);
			image_bitmap.bitmapData = newData;
			paletteValid = true;
		}
		
	}
}