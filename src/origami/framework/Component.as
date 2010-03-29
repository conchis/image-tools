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

package origami.framework
{
	import flash.events.Event;

	import mx.containers.Canvas;

	import origami.geometry.Rectangle;

	/**
	 * A UIComponent class with methods for parsing application arguments.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Component extends Canvas
	{
		/** Id of event triggered on parameter changes. */
		public static const PARAMETERS_CHANGED: String
				= "origami.framework.Component.PARAMETERS_CHANGED";

		/** Component parameters. */
		private var __parameters: Object = new Object();

		/**
		 * Constructs a new component.
		 */

		public function Component()
		{
			super();
		}

		/**
		 * Sets the parameters object, the mapping between parameter names
		 * and values.
		 *
		 * @param parameters mapping from names to parameter values
		 */

		public function set parameters(parameters: Object): void
		{
			if (__parameters == parameters) return;
			__parameters = parameters;
			dispatchEvent(new Event(PARAMETERS_CHANGED));
		}

		/**
		 * Returns the mapping from parameter names to values.
		 *
		 * @return parameter mapping
		 */

		public function get parameters(): Object
		{
			return __parameters;
		}

		/**
		 * Determines if the component has the named parameter.
		 *
		 * @param name parameter name
		 * @return true if parameter is present, false otherwise
		 */

		public function hasParameter(name: String): Boolean
		{
			return __parameters[name] != null;
		}

		/**
		 * Returns the value of a string valued parameter.
		 *
		 * @param name parameter name
		 * @return parameter value
		 */

		public function getStringParameter(name: String): String
		{
			return String(__parameters[name]);
		}

		/**
		 * Returns the value of a number valued parameter.
		 *
		 * @param name parameter name
		 * @return number value of parameter
		 */

		public function getNumberParameter(name: String, default_value: Number = 0): Number
		{
			var parameter_string: String = __parameters[name];
			if (parameter_string == null)
				return default_value;
			return parseFloat(parameter_string);
		}

		/**
		 * Returns the value of a rectangle valued parameter specified
		 * as left, top, right, bottom coordinates.
		 *
		 * @param name parameter name
		 * @return rectangle value of parameter
		 */

		public function getRectangleParameter(name: String,
				default_value: Rectangle = null): Rectangle
		{
			var parameter_string: String = __parameters[name];
			if (parameter_string == null)
				return default_value;

			var dimensions: Array = parameter_string.split(",");
			if (dimensions.length != 4) return default_value;

			var left:   Number = parseFloat(String(dimensions[0]));
			var top:    Number = parseFloat(String(dimensions[1]));
			var right:  Number = parseFloat(String(dimensions[2]));
			var bottom: Number = parseFloat(String(dimensions[3]));

			return Rectangle.makeLeftTopRightBottom(left, top, right, bottom);
		}

		/**
		 * Returns the value of a boolean parameter.
		 *
		 * @param name parameter name
		 * @return boolean value of parameter
		 */

		public function getBooleanParameter(name: String): Boolean
		{
			var value_string: String = __parameters[name];
			if (value_string == null)
				return false;
			value_string = value_string.toLowerCase();
			if (value_string == "" || value_string == "yes"
					|| value_string == "true")
				return true;
			return false;
		}

	}
}