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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	import mx.containers.Canvas;
	import mx.core.UIComponent;

	import origami.tiled_image.ImageModel;

	/**
	 * An icon that displays another component when rolled over.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Rollover extends Canvas
	{

		public const ROLLOVER_WIDTH: int = 64;

		/** Model of tiled image. */
		private var __image_model: ImageModel;

		/** Image loader. */
		private var loader: Loader;

		/** Thumbnail image. */
		private var thumbnail: UIComponent;

		/** Thumbnail bitmap. */
		private var thumbnail_bits: Bitmap

		/** Panel controled by this control. */
		private var __panel: UIComponent;

		/**
		 * Constructs a Navigator.
		 */

		public function Rollover()
		{
			super();

			setStyle("borderStyle", "outset");
			setStyle("borderColor", 0x666666);
			setStyle("borderThickness", 5);
			setStyle("dropShadowEnabled", true);
			setStyle("shadowDirection", "right");
			setStyle("shadowDistance", 2);

			addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
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
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onImageLoaded);

			var thumbnail_url: String = image_model.thumbnail_url;
			loader.load(new URLRequest(thumbnail_url))
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

		// ****

		override protected function createChildren():void
		{
			super.createChildren();

			thumbnail = new UIComponent();
			//thumbnail.x = 0;
			//thumbnail.y = 0;
			//thumbnail.alpha = 0.75;
			addChild(thumbnail);
		}

		/**
		 * Sets the panel whos visibility is controled by this control.
		 */

		public function set panel(panel: UIComponent): void
		{
			__panel = panel;
			panel.visible = false;
		}

		/**
		 * Method called when thumbnail is loaded.
		 *
		 * @param event image loaded event
		 */

		private function onImageLoaded(event: Event): void
		{
			// Add thumbnail graphics
			thumbnail_bits = Bitmap(loader.content);

			// Adjust position and size
			var thumbnail_width: Number = thumbnail_bits.width;
			var thumbnail_height: Number = thumbnail_bits.height;

			// Content width
			thumbnail_bits.width = ROLLOVER_WIDTH;
			thumbnail_bits.height = (thumbnail_height / thumbnail_width) * ROLLOVER_WIDTH;

			thumbnail.addChild(thumbnail_bits);

			setActualSize(ROLLOVER_WIDTH + 4, thumbnail_bits.height + 4);

			// Force parent view to redraw with thumbnail in correct position
			UIComponent(parent).invalidateDisplayList();
		}

		private function onRollOver(event: MouseEvent): void
		{
			if (!__panel || __panel.visible) return;
			__panel.visible = true;
			visible = false;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onRollOut);
		}

		private function onRollOut(event: MouseEvent): void
		{
			if (!__panel) return;
			if (__panel.mouseX < 0 || __panel.mouseX > __panel.width
					|| __panel.mouseY < 0 || __panel.mouseY > __panel.height)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onRollOut);
				__panel.visible = false;
				visible = true;
			}
		}

	}
}