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
	 * A Polygon consists of a series of linked points.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Polygon
	{
	    /** Array of points in polygon. */
	    public var points: Array;

	    // **** Initialization

	    /** Constructs an empty polygon. */

	    function Polygon()
	    {
	        points = new Array();
	    }

	    /**
	     * Makes a polygon from a series of point arguments.
	     *
	     * @param arguments series of point arguments
	     */

	    public static function makePoints(... arguments: Array): Polygon
	    {
	        var polygon: Polygon = new Polygon();
	        var points: Array = polygon.points;
	        for (var index: Number = 0; index < arguments.length; index++)
	        {
	            if (!(arguments[index] is Point))
	                throw new Error("Invalid argument: " + arguments[index]);
	            points.push(arguments[index]);
	        }
	        return polygon;
	    }

	    // **** Measuring

	    /**
	     * Returns the number of points.
	     *
	     * @return number of points in the polygon
	     */

	    public function get length(): Number
	    {
	        return points.length;
	    }

	    /**
	     * Returns a bounding rectangle for this figure.
	     *
	     * @return bounding rectangle
	     */

	    public function get bounds(): Rectangle
	    {
	        // If no points, return an empty rectangle
	        if (points.length == 0) return new Rectangle();
	        // Find boundary coordinates
	        var left:   Number = points[0].x;
	        var top:    Number = points[0].y;
	        var right:  Number = left;
	        var bottom: Number = top;
	        for (var index: Number = 0; index < points.length; index+= 1)
	        {
	            var point: Point = points[index];
	            if (point.x < left)   left   = point.x;
	            if (point.y < top)    top    = point.y;
	            if (point.x > right)  right  = point.x;
	            if (point.y > bottom) bottom = point.y;
	        }
	        // Return rectangle
	        return Rectangle.makeLeftTopRightBottom(left, top, right, bottom);
	    }

	    // **** Iteration

	    /**
	     * Iterates over all line segments in a polygon. The segment ending in the
	     * first point is examined first.
	     *
	     * @param fn function to be applied to each line segment.
	     */

	    public function forSegments(fn: Function): void
	    {
	    	// If no segments, return
	    	if (points.length < 2) return;

	    	// Apply fn for last segment back to start
	    	fn(points[points.length - 1], points[0]);

	    	// Loop over each pair of points
	    	for (var index: int = 0; index < (points.length - 1); index += 1)
	    		fn(points[index], points[index+1]);
	    }

	    // **** Projection

	    /**
	     * Returns a polygon projected into a new coordinate system by the
	     * specified transform.
	     *
	     * @param transform transform to apply to polygon
	     * @return transformed polygon
	     */

	    public function project(transform: Transform): Polygon
	    {
	        var result: Polygon = new Polygon();
	        var new_points: Array = result.points;
	        for (var index: Number = 0; index < points.length; index++)
	            new_points.push(transform.project(points[index]));
	        return result;
	    }

	    // **** Polygon Clipping

	    /**
	     * Clips a polygon to fit within a specified rectangle.
	     *
	     * @param clipping_rectangle clipping rectangle
	     */

	    public function clip(clipping_rectangle: Rectangle): Polygon
	    {
	    	var result: Polygon = new Polygon();
	    	result.points = this.points;
	    	clipHorizontalRight(result, clipping_rectangle.right);
	    	clipVerticalBottom(result, clipping_rectangle.bottom);
	    	clipHorizontalLeft(result, clipping_rectangle.left);
	    	clipVerticalTop(result, clipping_rectangle.top);
	    	return result;
	    }

	    private function intersectVertical(previous: Point, current: Point, clip_y: Number): Point
	    {
			var delta_x: Number = current.x - previous.x;
			var delta_y: Number = current.y - previous.y;
			var offset_y: Number = clip_y - previous.y;
			return Point.makeXY(previous.x + offset_y * delta_x / delta_y, clip_y);
	    }

	    private function intersectHorizontal(previous: Point, current: Point, clip_x: Number): Point
	    {
			var delta_x: Number = current.x - previous.x;
			var delta_y: Number = current.y - previous.y;
			var offset_x: Number = clip_x - previous.x;
			return Point.makeXY(clip_x, previous.y + offset_x * delta_y / delta_x);
	    }

	    public function clipHorizontalRight(polygon: Polygon, clip_x: Number): void
	    {
	    	var points: Array = new Array();

	    	polygon.forSegments(
	    		function(previous: Point, current: Point): void
	    		{
	    			if (previous.x <= clip_x)
	    			{
	    				if (current.x <= clip_x)
	    					points.push(current);
	    				else
	    					points.push(intersectHorizontal(previous, current, clip_x));
	    			}
	    			else
	    			{
	    				if (current.x <= clip_x)
	    				{
							points.push(intersectHorizontal(previous, current, clip_x));
	    					points.push(current);
	    				}
	    			}
	    		});

	    	polygon.points = points;
	    }

	    public function clipHorizontalLeft(polygon: Polygon, clip_x: Number): void
	    {
	    	var points: Array = new Array();

	    	polygon.forSegments(
	    		function(previous: Point, current: Point): void
	    		{
	    			if (clip_x <= previous.x)
	    			{
	    				if (clip_x <=  current.x)
	    					points.push(current);
	    				else
	    					points.push(intersectHorizontal(previous, current, clip_x));
	    			}
	    			else
	    			{
	    				if (clip_x <= current.x)
	    				{
							points.push(intersectHorizontal(previous, current, clip_x));
	    					points.push(current);
	    				}
	    			}
	    		});

	    	polygon.points = points;
	    }

	    public function clipVerticalBottom(polygon: Polygon, clip_y: Number): void
	    {
	    	var points: Array = new Array();

	    	polygon.forSegments(
	    		function(previous: Point, current: Point): void
	    		{
	    			if (previous.y <= clip_y)
	    			{
	    				if (current.y <= clip_y)
	    					points.push(current);
	    				else
	    					points.push(intersectVertical(previous, current, clip_y));
	    			}
	    			else
	    			{
	    				if (current.y <= clip_y)
	    				{
							points.push(intersectVertical(previous, current, clip_y));
	    					points.push(current);
	    				}
	    			}
	    		});

	    	polygon.points = points;
	    }

	    public function clipVerticalTop(polygon: Polygon, clip_y: Number): void
	    {
	    	var points: Array = new Array();

	    	polygon.forSegments(
	    		function(previous: Point, current: Point): void
	    		{
	    			if (clip_y <= previous.y)
	    			{
	    				if (clip_y <= current.y)
	    					points.push(current);
	    				else
	    					points.push(intersectVertical(previous, current, clip_y));
	    			}
	    			else
	    			{
	    				if (clip_y <= current.y)
	    				{
							points.push(intersectVertical(previous, current, clip_y));
	    					points.push(current);
	    				}
	    			}
	    		});

	    	polygon.points = points;
	    }

	    // **** Drawing

	   /**
	    * Draw each of the points in the polygon.
	    *
	    * @param graphics graphics to draw on
	    */

	    public function drowOn(graphics: Graphics): void
	    {
	    	if (points.length == 0) return;
	    	graphics.moveTo(points[0].x, points[0].y);
	    	for (var index: int = 1; index < points.length; index += 1)
	    		graphics.lineTo(points[index].x, points[index].y);
	    	graphics.lineTo(points[0].x, points[0].y);
	    }

	    // **** String Representation

	    /**
	     * Returns a string representation of this polygon.
	     */

	    public function toString(): String
	    {
	        var result: String = "Polygon([";
	        for (var index: Number = 0; index < points.length; index++)
	        {
	            if (index > 0)
	                result += ", ";
	            result += points[index].toString();
	        }
	        result += "])";
	        return result;
	    }

	}
}