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

	import origami.geometry.Rectangle;

	/**
	 * Dimensions class represents a rectangular area or area size without a
	 * position.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Dimensions
	{
	    /** Dimensions width. */
	    public var width:  Number = 0;

	    /** Dimensions height. */
	    public var height: Number = 0;

	    /**
	     * Makes a Dimensions object with a specified width and height.
	     *
	     * @param width dimensions width
	     * @param height dimensions height
	     * @return Dimensions object
	     */

	    public static function makeWidthHeight(width: Number, height: Number): Dimensions
	    {
	        var new_dimensions: Dimensions = new Dimensions();
	        new_dimensions.width = width;
	        new_dimensions.height = height;
	        return new_dimensions;
	    }

	    /**
	     * Makes a Dimensions object as a copy of another Dimensions object.
	     *
	     * @param other Dimensions object to copy
	     */

	     public static function makeDimensions(other: Dimensions): Dimensions
	     {
	        var new_dimensions: Dimensions = new Dimensions();
	        new_dimensions.width = other.width;
	        new_dimensions.height = other.height;
	        return new_dimensions;
	     }

	    // **** Coordinates

	    /**
	     * Returns the distance from (0, 0) to a point at (x, y).
	     *
	     * @return length of diagonal
	     */

	    public function get distance(): Number
	    {
	        return Math.sqrt(width * width + height * height);
	    }

	    // **** Operations

	    /**
	     * Add another Dimensions object to this.
	     *
	     * @param other_size other Dimensions object
	     * @return sum Dimensions
	     */

	    public function addDimensions(other_size: Dimensions): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                width + other_size.width, height + other_size.height);
	    }

	    /**
	     * Subtract another Dimensions object from this.
	     *
	     * @param other_size other Dimensions object
	     * @return difference between dimensions
	     */

	    public function subtractDimensions(other_size: Dimensions): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                width - other_size.width, height - other_size.height);
	    }

	    /**
	     * Multiply by another Dimensions.
	     *
	     * @param dimensions Dimensions object to multiply
	     * @return multiplied Dimensions object
	     */

	    public function multiplyDimensions(dimensions: Dimensions): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                width * dimensions.width, height * dimensions.height);
	    }

	    /**
	     * Divide by another Dimensions.
	     *
	     * @param dimensions Dimensions object to divide by
	     * @return divided Dimensions object
	     */

	    public function divideDimensions(dimensions: Dimensions): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                width / dimensions.width, height / dimensions.height);
	    }

	    /**
	     * Multiply dimensions by a constant.
	     *
	     * @param multiplier multiplier to apply to dimensions
	     * @return scaled Dimensions object
	     */

	    public function scale(multiplier: Number): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                width * multiplier, height * multiplier);
	    }

	    /**
	     * Round dimensions to nearest integer.
	     *
	     * @return Dimensions with each dimension rounded to nearest integer
	     */

	    public function round(): Dimensions
	    {
	        return Dimensions.makeWidthHeight(
	                Math.round(width), Math.round(height));
	    }

	    // **** Testing

	    /**
	     * Test if two Dimensions are equal. Note that this will often fail due
	     * to round off error if the coordinates are not integers.
	     *
	     * @return true only if Dimensions are equal
	     */

	    public function equals(other: Object): Boolean
	    {
	        if (!(other is Dimensions)) return false;
	        return width == other.width && height == other.height;
	    }

	    // **** Type Change

	 	/**
	 	 * Returns a rectangle from (0, 0) with the dimensions width and height.
	 	 *
	 	 * @return a Rectangle
	 	 */

	    public function get rectangle(): Rectangle
	    {
	    		return Rectangle.makeLeftTopWidthHeight(0, 0, width, height);
	    }

	 	/**
	 	 * Returns a polygon fpr a four point rectangle from (0, 0) with the dimensions
	 	 * width and height.
	 	 *
	 	 * @return a Polygon
	 	 */

	    public function get polygon(): Polygon
	    {
	    	return Polygon.makePoints(Point.makeXY(0, 0), Point.makeXY(width, 0),
	    			Point.makeXY(width, height), Point.makeXY(0, height));
	    }

	    // **** String Representation

	    /**
	     * Returns a string representation of this object.
	     *
	     * @return string representation
	     */

	    public function toString(): String
	    {
	        return "Dimensions(" + width +  ", " + height + ")";
	    }

	}
}