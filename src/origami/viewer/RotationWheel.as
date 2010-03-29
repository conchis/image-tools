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
	import mx.controls.Image;
	import mx.managers.CursorManager;

	import origami.geometry.Angles;
	import origami.spatial.Viewport;

	/**
	 * A control used to rotate the window contents.
	 *
	 * @author Jonathan A. Smith
	 */

	public class RotationWheel extends Canvas
	{
		private const BUTTON_WIDTH:  int = 20;
		private const BUTTON_HEIGHT: int = 20;

		private const BUTTON_LEFT:   int = 54;

		private const WHEEL_CENTER_X: int = 25;
		private const WHEEL_CENTER_Y: int = 25;

		/** Viewport model. */
		private var __viewport: Viewport;

		[Embed(source="../assets/viewer.swf", symbol="viewerArrowPointer")]
		private static var arrowPointer: Class;

		[Embed(source="../assets/viewer.swf", symbol="rotateWheel")]
		private static var rotateWheel: Class;

		[Embed(source="../assets/viewer.swf", symbol="rotateArrow")]
		private static var rotateArrow: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerRotateLeftButton")]
		private static var rotateLeftIcon: Class;

		[Embed(source="../assets/viewer.swf", symbol="viewerRotateRightIcon")]
		private static var rotateRightIcon: Class;

		/** Rotation arrow. */
		private var arrow_image: Image;

		/** Id of current mouse pointer. */
		private var cursor_id: Number;

		/** Rotate left button. */
		private var left_button: Button;

		/** Rotate right button. */
		private var right_button: Button;

		/** Saved rotation (radians). */
		private var radians: Number = 0;

		public function RotationWheel()
		{
			super();
			width = 80;
			height = 65;

			//setStyle("backgroundColor", 0x000000);

			// Change cursor on mouse over
			addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			addEventListener(MouseEvent.MOUSE_OUT, onRollOut);

			// Intercept and cancel mouse clicks
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		/**
		 * Sets and listens to events from the viewport model.
		 *
		 * @param viewport Viewport model
		 */

		public function set viewport(viewport: Viewport): void
		{
			__viewport = viewport;
			viewport.addEventListener(Viewport.CHANGED, onRotationChange);
		}

		/**
		 * Returns the viewport model.
		 *
		 * @return viewport model
		 */

		public function get viewport(): Viewport
		{
			return __viewport;
		}

		/**
		 * Adds controls to this view.
		 */

		override protected function createChildren():void
		{
			super.createChildren();

			var wheel_image: Image = new Image();
			wheel_image.source = rotateWheel;
			wheel_image.x = WHEEL_CENTER_X;
			wheel_image.y = WHEEL_CENTER_Y;
			addChild(wheel_image);

			arrow_image = new Image();
			arrow_image.source = rotateArrow;
			arrow_image.x = WHEEL_CENTER_X;
			arrow_image.y = WHEEL_CENTER_Y;
			addChild(arrow_image);

			right_button = new Button();
			right_button.setStyle("icon", rotateRightIcon);
			right_button.width = BUTTON_WIDTH;
			right_button.height = BUTTON_HEIGHT;
			right_button.x = BUTTON_LEFT;
			right_button.y = 0;
			addChild(right_button);
			right_button.addEventListener(MouseEvent.CLICK, onRotateRight);

			left_button = new Button();
			left_button.setStyle("icon", rotateLeftIcon);
			left_button.width = BUTTON_WIDTH;
			left_button.height = BUTTON_HEIGHT;
			left_button.x = BUTTON_LEFT;
			left_button.y = 25;
			addChild(left_button);
			left_button.addEventListener(MouseEvent.CLICK, onRotateLeft);
		}

		/**
		 * Updates the view in response to a change in rotation.
		 *
		 * @param event change event
		 */

		private function onRotationChange(event: Event = null): void
		{
			if (radians == __viewport.rotation) return;
			radians = __viewport.rotation;
			arrow_image.rotation = Angles.toDegrees(radians);
		}

		// ****  Mouse Tracking

		/**
		 * Starts tracking mouse movements on mouse down.
		 *
		 * @param event mouse event
		 */

		private function onMouseDown(event: MouseEvent): void
		{
			event.stopPropagation();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		/**
		 * Tracks mouse movements. Computes and sets rotation based on the mouse
		 * position relative to the pointer center.
		 *
		 * @param event mouse event
		 */

		private function onMouseMove(event: MouseEvent): void
		{
			const SNAP_DEGREES:   Number = 45;
			const SNAP_THRESHOLD: Number = 10;

			if (!__viewport) return;
			var mouse_x: Number = mouseX - arrow_image.x;
			var mouse_y: Number = mouseY - arrow_image.y;
			var degrees: Number = Angles.toDegrees(Math.atan2(mouse_y, mouse_x)) + 90;
			var snap: Number = SNAP_DEGREES * Math.floor((degrees + SNAP_DEGREES/2) / SNAP_DEGREES);
			if (Math.abs(degrees - snap) <= SNAP_THRESHOLD)
				__viewport.setRotation(Angles.toRadians(snap));
			else
				__viewport.setRotation(Angles.toRadians(degrees));
		}

		/**
		 * On mouse up stops tracking mouse.
		 *
		 * @param event mouse event
		 */

		private function onMouseUp(event: MouseEvent): void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		// **** Rotate Buttons

		/**
		 * Rotate right to next 90 degree stop.
		 */

		private function onRotateRight(event: MouseEvent): void
		{
			var degrees: Number = Math.round(Angles.toDegrees(__viewport.rotation));
			degrees = 90 * Math.round((degrees + 45) / 90);
			__viewport.setRotation(Angles.toRadians(degrees));
		}

		/**
		 * Rotate left to next 90 degree stop.
		 */

		private function onRotateLeft(event: MouseEvent): void
		{
			var degrees: Number = Math.round(Angles.toDegrees(__viewport.rotation));
			degrees = 90 * Math.round((degrees - 46) / 90);
			__viewport.setRotation(Angles.toRadians(degrees));
		}

		// **** Mouse Pointer

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