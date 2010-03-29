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
	import flash.events.EventDispatcher;

	/**
	 * Application model for the viewer state. Manages information about the viewer
	 * mode.
	 *
	 * @author Jonathan A. Smith
	 */

	public class ViewerModel extends EventDispatcher
	{
		/** Constant for mode when mouse is used for zooming in. */
		public static const ZOOM_IN_MODE:  int = 1;

		/** Constant for mode when mouse is used for zooming out. */
		public static const ZOOM_OUT_MODE: int = 2;

		/** Constant for mode when mouse is used for panning. */
		public static const PAN_MODE:      int = 0;

		/** Zoom or pan mode. */
		private var __mode: int = ZOOM_IN_MODE;

		/** Mode stack. */
		private var __mode_stack: Array = new Array();

		/**
		 * Constructs a ViewerModel.
		 */

		public function ViewerModel()
		{
			super(null);
		}

		/**
		 * Sets the viewer mode. Clears any temporary changes that have been
		 * pushed into the stack.
		 *
		 * @param mode new mode value
		 */

		public function set mode(mode: int): void
		{
			var prior_mode: int = __mode;
			__mode = mode;
			__mode_stack = new Array();
			dispatchEvent(new Event(Event.CHANGE));
		}

		/**
		 * Returns the current mode value.
		 *
		 * @return mode value
		 */

		public function get mode(): int
		{
			return __mode;
		}

		/**
		 * Temporarily sets a new mode. The new mode can be removed and the mode
		 * revered to the old mode by calling pop.
		 *
		 * @parm mode new temporary mode
		 */

		public function pushMode(mode: int): void
		{
			__mode_stack.push(__mode);
			__mode = mode;
			dispatchEvent(new Event(Event.CHANGE));
		}

		/**
		 * Removes a temporary mode. Reverts to the mode that was set before the
		 * temporary mode was added. Returns the mode prior to reverting.
		 *
		 * @return mode prior to reverting
		 */

		public function popMode(): int
		{
			var prior: int = __mode;
			__mode = __mode_stack.pop();
			dispatchEvent(new Event(Event.CHANGE));
			return prior;
		}

		/**
		 * Returns true if current mode is temporary (that is has been pushed.)
		 *
		 * @return true if mode is temporary, false otherwise.
		 */

		public function isTemporaryMode(): Boolean
		{
			return __mode_stack.length > 0;
		}

	}
}