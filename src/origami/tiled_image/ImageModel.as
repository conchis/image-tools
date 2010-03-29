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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import origami.geometry.Dimensions;
	import origami.spatial.Pyramid;

	/**
	 * An ImageModel provides information about a tiled image including
	 * the image dimensions, tile size, tile URLs, and pyramid information.
	 *
	 * @author Jonathan A. Smith
	 */

	public class ImageModel extends Pyramid implements IEventDispatcher
	{
		/** URL of image. */
		private var __image_url: String;

	    /** Event dispatcher. */
	    private var dispatcher: EventDispatcher = new EventDispatcher();

		/**
		 * Constructs an ImageModel.
		 */

		public function ImageModel()
		{
			super();
		}

		// **** Accessors

		/**
		 * Sets the image URL. Note that setting the url causes the descriptive
		 * XML file to be loaded and parsed.
		 *
		 * @param url image source url
		 */

		public function set image_url(url: String): void
		{
			if (__image_url == url) return;
			__image_url = url;
			load();
		}

		/**
		 * Returns the image url.
		 *
		 * @return url of tiled image source
		 */

		public function get image_url(): String
		{
			return __image_url;
		}

		/**
		 * Returns true when the model is initialized.
		 *
		 * @return true when the model has been initialized
		 */

		public function get is_initialized(): Boolean
		{
			return __is_initialized;
		}

		// **** Tile URLs

		/**
		 * Returns a URL for a specified tile at a specified later. Override
		 * this method to change the URL scheem for tile reterival.
		 *
		 * @param column column of tile
		 * @param row row of tile
		 * @param layer where tile resides
		 * @return URL for tile image
		 */

		public function tileURL(column: int, row: int, layer: int): String
		{
		    return (__image_url
		    	  + "/layer" + pad(layer, 4)
		          + "/tile"  + pad(row, 4)
		          + "n"      + pad(column, 4)
		          + ".jpg");
		}

		/**
		 * Returns a URL used to get a thumbnail image.
		 *
		 * @return URL for thumbnail
		 */

		public function get thumbnail_url(): String
		{
			return image_url + "/thumbnail.jpg";
		}

		/**
		 * Left pads an integer with zeros.
		 *
		 * @param number number to pad
		 * @param width final width of number
		 */

		private function pad(number: int, width: int): String
		{
		    var number_string: String = "" + number;
		    var padding: String = "00000000000000000000".substring(
		            0, width -  number_string.length);
		    return padding + number_string;
		}

		// **** Image Information Loading

		/**
		 * Loads image information from the specified image url.
		 */

		protected function load(): void
		{
			var loader: URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onInformationLoaded);
			loader.load(new URLRequest(__image_url + "/contents.xml"));
		}

		/**
		 * Called when image information has been loaded.
		 *
		 * @param event event fired when XML is loaded.
		 */

		protected function onInformationLoaded(event: Event): void
		{
			 var xml: XML = new XML(event.target.data);
			 for each (var element: XML in xml.children())
			 {
			 	if(element.@property != "image_size") continue;
			 	var width: int = parseInt(element.@width);
			 	var height: int = parseInt(element.@height);
			 	image_size = Dimensions.makeWidthHeight(width, height);
				__is_initialized = true;
				dispatchEvent(new Event(Event.COMPLETE));
			 }
		}

		// **** Event Dispatch

		/**
		 * Registers an event listener object with an EventDispatcher object so
		 * that the listener receives notification of an event.
		 */

		public function addEventListener(type: String, listener: Function, use_capture: Boolean = false,
				priority: int = 0, use_weak_reference: Boolean = false): void
		{
			dispatcher.addEventListener(type, listener, use_capture, priority,
					use_weak_reference);
		}

		/**
		 * Dispatches an event into the event flow.
		 */

		public function dispatchEvent(event: Event): Boolean
		{
			return dispatcher.dispatchEvent(event);
		}

		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 */

		public function hasEventListener(type: String): Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 */

		public function removeEventListener(type: String, listener: Function,
				use_capture: Boolean = false): void
		{
			dispatcher.removeEventListener(type, listener, use_capture);
		}

		/**
		 * Checks whether an event listener is registered with this
		 * EventDispatcher object or any of its ancestors for the
		 * specified event type.
		 */

		public function willTrigger(type: String): Boolean
		{
			return dispatcher.willTrigger(type);
		}

	}
}