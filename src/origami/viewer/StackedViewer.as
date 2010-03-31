/**
 * Copyright 2010 Northwestern University
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
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.containers.Canvas;
	import mx.events.ResizeEvent;
	
	import origami.geometry.Dimensions;
	import origami.spatial.Viewport;
	import origami.tiled_image.ImageModel;
	import origami.tiled_image.TiledImage;
	
	/**	A viewer for multiple stacked tiled images with a detached navigator.
	 * 
	 * 	Events:
	 * 
	 *  Event.COMPLETE: Dispatched after a call to setImageUrls when all
	 * 	of the image models have been loaded, all the tiled images have
	 *  been created, and the thumbnail has been loaded and intialized.
	 * 
	 * 	IOErrorEvent.IO_ERROR: Dispatched if an IO error occurs.
	 * 
	 *  @author	John Norstad
	 */

	public class StackedViewer extends Viewer
	{
		/**	Child components. */
		
		private var tiledImages: Array = new Array();
		
		/**	The navigator component. */
		
		private var navigator: Navigator;
		
		/**	The number of images. */
		
		private var numImages: int;
		
		/**	The number of image models loaded. */
		
		private var numImageModelsLoaded: int;
		
		/**	Image models. */
		
		private var imageModels: Array = new Array();
		
		/**	Creates a new stacked viewer. */
	 
		public function StackedViewer ()
		{
			super();
			addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
		/**	Creates the child components. */
		
		override protected function createChildren (): void
		{
			super.createChildren();
			
			navigator = new Navigator();
			navigator.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			navigator.viewport = viewport;
			navigator.viewer_model = viewer_model;
		}
		
		/**	Gets the navigator.
		 * 
		 *  @return		The navigator.
		 */
		 
		public function getNavigator (): Navigator
		{
			return navigator;
		}
		
		/**	Gets the thumbnail.
		 * 
		 *  @return		The thumbnail.
		 */
		 
		public function getThumbnail (): Thumbnail
		{
			return navigator.getThumbnail();
		}
		
		/**	Handles resize events.
		 * 
		 * 	@param	event	Resize event.
		 */
		 
		private function onResize (event: ResizeEvent): void
		{
			for each (var tiledImage: TiledImage in tiledImages) {
				tiledImage.width = width;
				tiledImage.height = height;
			}
		}
		
		/**	Sets the image urls.
		 * 
		 *  @param	urls		Image urls.
		 */
		 
		public function setImageUrls (urls: Array): void
		{
			numImages = urls.length;
			numImageModelsLoaded = 0;
			tiledImages = new Array();
			imageModels = new Array();
			for each (var url: String in urls) {
				var imageModel: ImageModel = new ImageModel();
				imageModel.addEventListener(Event.COMPLETE, onImageModelComplete);
				imageModel.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				imageModels.push(imageModel);
				imageModel.image_url = url;
			}
		}
		
		/**	Handles image model complete events.
		 * 
		 *  @param	event	Image model complete event.
		 */
		 
		private function onImageModelComplete (event: Event): void
		{
			numImageModelsLoaded++;
			if (numImageModelsLoaded == numImages) createTiledImages();
		}
		
		/**	Handles IO error events.
		 * 
		 *  @param	event		IO error event.
		 */
		 
		protected function onIOError (event: IOErrorEvent): void
		{
			dispatchEvent(event);
		}
		
		/**	Creates the tiled images. */
		
		private function createTiledImages (): void
		{
			while (getChildAt(0) is TiledImage) {
				removeChildAt(0);
			}
			
			for (var i: int = 0; i < numImages; i++) {
				var imageModel: ImageModel = imageModels[i];
				var tiledImage: TiledImage = new TiledImage();
				tiledImage.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				tiledImage.width = width;
				tiledImage.height = height;
				if (i > 0) tiledImage.blendMode = BlendMode.ADD;
				tiledImage.viewport = viewport;
				tiledImage.image_model = imageModel;
				tiledImages.push(tiledImage);
				addChildAt(tiledImage, i);
			}
			
			var thumbnail: Thumbnail = navigator.getThumbnail();
			thumbnail.addEventListener(Event.COMPLETE, onThumbnailInitialized);
			navigator.image_model = imageModels[0];
		}
		
		/**	Handles thumbnail initialized events.
		 * 
		 *  @param	event	Event.
		 */
		 
		private function onThumbnailInitialized (event: Event): void
		{
			var thumbnail: Thumbnail = navigator.getThumbnail();
			thumbnail.removeEventListener(Event.COMPLETE, onThumbnailInitialized);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**	Gets a tiled image.
		 * 
		 *  @param	index		Index.
		 * 
		 *  @return				Tiled image at specified index.
		 */
		 
		public function getTiledImage (index: int): TiledImage
		{
			return tiledImages[index];
		}
	}
}