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
    import origami.geometry.Polygon;
    import origami.geometry.Rectangle;

	// Test the Polygon class

	public class PolygonTest extends TestCase
	{

	    public function PolygonTest(method: String)
	    {
	        super(method);
	    }

	    public function testMakePolygon(): void
	    {
	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(0, 0), Point.makeXY(10, 10), Point.makeXY(0, 10));
	        assertEquals(3, p1.length);
	    }

	    public function testBounds(): void
	    {
	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(5, 0), Point.makeXY(10, 20), Point.makeXY(5, 10));
	        var b1: Rectangle = p1.bounds;
	        assertEquals( 5, b1.left);
	        assertEquals( 0, b1.top);
	        assertEquals(10, b1.right);
	        assertEquals(20, b1.bottom);
	    }

	    public function testFromRectangle(): void
	    {
	        var r1: Rectangle = Rectangle.makeLeftTopRightBottom(10, 0, 20, 10);
	        var p1: Polygon = r1.polygon;
	        assertEquals(4, p1.length);
	        var r2: Rectangle = p1.bounds;
	        assertEquals(r1.left,   r2.left);
	        assertEquals(r1.top,    r2.top);
	        assertEquals(r1.right,  r2.right);
	        assertEquals(r1.bottom, r2.bottom);
	    }

	    public function testForSegments(): void
	    {
	        var poly: Polygon = Polygon.makePoints(
	                Point.makeXY(1, 0), Point.makeXY(2, 14), Point.makeXY(3, 18), Point.makeXY(4, 24));
	    	var count: int = 0;
	    	poly.forSegments(
	    		function(p1: Point, p2: Point): void
	    		{
	    			assertEquals(count + 1, poly.points[count].x);
	    			count += 1;
	    		});
	    	assertEquals(4, count);
	    }

	    public function testClip1(): void
	    {
	    	var clip_rectangle: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 10, 10);

	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(1, 1), Point.makeXY(100, 1), Point.makeXY(100, 8), Point.makeXY(1, 8));
	        var p2: Polygon = p1.clip(clip_rectangle);
	        trace("___");
	        trace(p1)
	        trace(p2);
	        assertEquals(4, p2.points.length);
	        assertTrue(Point(p2.points[0]).equals(Point.makeXY( 1, 1)));
	        assertTrue(Point(p2.points[1]).equals(Point.makeXY(10, 1)));
	        assertTrue(Point(p2.points[2]).equals(Point.makeXY(10, 8)));
	        assertTrue(Point(p2.points[3]).equals(Point.makeXY( 1, 8)));
	    }

	    public function testClip2(): void
	    {
	    	var clip_rectangle: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 10, 10);

	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(1, 1), Point.makeXY(8, 1), Point.makeXY(8, 100), Point.makeXY(1, 100));
	        var p2: Polygon = p1.clip(clip_rectangle);
	        trace("___");
	        trace(p1)
	        trace(p2);
	        assertEquals(4, p2.points.length);
	        assertTrue(Point(p2.points[0]).equals(Point.makeXY( 1, 10)));
	        assertTrue(Point(p2.points[1]).equals(Point.makeXY( 1,  1)));
	        assertTrue(Point(p2.points[2]).equals(Point.makeXY( 8,  1)));
	        assertTrue(Point(p2.points[3]).equals(Point.makeXY( 8, 10)));
	    }

	    public function testClip3(): void
	    {
	    	var clip_rectangle: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 10, 10);

	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(1, -100), Point.makeXY(8, -100), Point.makeXY(8, 8), Point.makeXY(1, 8));
	        var p2: Polygon = p1.clip(clip_rectangle);
	        trace("___");
	        trace(p1)
	        trace(p2);
	        assertEquals(4, p2.points.length);
	        assertTrue(Point(p2.points[0]).equals(Point.makeXY( 1,  0)));
	        assertTrue(Point(p2.points[1]).equals(Point.makeXY( 8,  0)));
	        assertTrue(Point(p2.points[2]).equals(Point.makeXY( 8,  8)));
	        assertTrue(Point(p2.points[3]).equals(Point.makeXY( 1,  8)));
	    }

	    public function testClip4(): void
	    {
	    	var clip_rectangle: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 10, 10);

	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(-100, 1), Point.makeXY(8, 1), Point.makeXY(8, 8), Point.makeXY(-100, 8));
	        var p2: Polygon = p1.clip(clip_rectangle);
	        trace("___");
	        trace(p1)
	        trace(p2);
	        assertEquals(4, p2.points.length);
	        assertTrue(Point(p2.points[0]).equals(Point.makeXY( 0,  1)));
	        assertTrue(Point(p2.points[1]).equals(Point.makeXY( 8,  1)));
	        assertTrue(Point(p2.points[2]).equals(Point.makeXY( 8,  8)));
	        assertTrue(Point(p2.points[3]).equals(Point.makeXY( 0,  8)));
	    }

	    public function testClip5(): void
	    {
	    	var clip_rectangle: Rectangle = Rectangle.makeLeftTopWidthHeight(0, 0, 10, 10);

	        var p1: Polygon = Polygon.makePoints(
	                Point.makeXY(-1, -1), Point.makeXY(11, -1), Point.makeXY(11, 11), Point.makeXY(-1, 11));
	        var p2: Polygon = p1.clip(clip_rectangle);
	        trace("___");
	        trace(p1)
	        trace(p2);
	        assertEquals(4, p2.points.length);
	        assertTrue(Point(p2.points[0]).equals(Point.makeXY( 0, 10)));
	        assertTrue(Point(p2.points[1]).equals(Point.makeXY( 0,  0)));
	        assertTrue(Point(p2.points[2]).equals(Point.makeXY(10,  0)));
	        assertTrue(Point(p2.points[3]).equals(Point.makeXY(10, 10)));
	    }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new PolygonTest("testMakePolygon"));
            suite.addTest(new PolygonTest("testBounds"));
            suite.addTest(new PolygonTest("testFromRectangle"));
            suite.addTest(new PolygonTest("testForSegments"));
            suite.addTest(new PolygonTest("testClip1"));
            suite.addTest(new PolygonTest("testClip2"));
            suite.addTest(new PolygonTest("testClip3"));
            suite.addTest(new PolygonTest("testClip5"));
            return suite;
        }

	}
}