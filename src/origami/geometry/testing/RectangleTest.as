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

package origami.geometry.testing
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

	import origami.geometry.Point;
	import origami.geometry.Rectangle;
	import origami.geometry.Transform;

	// Test the Rectangle class

	public class RectangleTest extends TestCase
	{

	    function RectangleTest(method: String)
	    {
	        super(method);
	    }

	    public function testMakeRectangle(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 100, 200);
	        assertEquals(0, r1.left);
	        assertEquals(0, r1.top);
	        assertEquals(100, r1.width);
	        assertEquals(200, r1.height);
	        assertEquals(100, r1.right);
	        assertEquals(200, r1.bottom);
	    }

	    public function testMakeWithCorners(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(10, 20, 110, 220);
	        assertEquals(10, r1.left);
	        assertEquals(20, r1.top);
	        assertEquals(100, r1.width);
	        assertEquals(200, r1.height);
	        assertEquals(110, r1.right);
	        assertEquals(220, r1.bottom);
	    }

	    public function testCornerPoints(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(10, 20, 110, 220);
	        var p1: Point = r1.top_left;
	        var p2: Point = r1.bottom_right;
	        assertEquals(10, p1.x);
	        assertEquals(20, p1.y);
	        assertEquals(110, p2.x);
	        assertEquals(220, p2.y);
	    }

	    public function testOverlaps(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(0, 0, 100, 100);
	        var r2: Rectangle = Rectangle.makeLeftTopRightBottom(200, 200, 210, 210);
	        var r3: Rectangle = Rectangle.makeLeftTopRightBottom(99, 99, 109, 109);
	        assertTrue(!r1.overlaps(r2));
	        assertTrue(!r2.overlaps(r1));
	        assertTrue(r1.overlaps(r3));
	        assertTrue(r3.overlaps(r1));
	    }

	    public function testContains(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(0, 0, 100, 100);
	        var r2: Rectangle = Rectangle.makeLeftTopRightBottom(5, 5,  10,  10);
	        var r3: Rectangle = Rectangle.makeLeftTopRightBottom(101, 0, 201, 100);
	        var r4: Rectangle = Rectangle.makeLeftTopRightBottom(5, 5, 101, 10);
	        assertTrue(r1.contains(r2));
	        assertTrue(!r2.contains(r1));
	        assertTrue(!r1.contains(r3));
	        assertTrue(!r3.contains(r1));
	        assertTrue(!r1.contains(r4));
	        assertTrue(!r4.contains(r1));
	    }

	    public function testContainsPoint(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(0, 0, 10, 10);
	        assertTrue(r1.containsPoint(Point.makeXY(0,0)));
	        assertTrue(r1.containsPoint(Point.makeXY(10, 10)));
	        assertTrue(!r1.containsPoint(Point.makeXY(100, 100)));
	        assertTrue(!r1.containsPoint(Point.makeXY(3, 10.1)));
	    }

	    public function testProject(): void
	    {
	        var t: Transform = Transform.makeTranslate(10, 10).compose(
	                    Transform.makeScale(2, 2));
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(0, 0, 5, 5);
	        var r2: Rectangle = r1.project(t);
	        assertTrue(Rectangle.makeLeftTopRightBottom(10, 10, 20, 20).equals(r2));
	    }

	    public function testExtend(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(0, 0, 10, 10);
	        var r2: Rectangle = Rectangle.makeLeftTopRightBottom(5, 5, 20, 20);
	        assertTrue(
	            Rectangle.makeLeftTopRightBottom(0, 0, 20, 20).equals(
	            	r1.extend(r2)));
	        assertTrue(r1.extend(r2).equals(r2.extend(r1)));
	    }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new RectangleTest("testMakeRectangle"));
            suite.addTest(new RectangleTest("testMakeWithCorners"));
            suite.addTest(new RectangleTest("testCornerPoints"));
            suite.addTest(new RectangleTest("testOverlaps"));
            suite.addTest(new RectangleTest("testContains"));
            suite.addTest(new RectangleTest("testContainsPoint"));
            suite.addTest(new RectangleTest("testProject"));
            suite.addTest(new RectangleTest("testExtend"));
            return suite;
        }

	}
}