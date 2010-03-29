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

	import origami.geometry.Point;

	/**
	 * An affine transform matrix for translating from one coordinate system
	 * to another.
	 *
	 * @author Jonathan A. Smith
	 */

	public class Transform
	{

	    /** 3 x 3 transform matrix stored as a list of nine values. */
	    private var matrix: Array;

	    // **** Initialization

	    /**
	     * Constructs a Transform. The default matrix is the identity matrix.
	     */

	    function Transform()
	    {
	        this.matrix = [1, 0, 0, 0, 1, 0, 0, 0, 1];
	    }

	    /**
	     * Returns the identity transform.
	     *
	     * @return identity transform
	     */

	    public static function makeIdentity(): Transform
	    {
	        return new Transform();
	    }

	    /**
	     * Returns a transform for translation.
	     *
	     * @param offset_x x offset for translation
	     * @param offset_y y offset for translation
	     * @return translation transform
	     */

	    public static function makeTranslate(offset_x: Number, offset_y: Number): Transform
	    {
	        var transform: Transform = new Transform();
	        transform.matrix = [1, 0, offset_x, 0, 1, offset_y, 0, 0, 1];
	        return transform;
	    }

	    /**
	     * Returns a transform for scaling.
	     *
	     * @param scale_x x coordinate multiplier
	     * @param scale_y y coordinate multiplier
	     * @return transform for scaling
	     */

	    public static function makeScale(scale_x: Number, scale_y: Number): Transform
	    {
	        var transform: Transform = new Transform();
	        transform.matrix = [scale_x, 0, 0, 0, scale_y, 0, 0, 0, 1];
	        return transform;
	    }

	    /**
	     * Returns a transform for rotation.
	     *
	     * @param radians angle in radians
	     * @return transform for rotation
	     */

	    public static function makeRotate(radians: Number): Transform
	    {
	        var cos_angle: Number = Math.cos(radians);
	        var sin_angle: Number = Math.sin(radians);
	        var transform: Transform = new Transform();
	        transform.matrix = [
	            cos_angle, -sin_angle, 0, sin_angle, cos_angle, 0, 0, 0, 1];
	        return transform;
	    }

	    /**
	     * Returns a transform for rotation around a specified point.
	     *
	     * @param radians angle in radians
	     * @param center center point for rotaton
	     * @return transform for rotation and translation
	     */

	    public static function makeRotateAround(radians: Number, center: Point): Transform
	    {
			return makeTranslate(center.x, center.y)
					.compose(makeRotate(radians))
					.compose(makeTranslate(-center.x, -center.y));
	    }

	    // **** Projection

	    /**
	     * Converts a point into the coordinate system described by this
	     * transform.
	     *
	     * @param point to be projected
	     * @return projected point
	     */

	    public function project(point: Point): Point
	    {
	        return Point.makeXY(
	            matrix[0] * point.x + matrix[1] * point.y + matrix[2],
	            matrix[3] * point.x + matrix[4] * point.y + matrix[5]  );
	    }

	    // **** Composition and Inverse

	    /**
	     * Combines transforms by multiplying matrices.
	     *
	     * @param transform Transform to be performed before this transform
	     * @return combined transform
	     */

	    public function compose(transform: Transform): Transform
	    {
	        var a: Array = matrix;
	        var b: Array = transform.matrix;
	        var result: Transform = new Transform();

	        result.matrix = [
	            a[0]*b[0] + a[1]*b[3] + a[2]*b[6],
	            a[0]*b[1] + a[1]*b[4] + a[2]*b[7],
	            a[0]*b[2] + a[1]*b[5] + a[2]*b[8],

	            a[3]*b[0] + a[4]*b[3] + a[5]*b[6],
	            a[3]*b[1] + a[4]*b[4] + a[5]*b[7],
	            a[3]*b[2] + a[4]*b[5] + a[5]*b[8],

	            a[6]*b[0] + a[7]*b[3] + a[8]*b[6],
	            a[6]*b[1] + a[7]*b[4] + a[8]*b[7],
	            a[6]*b[2] + a[7]*b[5] + a[8]*b[8]  ];

	        return result;
	    }

	    /**
	     * Compute the inverse of the matrix to reverse the transform.
	     */

	    public function inverse(): Transform
	    {
	        var a: Array = matrix;
	        var det: Number =
	            (  a[0]*a[4]*a[8] - a[0]*a[5]*a[7] - a[1]*a[3]*a[8]
	             + a[1]*a[5]*a[6] + a[2]*a[3]*a[7] - a[2]*a[4]*a[6] );

	        var result: Transform = new Transform();
	        result.matrix = [
	            ( a[4]*a[8] - a[5]*a[7]) / det,
	            -(a[1]*a[8] - a[2]*a[7]) / det,
	            ( a[1]*a[5] - a[2]*a[4]) / det,

	            -(a[3]*a[8] - a[5]*a[6]) / det,
	            ( a[0]*a[8] - a[2]*a[6]) / det,
	            -(a[0]*a[5] - a[2]*a[3]) / det,

	            ( a[3]*a[7] - a[4]*a[6]) / det,
	            -(a[0]*a[7] - a[1]*a[6]) / det,
	            ( a[0]*a[4] - a[1]*a[3]) / det ];

	        return result;
	    }

	    // **** Equals

	    /**
	     * Determines if two transforms are equal.
	     *
	     * @return true only if transforms are equal
	     */

	    public function equals(other: Object): Boolean
	    {
	        if (!(other is Transform))
	            return false;

	        var other_matrix: Array = other.matrix;
	        if (other_matrix.length != matrix.length)
	            return false;

	        for (var index: Number = 0; index < matrix.length; index += 1)
	        {
	            if (matrix[index] != other_matrix[index])
	            return false;
	        }

	        return true;
	    }

	    // **** Flash 7 Matrix

	    /**
	     * Converts the transform in to the "old" flash format. This is required
	     * to support Flash 7 player.
	     */

	    public function asFlash7Matrix(): Object
	    {
	    		return { a: matrix[0], b: matrix[1], c: matrix[2],
	    			     d: matrix[3], e: matrix[4], f: matrix[5],
	    			     g: matrix[6], h: matrix[7], i: matrix[8] };
	    }

	    // **** String Representation

	    /**
	     * Returns a string representation of the transform matrix.
	     *
	     * @return string representation
	     */

	    public function toString(): String
	    {
	        var out: String = "";
	        for (var row: Number = 0; row < 3; row += 1)
	        {
	            out += "\n[";
	            for (var column: Number = 0; column < 3; column += 1)
	            {
	                if (column > 0) out += ", ";
	                var index: Number = row * 3 + column;
	                out += "" + matrix[index];
	            }
	            out += "]";
	        }
	        return out;
	    }

	}
}
