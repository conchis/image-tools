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

package origami.spatial
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import origami.geometry.Dimensions;
	import origami.geometry.Point;
	import origami.geometry.Polygon;
	import origami.geometry.Rectangle;
	import origami.geometry.Transform;

	/**
	 * A Viewport represents a viewer's presentation of a visual scene.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Viewport implements IEventDispatcher
	{
	    public static const ZOOM_STEP: Number = Math.SQRT2;

	    /** Event triggered when animating view changes. */
	    public static const UPDATE: String = "origami.spatial.Viewport.UPDATE";

	    /** Event triggered when view has changed. */
	    public static const CHANGED: String = "origami.spatial.Viewport.CHANGED";

		/** Scale of view. */
		public var scale: Number;

		/** Minimum scale. */
		public var minimum_scale: Number;

		/** Rotation (radians). */
		public var rotation: Number = 0;

		/** Size of scene. */
		public var scene_size: Dimensions;

		/** Scene size before reset. */
		public var initial_scene_size: Dimensions;

		/** Size of view in view coordinates. */
		public var view_size: Dimensions;

		/** Center of view in scene coordinates. */
		public var scroll_center: Point;

		/** Limits of area for scroll center. */
		public var scroll_limits: Rectangle;

		/** Transform for moving from scene to view coordinates including rotation. */
		public var view_transform2: Transform;

		/** Transform for moving from view to scene coordinates including rotation. */
		public var scene_transform2: Transform;

		/** Visible area as scene coordinates polygon. */
		public var view_polygon: Polygon;

		/** Origin of visible area in schene coordinates. */
		public var clipped_view_polygon: Polygon;

		/** Center point at start of pan. */
		public var pan_scroll_center: Point;

		/** Starting point for pan in view coordinates. */
		private var pan_start: Point;

		/** Object used to animate zooming. */
		private var zoom_animator: ZoomAnimator;

		/** Set to true when updates should not load tiles. */
		public var rapid_mode: Boolean;

		/** Set to true if the scale changed during rapid mode. */
		public var scale_changed: Boolean;

		/** True only when initialized. */
		private var is_initialized: Boolean;

	    /** Event dispatcher. */
	    private var dispatcher: EventDispatcher = new EventDispatcher();

		/**
		 * Constructs a Viewport
		 */

		public function Viewport()
		{
			super();
			is_initialized = false;
			rapid_mode = false;
			zoom_animator = new ZoomAnimator();
			zoom_animator.setViewport(this);
		}

		// **** Accessors

		// ****

		/**
		 * Sets the scene size to establish global coordinate system.
		 *
		 * @param scene_size scene size in global coordinate units
		 */

		public function setSceneSize(scene_size: Dimensions): void
		{
			this.scene_size = scene_size;
			this.initial_scene_size = scene_size;
			update();
			if (is_initialized)
				this.dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Sets the view size.
		 *
		 * @param view_size view size in global coordinate units.
		 */

		public function setViewSize(view_size: Dimensions): void
		{
			this.view_size = view_size;
			if (!is_initialized) return;

			var was_zoomed_out: Boolean = (scale == minimum_scale);

			// Reset scale on resize
			var horizontal_scale: Number = view_size.width / initial_scene_size.width;
			var vertial_scale: Number = view_size.height / initial_scene_size.height;

			if (was_zoomed_out || scale < minimum_scale)
				scale = minimum_scale;

			update();
			dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Sets the view scale.
		 *
		 * @param scale as a fraction, for example 0.5 is half size
		 */

		public function setScale(scale: Number): void
		{
			scale = Math.min(1.0, Math.max(scale, minimum_scale));
			if (scale === this.scale) return;
			this.scale = scale;
			update();
			scale_changed = rapid_mode;
			if (rapid_mode)
			    dispatchEvent(new Event(UPDATE));
			else
				dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Sets the view rotation.
		 *
		 * @param angle rotation angle
		 */

		public function setRotation(rotation: Number): void
		{
			if (rotation < 0)
				rotation = 2 * Math.PI + rotation;
			if (rotation == this.rotation) return;
			this.rotation = rotation;
			update();
			if (is_initialized)
				dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Initializes the scale to show entire scene in view.
		 */

		private function initializeCoordinates(): void
		{
			is_initialized = true;

			// Compute scale that fits entire scene
			var horizontal_scale: Number = view_size.width / scene_size.width;
			var vertial_scale: Number = view_size.height / scene_size.height;
			minimum_scale = Math.min(horizontal_scale, vertial_scale);
			scale = minimum_scale;

			// Extend scene to include non-filled area of view
			scene_size = view_size.scale(1/ scale);

			// Set the scroll center to center of scene
			scroll_center = Point.makeXY(scene_size.width / 2, scene_size.height / 2);
		}

		/**
		 * Updates transforms for scene to view and back.
		 */

		private function update(): void
		{
			if (view_size == null || scene_size == null) return;
			if (!is_initialized) initializeCoordinates();

			var view_extent: Dimensions = view_size.scale(1 / scale);
			var half_extent: Dimensions = view_extent.scale(1 / 2);

			scroll_limits = scene_size.rectangle.inset(half_extent.width, half_extent.height);

			view_polygon =
				Rectangle.makeLeftTopWidthHeight(scroll_center.x - half_extent.width,
					scroll_center.y - half_extent.height, view_extent.width, view_extent.height).polygon;

			view_transform2 =
			    Transform.makeTranslate(view_size.width/2, view_size.height/2)
				.compose(Transform.makeScale(scale, scale))
				.compose(Transform.makeRotate(rotation))
				.compose(Transform.makeTranslate(-scroll_center.x, -scroll_center.y));

			scene_transform2 = view_transform2.inverse();

			view_polygon = view_size.polygon.project(scene_transform2);
			clipped_view_polygon = view_polygon.clip(initial_scene_size.rectangle);
		}

		/**
		 * Sets the scale and scroll center point without broadcasting.
		 *
		 * @param scale new scale for view
		 * @param scroll_center new scroll center for view
		 */

		public function updateView(scale: Number, scroll_center: Point): void
		{
			this.scale = scale;
			this.scroll_center = scroll_center;
			update();
		}

		// **** Focus on box

		/**
		 * Sets the view to focus on a specified rectangle in scene coordinates.
		 *
		 * @param view_box scene rectangle to focus and zoom view
		 */

		public function focusOnBox(view_box: Rectangle): void
		{
			scroll_center = view_box.center;
			scale = Math.min(view_size.width  / view_box.width,
							view_size.height / view_box.height);
			scale = snapToLayer(scale);
			update();
			dispatchEvent(new Event(CHANGED));
		}

		// **** Zoom

		/**
		 * Optional method to set rapid mode so as to not load additional tiles
		 * during a zoom operation.
		 */

		public function startZoom(): void
		{
		    scale_changed = false;
		    rapid_mode = true;
		}

		/**
		 * Optional method to reset rapid mode and call onChanged at the end of a
		 * zoom operation.
		 */

		public function endZoom(): void
		{
		    rapid_mode = false;
		    if (scale_changed)
		    	dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Zoom all the way out to see the entire scene.
		 */

		public function zoomReset(): void
		{
			zoom_animator.zoomTo(minimum_scale, scroll_center);
		}

		/**
		 * Snaps the scale to a power of (1/sqrt(2)) so as to minimize errors
		 * in tiled images.
		 *
		 * @param scale raw scale
		 * @return adjusted scale
		 */

		private function snapToLayer(scale: Number): Number
		{
		 	var level: Number = Math.ceil(Math.log(scale) / Math.log(ZOOM_STEP));
		 	var raw_scale: Number = Math.pow(ZOOM_STEP, level);
		 	return Math.max(minimum_scale, Math.min(raw_scale, 1.0));
		}

		/**
		 * Returns true only if user can zoom in.
		 *
		 * @return True only if user can zoom in
		 */

		public function canZoomIn(): Boolean
		{
			return scale < 1.0;
		}

		/**
		 * Zooms in one step.
		 */

		public function zoomIn(): void
		{
			var goal_scale: Number = snapToLayer(scale * ZOOM_STEP);
			zoom_animator.zoomTo(goal_scale, scroll_center);
		}

		/**
		 * Returns true if user can zoom out.
		 *
		 * @return True only if user can zoom out
		 */

		public function canZoomOut(): Boolean
		{
			return scale > minimum_scale;
		}

		/**
		 * Zooms out one step.
		 */

		public function zoomOut(): void
		{
			var goal_scale: Number = snapToLayer(scale / ZOOM_STEP);
			zoom_animator.zoomTo(goal_scale, scroll_center);
		}

		// **** Zoom To Point

		/**
		 * Zooms in, centering a specified point.
		 *
		 * @param new_center center point in view coordinates
		 */

		public function zoomInOn(new_center: Point): void
		{
			var goal_scale: Number = snapToLayer(scale * ZOOM_STEP);
			var goal_scroll: Point = scene_transform2.project(new_center);
			zoom_animator.zoomTo(goal_scale, goal_scroll);
		}

		/**
		 * Zooms out, centering a specified point.
		 *
		 * @param new_center center point in view coordinates
		 */

		public function zoomOutOn(new_center: Point): void
		{
			var goal_scale: Number = snapToLayer(scale / ZOOM_STEP);
			var goal_scroll: Point = scene_transform2.project(new_center);
			zoom_animator.zoomTo(goal_scale, goal_scroll);
		}

		// **** Zoom To Box

		/**
		 * Zooms in to make a specified box visible.
		 *
		 * @param view_box area that should be visible after zoom
		 */

		public function zoomInBox(view_box: Rectangle): void
		{
			var goal_scroll: Point =
					scene_transform2.project(view_box.center);

			var goal_scale: Number;
			if (view_box.width > 2 && view_box.height > 2)
				goal_scale = boxScale(view_box);
			else
				goal_scale = snapToLayer(scale * ZOOM_STEP);

			zoom_animator.zoomTo(goal_scale, goal_scroll);
		}

		/**
		 * Zooms out to make a specified box smaller.
		 *
		 * @param view_box view area
		 */

		public function zoomOutBox(view_box: Rectangle): void
		{
			var goal_scroll: Point =
					scene_transform2.project(view_box.center);

			var goal_scale: Number;
			goal_scale = snapToLayer(scale / ZOOM_STEP);

			zoom_animator.zoomTo(goal_scale, goal_scroll);
		}

		/**
		 * Compute a scale that will show a specified rectangle almost filling
		 * the view.
		 *
		 * @param box rectangle in scene coordinates
		 */

		public function boxScale(box: Rectangle): Number
		{
			var horizontal_scale: Number = view_size.width  * scale / box.width;
			var vertial_scale: Number    = view_size.height * scale / box.height;
			var scale: Number = Math.min(horizontal_scale, vertial_scale);
			return snapToLayer(scale);
		}

		// **** Pan

		/**
		 * Begins to pan scene.
		 *
		 * @param pan_start starting point in view coordinates
		 */

		public function startPan(pan_start: Point): void
		{
			this.pan_start = pan_start;
			pan_scroll_center = scroll_center;
		}

		/**
		 * Returns true if panning.
		 *
		 * @return true if panning
		 */

		public function get is_panning(): Boolean
		{
			return pan_start != null;
		}

		/**
		 * Called while panning and tracking mouse movements.
		 *
		 * @param view_point point where mouse is in view coordinates
		 */

		public function pan(view_point: Point): void
		{
			if (pan_scroll_center == null) return;
			var scene_start: Point = pan_start.project(scene_transform2);
			var scene_point: Point = view_point.project(scene_transform2);
			var scene_offset: Dimensions = scene_start.subtractPoint(scene_point);
			scroll_center = pan_scroll_center.addDimensions(scene_offset);
			scroll_center = scroll_center.pinInRectangle(scroll_limits);
			update();
			dispatchEvent(new Event(CHANGED));
		}

		/**
		 * Finish panning.
		 */

		public function finishPan(): void
		{
			pan_scroll_center = null;
			pan_start = null;
			dispatchEvent(new Event(UPDATE));
		}

		/**
		 * Cancels pan and snap back to starting point.
		 */

		public function cancelPan(): void
		{
			scroll_center = pan_scroll_center;
			pan_scroll_center = null;
			update();
			dispatchEvent(new Event(CHANGED));
		}

		// **** Animation

		/**
		 * Step any animation in progress.
		 *
		 * @return true if animation is in progress, false otherwise.
		 */

		public function stepAnimation(): Boolean
		{
			return zoom_animator.stepAnimation();
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