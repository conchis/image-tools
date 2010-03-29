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

	import origami.geometry.Dimensions;
	import origami.geometry.Point;

	/**
	 * Controls the viewport to animate the zoom between two scales.
	 *
	 * @author Jonathan A. Smith
	 */

	internal class ZoomAnimator
	{
		/** Viewport controlled by this object. */
		internal var viewport: Viewport;

		/** True when animating. */
		internal var is_animating: Boolean;

		/** Scale at the beginning of animation. */
		internal var start_scale: Number;

		/** Scale we are animating to. */
		internal var target_scale: Number;

		/** Increment to add on each step. */
		internal var scale_increment: Number;

		/** Scroll center point at beginning of animation. */
		internal var start_scroll: Point;

		/** Scroll point at end of animation. */
		internal var target_scroll: Point;

		/** Increment to add to scroll on each step. */
		internal var scroll_increment: Dimensions;

		/** Number of steps for animation. */
		internal var steps: Number;

		/** Number of steps so far used in animation. */
		internal var step_count: Number;

		/** Saved root onEnterFrame method. */
		internal var saved_on_enter_frame: Function;

		/**
		 * Constructs a ZoomAnimator
		 */

		function ZoomAnimator()
		{
			is_animating = false;
		}

		/**
		 * Sets the viewport to be animated.
		 *
		 * @parm viewport viewport to be animated
		 */

		internal function setViewport(viewport: Viewport): void
		{
			this.viewport = viewport;
		}

		/**
		 * Zoom animation to a specified scale and scroll point.
		 *
		 * @param target_scale scale to zoom to
		 * @param target_scroll scroll point
		 */

		internal function zoomTo(target_scale: Number, target_scroll: Point): void
		{
			// Set initial and target scale and scroll point
			start_scale = viewport.scale;
			start_scroll = viewport.scroll_center;
			this.target_scale  = target_scale;
			this.target_scroll = target_scroll;

			// Animation steps depending on the change in scale
		 	var level: Number      = Math.ceil(Math.log(start_scale) / Math.log(Math.SQRT2));
		 	var goal_level: Number = Math.ceil(Math.log(target_scale) / Math.log(Math.SQRT2));
		 	var steps: Number = Math.abs(level - goal_level) + 2;

		 	// Compute scale and scroll increments
			this.scale_increment  = (target_scale - start_scale) / steps;
			this.scroll_increment = target_scroll.subtractPoint(start_scroll).scale(1 / steps);

			// Start animation
			this.steps = steps;
			this.step_count = 0;
			startAnimation();
		}

		/**
		 * Initiate the animation.
		 */

		private function startAnimation(): void
		{
			is_animating = true;
			stepAnimation();
		}

		/**
		 * Method called on each step of the animation.
		 */

		internal function stepAnimation(): Boolean
		{
			if (!is_animating) return false;

			// On last animation step, snap to goal scale
			if (step_count >= steps)
			{
				viewport.setScale(target_scale);
				is_animating = false;
				return false;
			}

			// Set scale for step and increment count
			var scale: Number = (target_scale + viewport.scale) / 2;
			var scroll_point: Point =
					target_scroll.addPoint(viewport.scroll_center).scale(1 / 2);

			viewport.updateView(scale, scroll_point);
			step_count += 1;
			viewport.dispatchEvent(new Event(Viewport.UPDATE));
			return true;
		}

	}

}