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

	import origami.geometry.Rectangle;

	/**
	 * Event class for areas selected with with SelectionRectangle.
	 *
	 * @author Jonathan A. Smtih
	 */

	public class SelectionEvent extends Event
	{
		/** Event ID. */
		public static const SELECT: String = "origami.viewer.SelectionEvent.SELECT";

		/** Selection sectangle. */
		public var selection_rectangle: Rectangle;

		/**
		 * Constructs a SelectionEvent.
		 *
		 * @param selection_rectangle rectangle selected by user
		 */

		public function SelectionEvent(selection_rectangle: Rectangle)
		{
			super(SELECT, true, false);
			this.selection_rectangle = selection_rectangle;
		}

	}
}