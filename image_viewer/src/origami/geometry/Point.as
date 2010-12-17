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
	import origami.geometry.Dimensions;
	import origami.geometry.Transform;
	import origami.geometry.Rectangle;

	/**
	 * Point class.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Point
	{
	    /** Point x coordinate. */
	    public var x: Number = 0;

	    /** Point y coordinate. */
	    public var y: Number = 0;

	    // **** Rectangular Coordinates

	    /**
	     * Makes a point from an x and y coordinate.
	     *
	     * @param x x coordinate
	     * @param y y coordinate
	     * @return new Point with specified coordinates
	     */

	    public static function makeXY(x: Number, y: Number): Point
	    {
	        var new_point: Point = new Point();
	        new_point.x = x;
	        new_point.y = y;
	        return new_point;
	    }

	    /**
	     * Makes a point as a copy of another point.
	     *
	     * @param point Point to be copied
	     * @return copied Point
	     */

	    public static function makePoint(point: Point): Point
	    {
	        var new_point: Point = new Point();
	        new_point.x = point.x;
	        new_point.y = point.y;
	        return new_point;
	    }

	    // **** Polar Coordinates

	    /**
	     * Makes a point from polar coordinates: angle and distance.
	     *
	     * @param angle angle from origin in radians
	     * @param distance distance from origin
	     * @return new point
	     */

	    public static function makeAngleDistance(angle: Number, distance: Number): Point
	    {
	        var new_point: Point = new Point();
	        new_point.x = distance * Math.cos(angle);
	        new_point.y = distance * Math.sin(angle);
	        return new_point;
	    }

	    /**
	     * Returns the angle of this point in polar coordinates.
	     *
	     * @return angle in radians
	     */

	    public function get angle(): Number
	    {
	        var point_angle: Number = 0;
	        if (x > 0)
	            point_angle = Math.atan(y / x);
	        else if (x < 0)
	            point_angle = Math.atan(y / x) + Math.PI;
	        else if (y > 0)
	            point_angle = Math.PI / 2;
	        else if (y < 0)
	            point_angle = -Math.PI / 2;
	        if (point_angle < 0)
	            point_angle += 2 * Math.PI;
	        return point_angle;
	    }

	    /**
	     * Returns the distance of this point in polar coordinates.
	     *
	     * @return distance from origin
	     */

	    public function get distance(): Number
	    {
	        return Math.sqrt(x * x + y * y);
	    }

	    // **** Transform

	    /**
	     * Project the point into the coordinate system defined by a transform
	     * object.
	     *
	     * @param transform Transform object
	     * @return transformed point
	     */

	    public function project(transform: Transform): Point
	    {
	        return transform.project(this);
	    }

	    // **** Operations

	    /**
	     * Computes the distance between this and another point.
	     *
	     * @param other_point other point
	     * @return distance between points
	     */

	    public function distanceTo(other_point: Point): Number
	    {
	        var x_distance: Number = other_point.x - x;
	        var y_distance: Number = other_point.y - y;
	        return Math.sqrt(x_distance * x_distance + y_distance * y_distance);
	    }

	    /**
	     * Compute the angle between this and another point.
	     *
	     * @param other_point other point
	     * @return difference of angle from origin
	     */

	    public function angleTo(other_point: Point): Number
	    {
	        var x_distance: Number = other_point.x - x;
	        var y_distance: Number = other_point.y - y;
	        var relative_angle: Number = 0;
	        if (x_distance > 0)
	            relative_angle = Math.atan(y_distance / x_distance);
	        else if (x_distance < 0)
	            relative_angle = Math.atan(y_distance / x_distance) + Math.PI;
	        else if (y_distance > 0)
	            relative_angle = Math.PI / 2;
	        else if (y_distance < 0)
	            relative_angle = -Math.PI / 2;
	        if (relative_angle < 0)
	            relative_angle += 2 * Math.PI;
	        return relative_angle;
	    }

	    /**
	     * Adds another point to this point.
	     *
	     * @param other_point other point
	     * @return sum of points
	     */

	    public function addPoint(other_point: Point): Point
	    {
	        return Point.makeXY(x + other_point.x, y + other_point.y);
	    }

	    /**
	     * Subtracts another point from this point.
	     *
	     * @param other_point other point
	     * @return difference of points
	     */

	    public function subtractPoint(other_point: Point): Dimensions
	    {
	        return Dimensions.makeWidthHeight(x - other_point.x, y - other_point.y);
	    }

	    /**
	     * Adds dimensions to this point.
	     *
	     * @param dimensions Dimensions
	     * @return point plus dimensions
	     */

	    public function addDimensions(dimensions: Dimensions): Point
	    {
	        return Point.makeXY(x + dimensions.width, y + dimensions.height);
	    }

	    /**
	     * Subtracts dimensions from this point.
	     *
	     * @param dimensions Dimensions
	     * @return point less dimensions
	     */

	    public function subtractDimensions(dimensions: Dimensions): Point
	    {
	        return Point.makeXY(x - dimensions.width, y - dimensions.height);
	    }

	    /**
	     * Multiplies coordinates by a Dimensions object.
	     *
	     * @param dimensions Dimensions object to multiply
	     * @return Point result
	     */

	    public function multiplyDimensions(dimensions: Dimensions): Point
	    {
	        return Point.makeXY(x * dimensions.width, y * dimensions.height);
	    }

	    /**
	     * Divides coordinates by by a Dimensions object.
	     *
	     * @param dimensions Dimensions object to divide
	     * @return Point result
	     */

	    public function divideDimensions(dimensions: Dimensions): Point
	    {
	        return Point.makeXY(x / dimensions.width, y / dimensions.height);
	    }

	    /**
	     * Rotate a point around its origin by a specified angle.
	     *
	     * @param delta rotation angle in raidians
	     */

	    public function rotate(delta: Number): Point
	    {
	        return Point.makeAngleDistance(delta + angle, distance);
	    }

	    /**
	     * Add an x and y offset to the point.
	     *
	     * @param x_offset value to be added to x coordinate
	     * @param y_offset value to be added to y coordinate
	     * @return Point with offset coordinates
	     */

	    public function translate(x_offset: Number, y_offset: Number): Point
	    {
	        return Point.makeXY(x + x_offset, y + y_offset);
	    }

	    /**
	     * Multiplies point coordinates by a constant.
	     *
	     * @param multiplier value to multiply
	     * @return Point with multiplied coordinates
	     */

	    public function scale(multiplier: Number): Point
	    {
	        return Point.makeXY(x * multiplier, y * multiplier);
	    }

	    /**
	     * Pins the point within a specified rectangle.
	     */

	    public function pinInRectangle(rectangle: Rectangle): Point
	    {
	    		return Point.makeXY(
	    			Math.max(rectangle.left, Math.min(x, rectangle.right)),
	    			Math.max(rectangle.top,  Math.min(y, rectangle.bottom)) );
	    }

	    /**
	     * Round coordinates to nearest integer.
	     *
	     * @return Point with x and y coordinates rounded to nearest integer
	     */

	    public function round(): Point
	    {
	        return Point.makeXY(Math.round(x), Math.round(y));
	    }

	    // **** Testing

	    /**
	     * Test if two points are equal. Note that this will often fail due
	     * to round off error if the coordinates are not integers.
	     *
	     * @param other other Point or object
	     */

	    public function equals(other: Object): Boolean
	    {
	        if (!(other is Point)) return false;
	        return x == other.x && y == other.y;
	    }

	    // **** String Representation

	    /**
	     * Returns a string representation of the point.
	     *
	     * @return string representation of point
	     */

	    public function toString(): String
	    {
	        return "(" + x + ", " + y + ")";
	    }

	}
}