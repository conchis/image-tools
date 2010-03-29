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

package origami.geometry
{
	/**
	 * Utility functions for angle conversion.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Angles
	{
		/** Two Pi. */
		private static const TWO_PI: Number = 2 * Math.PI;

		/**
		 * Converts an angle in degrees to radians.
		 *
		 * @param degrees angle in degress
		 * @return angle in radians
		 */

		public static function toRadians(degrees: Number): Number
		{
			return degrees * (TWO_PI / 360.0);
		}

		/**
		 * Converts an angle from radians to degrees.
		 *
		 * @param radians angle in radians
		 * @return angle in degrees
		 */

		public static function toDegrees(radians: Number): Number
		{
			return radians * (360.0 / TWO_PI);
		}

	}
}