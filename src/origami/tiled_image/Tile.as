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
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	import origami.geometry.Dimensions;

	public class Tile extends Sprite
	{
		/** Image loader. */
		private var loader: Loader;

		/** Desired size of clip. */
		private var tile_size: Dimensions;

		/** Bitmap object with tile data. */
		private var image_bitmap: Bitmap;

		public function Tile()
		{
			super();
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onImageLoaded);
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
			if (tile_size)
			{
				image_bitmap.width = tile_size.width;
				image_bitmap.height = tile_size.height;
			}
			addChild(image_bitmap);
		}

		/**
		 * Set the size of the tile. Will take effect when loaded if the
		 * image had not finished loading.
		 *
		 * @param tile_size dimensions of tile
		 */

		internal function setSize(tile_size: Dimensions): void
		{
			this.tile_size = tile_size;
			if (image_bitmap)
			{
				image_bitmap.width = tile_size.width;
				image_bitmap.height = tile_size.height;
			}
		}

		/**
		 * Removes this tile clip.
		 */

		internal function remove(): void
		{
			this.parent.removeChild(this);
		}

	}
}