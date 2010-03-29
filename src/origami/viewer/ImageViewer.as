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
	import flash.external.ExternalInterface;

	import mx.events.ResizeEvent;

	import origami.framework.Component;
	import origami.geometry.Angles;
	import origami.geometry.Rectangle;
	import origami.spatial.Viewport;
	import origami.tiled_image.ImageModel;
	import origami.tiled_image.TiledImage;

	/**
	 * A viewer for a single tiled image.
	 *
	 * @author Jonathan A. Smith
	 */

	public class ImageViewer extends Viewer
	{
		/** Base image URL. */
		private var __image_url: String;

		/* Model of tiles image. */
		protected var image_model: ImageModel;

		/** Tiled image in view */
		private var tiled_image: TiledImage;

		/** Naviagtor. */
		private var navigator: Navigator;

		/** Rollover. */
		private var rollover: Rollover;

		/** Initial bounds. */
		private var initial_bounds: Rectangle;

		/** Initial rotation. */
		private var initial_rotation: Number;

		/** True only if monitoring view changes. */
		private var is_monitoring: Boolean = false;

		/**
		 * Create image viewer.
		 */

		public function ImageViewer()
		{
			super();
			addEventListener(Component.PARAMETERS_CHANGED, onParametersChanged);
			addEventListener(ResizeEvent.RESIZE, onResize);
		}

		/**
		 * Called when the component's paramters string is set.
		 */

		private function onParametersChanged(event: Event): void
		{
			if (hasParameter("image"))
			{
				image_url = getStringParameter("image");
				initial_bounds = getRectangleParameter("bounds");
				initial_rotation = getNumberParameter("rotation", 0);
				if (initial_rotation != 0)
					initial_rotation = Angles.toRadians(initial_rotation);
				is_monitoring = getBooleanParameter("monitor");
			}
		}

		/**
		 * Create child views.
		 */

		override protected function createChildren(): void
		{
			// Create viewer childern
			super.createChildren();

			// Add tiled image
			tiled_image = new TiledImage();
			tiled_image.viewport = viewport;
			addChild(tiled_image);

			// Add navigator
			navigator = new Navigator();
			navigator.viewport = viewport;
			navigator.viewer_model = viewer_model;
			addChild(navigator);

			// Add Rollover
			rollover = new Rollover();
			rollover.panel = navigator;
			addChild(rollover);
		}

		/**
		 * Called when view is resized.
		 *
		 * @param event resize event
		 */

		private function onResize(event: ResizeEvent): void
		{
			tiled_image.setActualSize(width, height);
		}

		/**
		 * Repositions view contents.
		 *
		 * @param width unscaled view width
		 * @param height unscaled view height
		 */

		override protected function updateDisplayList(width: Number, height: Number): void
		{
			super.updateDisplayList(width, height);

			// Position navigator
			navigator.x = width - navigator.width - 5;
			navigator.y = height - navigator.height - 5;

			// Position rollover
			rollover.x = width - rollover.width - 32;
			rollover.y = height - rollover.height - 32;
		}

		// **** Loading Image

		/**
		 * Sets the URL of the image to be displayed in the view.
		 *
		 * @param url URL of tiled image folder
		 */

		public function set image_url(image_url: String): void
		{
			__image_url = image_url;
			image_model = makeImageModel();
			image_model.image_url = image_url;
			image_model.addEventListener(Event.COMPLETE, onImageModelComplete);
		}

		/**
		 * Returns the URL of the image to be displayed in the view.
		 *
		 * @return URL of tiled image folder
		 */

		public function get image_url(): String
		{
			return __image_url;
		}

		/**
		 * Method to create the image model and start it's initialization.
		 * Override this to create a different ImageModel object.
		 *
		 * @return new ImageModel or subclass instance
		 */

		protected function makeImageModel(): ImageModel
		{
			return new ImageModel();
		}

		/**
		 * Called when image information is initialized. Installs the image model
		 * in each of the components, then initializes the view bounds and rotation,
		 * and initiates monitoring if approprivate.
		 */

		private function onImageModelComplete(event: Event): void
		{
			tiled_image.image_model = image_model;
			navigator.image_model = image_model;
			rollover.image_model = image_model;

			initializeView();
			initializeMonitor();
		}

		/**
		 * Sets the initial view to the box rectangle specified in the
		 * "bounds" and "rotation" query argments.
		 */

		private function initializeView(): void
		{
			if (initial_rotation != 0)
				viewport.setRotation(initial_rotation);
			if (initial_bounds != null)
				viewport.focusOnBox(initial_bounds);
		}

		/**
		 * Sets up monitoring -- transmitting image size and bounds information
		 * to the web page whenever the view changes.
		 */

		private function initializeMonitor(): void
		{
		    if (!is_monitoring) return;
		    viewport.addEventListener(Viewport.CHANGED, onViewChanged);
		    onViewChanged();
		}

		/**
		 * Method called when the view changes.
		 */

		private function onViewChanged(event: Event = null): void
		{
		trace("view changed..");

		    var image_width: Number  = int(viewport.scene_size.width);
		    var image_height: Number = int(viewport.scene_size.height);

		    var view_rectangle: Rectangle = viewport.view_polygon.bounds;
	        var view_left: Number    = int(view_rectangle.left);
	        var view_top: Number     = int(view_rectangle.top);
	        var view_right: Number   = int(view_rectangle.right);
	        var view_bottom: Number  = int(view_rectangle.bottom);

	        var rotation: Number = Math.round(Angles.toDegrees(viewport.rotation) * 1000.0) / 1000.0;

	        ExternalInterface.call("onViewChanged", image_width, image_height,
	                view_left, view_top, view_right, view_bottom, rotation);
		}

	}
}