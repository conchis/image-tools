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

package origami.aware
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import origami.geometry.Dimensions;
	import origami.tiled_image.ImageModel;

	/**
	 * An ImageModel subclass that adapts the viewer for the Aware tile server.
	 *
	 * @author Jonathan A. Smith
	 */

	public class AwareImageModel extends ImageModel
	{
		/** Loader used to load image information page. */
		private var loader: URLLoader;

		/**
		 * Contructs an AwareImageModel.
		 */

		public function AwareImageModel()
		{
			super();
			resolution_multiplier = 2.0;
		}

		/**
		 * Loads image information from the specified image url.
		 */

		override protected function load(): void
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onPageLoaded);
			loader.load(new URLRequest(makeInfoURL()));
		}

		/**
		 * Constructs a URL that can be used to obtain information about a specified
		 * Aware server image.
		 *
		 * @return image information page URL
		 */

		private function makeInfoURL(): String
		{
		    var start: Number = image_url.toLowerCase().indexOf("tileserver");
		    var info_url: String = image_url.substring(0, start)
		            + "imageInfo.jsp" + image_url.substring(start + 10);
		    return info_url;
		}

		/**
		 * Function called when data is loaded from the remove server.
		 */

		private function onPageLoaded(event: Event): void
		{
			scanInformationPage(loader.data);
		}

		/**
		 * Obtain image information from the HTML image summary page.
		 *
		 * @param text HTML text of image information summary
		 */

		private function scanInformationPage(text: String): void
		{
		    var width_start: int = text.indexOf("Width = ");
		    if (width_start == -1) return;
		    width_start += 8;
		    var width_end: int = text.indexOf("<", width_start);
		    if (width_end == -1) width_end = text.length - 1;
		    var width: int = parseInt(text.substring(width_start, width_end));
		    trace("width = " + width);

		    var height_start: Number = text.indexOf("Height = ");
		    if (height_start == -1) return;
		    height_start += 9;
		    var height_end: Number = text.indexOf("<", height_start);
		    if (height_end == -1) height_end = text.length - 1;
		    var height: int = parseInt(text.substring(height_start, height_end));
		    trace("height = " + height);

		    image_size = Dimensions.makeWidthHeight(width, height);
			__is_initialized = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Returns a URL used to obtain an image for a specified tile.
		 *
		 * @param column column of tile
		 * @param row row of tile
		 * @param layer where tile resides
		 * @return URL for tile image
		 */

		override public function tileURL(column: int, row: int, layer: int): String
		{
			var tile_url: String =
		    	image_url + "&zoom=" + layer + "&x=" + column + "&y=" + row + "&rotation=0";
		    return tile_url;
		}

		/**
		 * Returns a URL used to get a thumbnail image.
		 *
		 * @return URL for thumbnail
		 */

		override public function get thumbnail_url(): String
		{
		    var start: int = image_url.toLowerCase().indexOf("tileserver?");
		    var thumbnail_url: String = image_url.substring(0, start)
		            + "thumbnailserver?maxthumbnailwidth=150&maxthumbnailheight=800&"
		            + image_url.substring(start + 11);
		    return thumbnail_url;
		}

	}
}