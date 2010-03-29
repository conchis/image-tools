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
	import flash.events.MouseEvent;

	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.VSlider;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;

	import origami.spatial.Viewport;
	import origami.tiled_image.ImageModel;

	public class Navigator extends Canvas
	{
		public const BUTTON_WIDTH:  int = 20;
		public const BUTTON_HEIGHT: int = 20;

		/** Model of tiled image. */
		private var __image_model: ImageModel;

		/** Viewport model for viewer. */
		private var __viewport: Viewport;

		/** Model for viewer. */
		private var __viewer_model: ViewerModel;

		/** Thumbnail control. */
		private var thumbnail: Thumbnail;

		/** Zoom In button. */
		private var zoom_in_button: Button;

		/** Zoom Out button. */
		private var zoom_out_button: Button;

		/** Zoom slider. */
		private var zoom_slider: VSlider;

		/** Reset button. */
		private var reset_button: Button;

		/** Zoom mode button. */
		private var zoom_mode_button: Button;

		/** Pan mode button. */
		private var pan_mode_button: Button;

		/** Rotation wheel. */
		private var rotation_wheel: RotationWheel;

		/** True when initialized. */
		private var is_initialized: Boolean = false;

		[Embed(source="../assets/viewer.swf", symbol="viewerArrowPointer")]
		private static var arrowPointer: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerResetButtonIcon")]
		private static var resetIcon: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerInButtonIcon")]
		private static var zoomInIcon: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerOutButtonIcon")]
		private static var zoomOutIcon: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerZoomIcon")]
		private static var zoomIcon: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerPanIcon")]
		private static var panIcon: Class;

		/** Id of current mouse pointer. */
		private var cursor_id: Number;

		/**
		 * Constructs a Navigator.
		 */

		public function Navigator()
		{
			super();
			width = Thumbnail.THUMBNAIL_WIDTH + 38;
			height = 255;
			setStyle("backgroundColor", 0x666666);
			setStyle("backgroundAlpha", .5);

			// Change cursor on mouse over
			addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			addEventListener(MouseEvent.MOUSE_OUT, onRollOut);

			// Intercept and cancel mouse clicks
			addEventListener(MouseEvent.MOUSE_DOWN,
					function (event: Event): void
					{
						event.stopPropagation();
					});
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

		/**
		 * Creates child views.
		 */

		override protected function createChildren():void
		{
			super.createChildren();

			var top: int = 0;

			// Add Rotation Wheel
			rotation_wheel = new RotationWheel();
			rotation_wheel.viewport = viewport;
			rotation_wheel.x = 108;
			rotation_wheel.y =  5;
			addChild(rotation_wheel);

			// Add zoom mode button
			zoom_mode_button = new Button();
			zoom_mode_button.toggle = true;
			zoom_mode_button.setStyle("icon", zoomIcon);
			zoom_mode_button.width = 45;
			zoom_mode_button.height = 20;
			zoom_mode_button.x =  5;
			zoom_mode_button.y =  5;
			addChild(zoom_mode_button);
			zoom_mode_button.addEventListener(MouseEvent.CLICK, onZoomMode);

			// Add pan mode button
			pan_mode_button = new Button();
			pan_mode_button.toggle = true;
			pan_mode_button.setStyle("icon", panIcon);
			pan_mode_button.width = 45;
			pan_mode_button.height = 20;
			pan_mode_button.x =  5;
			pan_mode_button.y = 30;
			addChild(pan_mode_button);
			pan_mode_button.addEventListener(MouseEvent.CLICK, onPanMode);

			// Add zoom in button
			zoom_in_button = new Button();
			zoom_in_button.setStyle("icon", zoomInIcon);
			zoom_in_button.x = Thumbnail.THUMBNAIL_WIDTH + 13;
			zoom_in_button.y = 60;
			zoom_in_button.width = BUTTON_WIDTH;
			zoom_in_button.height = BUTTON_HEIGHT;
			zoom_in_button.useHandCursor = true;
			addChild(zoom_in_button);
			zoom_in_button.addEventListener(MouseEvent.CLICK, onZoomIn);

			// Add zoom out button
			zoom_out_button = new Button();
			zoom_out_button.setStyle("icon", zoomOutIcon);
			zoom_out_button.x = Thumbnail.THUMBNAIL_WIDTH + 13;
			zoom_out_button.y = 85;
			zoom_out_button.width = BUTTON_WIDTH;
			zoom_out_button.height = BUTTON_HEIGHT;
			zoom_out_button.useHandCursor = true;
			addChild(zoom_out_button);
			zoom_out_button.addEventListener(MouseEvent.CLICK, onZoomOut);

			// Add the thumbnail
			thumbnail = new Thumbnail();
			thumbnail.x = 8;
			thumbnail.y = 60;
			addChild(thumbnail);

			// Add zoom slider
			zoom_slider = new VSlider();
			zoom_slider.x = 10 + Thumbnail.THUMBNAIL_WIDTH;
			zoom_slider.y = 105;
			zoom_slider.height = 110;
			zoom_slider.minimum = 1;
			zoom_slider.maximum = 100;
			zoom_slider.liveDragging = true;
			addChild(zoom_slider);
			zoom_slider.addEventListener(Event.CHANGE, onZoomChange);

			// Add reset button
			reset_button = new Button();
			reset_button.setStyle("icon", resetIcon);
			reset_button.x = Thumbnail.THUMBNAIL_WIDTH + 13;
			reset_button.y = zoom_slider.y + zoom_slider.height + 5;
			reset_button.width = BUTTON_WIDTH;
			reset_button.height = BUTTON_HEIGHT;
			addChild(reset_button);
			reset_button.addEventListener(MouseEvent.CLICK, onZoomReset);
		}

		private function initializeView(): void
		{
			if (__image_model == null || __viewport == null
				|| thumbnail == null) return;
			thumbnail.viewport = __viewport;
			thumbnail.thumbnail_url = __image_model.thumbnail_url;
			is_initialized = true;
		}

		// **** Refresh Views

		override protected function updateDisplayList(width: Number, height: Number):void
		{
			super.updateDisplayList(width, height);

			this.onModeChange();
			this.onScaleChange();

			var new_height: int = thumbnail.height + thumbnail.y + 10;
			if (new_height > height)
			{
				setActualSize(width, new_height);
				this.height = new_height;
				UIComponent(parent).invalidateDisplayList();
			}
		}

		// **** Viewer Model

		/**
		 * Sets the model of the viewer for mode changes.
		 *
		 * @param viewer_model Model of viewer
		 */

		internal function set viewer_model(viewer_model: ViewerModel): void
		{
			__viewer_model = viewer_model;
			viewer_model.addEventListener(Event.CHANGE, onModeChange);
			this.invalidateDisplayList();
		}

		// **** Viewport

		/**
		 * Sets the viewport changed by this control.
		 *
		 * @param viewport Viewport changed by the control
		 */

		public function set viewport(viewport: Viewport): void
		{
			__viewport = viewport;
			viewport.addEventListener(Viewport.CHANGED, onScaleChange);
			viewport.addEventListener(Viewport.UPDATE, onScaleChange);
			initializeView();
		}

		/**
		 * Returns the viewport changed by this control.
		 *
		 * @return Viewport
		 */

		public function get viewport(): Viewport
		{
			return __viewport;
		}

		// **** Zooming

		/**
		 * Zooms all the way out.
		 *
		 * @param event mouse event
		 */

		private function onZoomReset(event: MouseEvent): void
		{
			if (!is_initialized) return;
			__viewport.zoomReset();
		}

		/**
		 * Zooms in one step.
		 *
		 * @param event Mouse event
		 */

		private function onZoomIn(event: MouseEvent): void
		{
			if (!is_initialized) return;
			__viewport.zoomIn();
		}

		/**
		 * Zooms out one step.
		 *
		 * @param event Mouse event
		 */

		private function onZoomOut(event: MouseEvent): void
		{
			if (!is_initialized) return;
			__viewport.zoomOut();
		}

		/**
		 * Reponds to change in zoom slider setting.
		 *
		 * @param event zoom slider event
		 */

		private function onZoomChange(event: Event): void
		{
			if (!is_initialized) return;
			var scale: Number = zoom_slider.value / 100.0;
			if (scale != __viewport.scale)
				__viewport.setScale(scale);
		}

		/**
		 * Responds to changes in the viewport controled by this view.
		 *
		 * @param event change event
		 */

		private function onScaleChange(event: Event = null): void
		{
			if (!is_initialized) return;
			zoom_slider.minimum = __viewport.minimum_scale * 100;
			zoom_slider.value = Math.round(1 + __viewport.scale * 100);
		}

		// **** Mode Changes

		/**
		 * Called when the mode changes.
		 *
		 * @param event Change event
		 */

		private function onModeChange(event: Event = null): void
		{
			if (!is_initialized) return;
			switch (__viewer_model.mode)
			{
				case ViewerModel.ZOOM_IN_MODE:
				case ViewerModel.ZOOM_OUT_MODE:
					pan_mode_button.selected = false;
					zoom_mode_button.selected = true;
					break;
				case ViewerModel.PAN_MODE:
					pan_mode_button.selected = true;
					zoom_mode_button.selected = false;
					break;
			}
		}

		/**
		 * Changes to zoom mode.
		 *
		 * @param event button event
		 */

		private function onZoomMode(event: Event): void
		{
			if (__viewer_model.mode == ViewerModel.PAN_MODE)
				__viewer_model.mode = ViewerModel.ZOOM_IN_MODE;
		}

		/**
		 * Changes to pan mode.
		 *
		 * @param event button event
		 */

		private function onPanMode(event: Event): void
		{
			if (__viewer_model.mode == ViewerModel.ZOOM_IN_MODE
					|| __viewer_model.mode == ViewerModel.ZOOM_IN_MODE)
				__viewer_model.mode = ViewerModel.PAN_MODE;
		}

		// **** Mouse Tracking

		/**
		 * Installs mouse pointer for this view.
		 *
		 * @param event mouse event
		 */

		private function onRollOver(event: Event): void
		{
			cursor_id = CursorManager.setCursor(arrowPointer, 1);
		}

		/**
		 * Removes the mouse pointer for this view.
		 *
		 * @param event mouse event
		 */

		private function onRollOut(event: Event): void
		{
			CursorManager.removeCursor(cursor_id);
		}

	}
}