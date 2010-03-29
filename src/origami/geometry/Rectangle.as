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
	import flash.display.Graphics;

	/**
	 * Rectangle object.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Rectangle
	{
	    /** Top position of rectangle. */
	    public var top:    Number;

	    /** Left position of rectangle. */
	    public var left:   Number;

	    /** Width of rectangle. */
	    public var width:  Number;

	    /** Height of rectangle. */
	    public var height: Number;

	    // **** Initialization

	    /**
	     * Makes a rectangle for a given left, top, width, and height.
	     *
	     * @param left left position
	     * @param top rectangle top position
	     * @param width rectangle width
	     * @param height rectangle height
	     * @return new rectangle
	     */

	    public static function makeLeftTopWidthHeight(left: Number, top: Number,
	            width: Number, height: Number): Rectangle
	    {
	        var rectangle: Rectangle = new Rectangle();
	        rectangle.left   = left;
	        rectangle.top    = top;
	        rectangle.width  = width;
	        rectangle.height = height;
	        return rectangle;
	    }

	    /**
	     * Makes a rectangle for a specified left, top, right, and bottom.
	     *
	     * @param left left position
	     * @param top rectangle top position
	     * @param right rectangle right edge
	     * @param bottom rectangle bottom edge
	     * @return new rectangle
	     */

	    public static function makeLeftTopRightBottom(left: Number, top: Number,
	            right: Number, bottom: Number): Rectangle
	    {
	        var rectangle: Rectangle = new Rectangle();
	        rectangle.left   = left;
	        rectangle.top    = top;
	        rectangle.width  = right - left;
	        rectangle.height = bottom - top;
	        return rectangle;
	    }

	    /**
	     * Makes a new rectangle as a copy of an existing rectangle.
	     *
	     * @param other rectangle to copy
	     * @return new rectangle
	     */

	    public static function makeRectangle(other: Rectangle): Rectangle
	    {
	        var rectangle: Rectangle = new Rectangle();
	        rectangle.left   = other.left;
	        rectangle.top    = other.top;
	        rectangle.width  = other.width;
	        rectangle.height = other.height;
	        return rectangle;
	    }

	    // **** Accessors

	    /**
	     * Returns the right coordinate.
	     *
	     * @return position of right edge
	     */

	    public function get right(): Number
	    {
	        return left + width;
	    }

	    /**
	     * Returns the bottom coordinate.
	     *
	     * @return position of bottom edge
	     */

	    public function get bottom(): Number
	    {
	        return top + height;
	    }

	    /**
	     * Returns the top left point.
	     *
	     * @return top left corner point
	     */

	    public function get top_left(): Point
	    {
	        return Point.makeXY(left, top);
	    }

	    /**
	     * Returns the bottom right point
	     *
	     * @return bottom right point
	     */

	    public function get bottom_right(): Point
	    {
	        return Point.makeXY(left + width, top + height);
	    }

	    /**
	     * Returns the dimensions of the rectangle.
	     *
	     * @return dimensions of rectangle
	     */

	    public function get dimensions(): Dimensions
	    {
	        return Dimensions.makeWidthHeight(width, height);
	    }

	    /**
	     * Returns the center point of the rectangle.
	     *
	     * @return center point
	     */

	    public function get center(): Point
	    {
	        return Point.makeXY(left + width / 2, top + height / 2);
	    }

	    /**
	     * Returns the area of the rectangle.
	     */

	    public function get area(): Number
	    {
	    		return width * height;
	    }

	    /**
	     * Returns the length of the diagnal.
	     *
	     * @return length of the diagnal
	     */

	    public function get diagnal(): Number
	    {
	        return Math.sqrt(width * width + height * height);
	    }

	    // **** Testing

	    /**
	     * Determines if two rectangles are equal.
	     *
	     * @param other rectangle to compare with this rectangle
	     * @return true only if other is equal
	     */

	    public function equals(other: Rectangle): Boolean
	    {
	    		if (other == null) return false;
	    		return (   left   == other.left
	    				&& top    == other.top
	    				&& width  == other.width
	    				&& height == other.height);
	    }

	    /**
	     * Determines if this rectangle contains another rectangle.
	     *
	     * @param other other rectangle to test
	     * @return true only if this rectangle contains another rectangle
	     */

	    public function contains(other: Rectangle): Boolean
	    {
	        return (    other.top    >= top
	                 && other.bottom <= bottom
	                 && other.left   >= left
	                 && other.right  <= right  );
	    }

	    /**
	     * Determines if a specified rectangle overlaps this rectangle.
	     *
	     * @param other other rectangle to test
	     * @return true only if this rectangle overlaps another rectangle
	     */

	    public function overlaps(other: Rectangle): Boolean
	    {
	        return (    other.bottom >= top
	                 && other.top    <= bottom
	                 && other.right  >= left
	                 && other.left   <= right  );
	    }

	    /**
	     * Determines if a point is within this rectangle.
	     *
	     * @param point point to test
	     * @return true only if this rectangle contains a specified point
	     */

	    public function containsPoint(point: Point): Boolean
	    {
	        return (    point.x >= left && point.x <= right
	                 && point.y >= top  && point.y <= bottom  );
	    }

	    // **** Operations and Conversion

	    /**
	     * Returns a rectangle projected in to a specified coordinate system
	     * via a transform.
	     *
	     * @param transform transform to apply
	     * @return transformed rectangle
	     */

	    public function project(transform: Transform): Rectangle
	    {
	        var new_top_left: Point = transform.project(top_left);
	        var new_bottom_right: Point = transform.project(bottom_right);
	        return Rectangle.makeLeftTopRightBottom(
	                new_top_left.x, new_top_left.y,
	                new_bottom_right.x, new_bottom_right.y);
	    }

	    /**
	     * Returns a rectangle with each coordinate rounded to the nearest integer.
	     *
	     * @return rectangle with coordinates rounded to nearest integer
	     */

	    public function round(): Rectangle
	    {
	        return Rectangle.makeLeftTopWidthHeight(
	                Math.round(left), Math.round(top),
	                Math.round(width), Math.round(height));
	    }

	    /**
	     * Creates a new rectangle inset by the specified width and height.
	     *
	     * @param inset_width width to inset rectangle
	     * @param inset_height height to inset rectangle
	     * @return inset rectangle
	     */

	    public function inset(inset_width: Number, inset_height: Number): Rectangle
	    {
	        inset_width  = Math.min(inset_width,  width  / 2);
	        inset_height = Math.min(inset_height, height / 2);
	        return Rectangle.makeLeftTopWidthHeight(
	                left   + inset_width,
	                top    + inset_height,
	                width  - 2 * inset_width,
	                height - 2 * inset_height);
	    }

	    /**
	     * Returns a rectangle: the intersection of this and another rectangle.
	     *
	     * @param other_rectangle other rectangle to intersect
	     */

	    public function intersect(other_rectangle: Rectangle): Rectangle
	    {
	        return Rectangle.makeLeftTopRightBottom(
	            Math.max(left,   other_rectangle.left),
	            Math.max(top,    other_rectangle.top),
	            Math.min(right,  other_rectangle.right),
	            Math.min(bottom, other_rectangle.bottom));
	    }

	    /**
	     * Returns a rectangle that is enclosed by this rectangle by moving
	     * the rectangle's origin inside this rectangle and then clipping
	     * the width and height to fit.
	     */

	    public function pin(other_rectangle: Rectangle): Rectangle
	    {
	    		// Pin top left in this rectangle
	    		var result_left: Number =
	    				Math.min(Math.max(left, other_rectangle.left), right);
	    		var result_top:  Number =
	    				Math.min(Math.max(top, other_rectangle.top), bottom);

	    		// Slide other rectangle inside this (if possible)
	    		var max_width: Number = width - result_left;
	    		if (other_rectangle.width > max_width)
	    			result_left = Math.max(right - other_rectangle.width, left);
	    		var max_height: Number = height - result_top;
	    		if (other_rectangle.height > max_height)
	    			result_top = Math.max(bottom - other_rectangle.height, top);

	    		// Trim the resulting rectangle to this rectangle's size
	    		var result_width: Number =
	    				Math.min(other_rectangle.width, width - result_left);
	    		var result_height: Number =
	    				Math.min(other_rectangle.height, height - result_top);

	    		// Return resulting rectangle
	    		return Rectangle.makeLeftTopWidthHeight(result_left, result_top,
	    				result_width, result_height);
	    }

	    /**
	     * Return the smallest rectangle that contains this and another rectangle.
	     *
	     * @param other rectangle to include
	     */

	    public function extend(other: Rectangle): Rectangle
	    {
	        return Rectangle.makeLeftTopRightBottom(
	            Math.min(left,  other.left ), Math.min(top,    other.top   ),
	            Math.max(right, other.right), Math.max(bottom, other.bottom) );
	    }

	    /**
	     * Returns a new rectangle translated by a specified x and y offset.
	     *
	     * @param offset_x offset in x direction
	     * @param offset_y offset in y direction
	     */

	    public function translate(offset_x: Number, offset_y: Number): Rectangle
	    {
	    		return Rectangle.makeLeftTopWidthHeight(
	    				left + offset_x, top + offset_y, width, height);
	    }

	    /**
	     * Returns a Polygon with this rectangle's boundary points.
	     *
	     * @return a polygon with the same boundary as this rectangle
	     */

	    public function get polygon(): Polygon
	    {
	        return Polygon.makePoints(
	            Point.makeXY(left, top), Point.makeXY(right, top),
	            Point.makeXY(right, bottom), Point.makeXY(left, bottom));
	    }

	    // **** Drawing

	   /**
	    * Draw the rectangle on a graphics object.
	    *
	    * @param graphics graphics to draw on
	    */

	    public function drowOn(graphics: Graphics): void
	    {
	    	graphics.moveTo(left, top);
	    	graphics.lineTo(right, top);
	    	graphics.lineTo(right, bottom);
	    	graphics.lineTo(left, bottom);
	    	graphics.lineTo(left, top);
	    }

	    // **** String Representation

	    /**
	     * Returns a string representation of the rectangle.
	     *
	     * @return string representation
	     */

	    public function toString(): String
	    {
	        return "" + top_left + " - " + bottom_right;
	    }

	}
}