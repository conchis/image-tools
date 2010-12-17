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

    import origami.geometry.Dimensions;
    import origami.geometry.Point;
    import origami.geometry.Transform;

	// Test the Point class

	public class PointTest extends TestCase
	{

	    public function PointTest(method: String)
	    {
	        super(method);
	    }

	    private function assertApprox(value_a: Number, value_b: Number): void
	    {
	    	assertEquals(Math.round(value_a * 100000), Math.round(value_b * 100000));
	    }

	    public function testMakePoint(): void
	    {
	        var p1: Point = Point.makeXY(3, 4);
	        assertEquals(3, p1.x);
	        assertEquals(4, p1.y);
	        assertEquals(5, p1.distance);
	        var p2: Point = Point.makeAngleDistance(p1.angle, p1.distance);
	        assertEquals(300, Math.round(p2.x * 100));
	        assertEquals(400, Math.round(p2.y * 100));
	    }

	    public function testEquals(): void
	    {
	        var p1: Point = Point.makeXY(3, 4);
	        assertTrue(p1.equals(Point.makeXY(3, 4)));
	        assertFalse(p1.equals(Point.makeXY(3, 2)));
	        assertFalse(p1.equals(Point.makeXY(2, 4)));
	    }

	    public function testAddPoint(): void
	    {
	        var p1: Point = Point.makeXY(2, 2);
	        var p2: Point = Point.makeXY(1, 2);
	        var p3: Point = p1.addPoint(p2);
	        assertEquals(3, p3.x);
	        assertEquals(4, p3.y);
	    }

	    public function testPolar(): void
	    {
	        assertApprox(              0, Point.makeXY( 0,   0).angle);
	        assertApprox(    Math.PI / 2, Point.makeXY( 0,  10).angle);
	        assertApprox(              0, Point.makeXY(10,   0).angle);
	        assertApprox(3 * Math.PI / 2, Point.makeXY( 0, -10).angle);
	        assertApprox(    Math.PI / 4, Point.makeXY( 1,   1).angle);
	        assertApprox(3 * Math.PI / 4, Point.makeXY(-1,   1).angle);
	        assertApprox(5 * Math.PI / 4, Point.makeXY(-1,  -1).angle);
	        assertApprox(7 * Math.PI / 4, Point.makeXY( 1,  -1).angle);
	    }

	    public function testSubtractPoint(): void
	    {
	        var p1: Point = Point.makeXY(4, 6);
	        var p2: Point = Point.makeXY(1, 2);
	        var d1: Dimensions = p1.subtractPoint(p2);
	        assertEquals(3, d1.width);
	        assertEquals(4, d1.height);
	    }

	    public function testDistanceTo(): void
	    {
	        var p1: Point = Point.makeXY(0, 0);
	        assertEquals(0, p1.distanceTo(Point.makeXY( 0,  0)));
	        assertEquals(5, p1.distanceTo(Point.makeXY( 5,  0)));
	        assertEquals(8, p1.distanceTo(Point.makeXY( 0,  8)));
	        assertEquals(5, p1.distanceTo(Point.makeXY( 3,  4)));
	        assertEquals(5, p1.distanceTo(Point.makeXY(-3,  4)));
	        assertEquals(5, p1.distanceTo(Point.makeXY( 3, -4)));
	        assertEquals(5, p1.distanceTo(Point.makeXY(-3, -4)));
	    }

	    public function testAngleTo(): void
	    {
	        var p1: Point = Point.makeXY(0, 0);
	        assertApprox(              0, p1.angleTo(Point.makeXY(0,   0)));
	        assertApprox(    Math.PI / 2, p1.angleTo(Point.makeXY(0,  10)));
	        assertApprox(              0, p1.angleTo(Point.makeXY(10,  0)));
	        assertApprox(3 * Math.PI / 2, p1.angleTo(Point.makeXY(0, -10)));
	        assertApprox(    Math.PI / 4, p1.angleTo(Point.makeXY(1,   1)));
	        assertApprox(3 * Math.PI / 4, p1.angleTo(Point.makeXY(-1,  1)));
	        assertApprox(5 * Math.PI / 4, p1.angleTo(Point.makeXY(-1, -1)));
	        assertApprox(7 * Math.PI / 4, p1.angleTo(Point.makeXY( 1, -1)));
	    }

	    public function testProject(): void
	    {
	        var t: Transform = Transform.makeTranslate(10, 10).compose(
	                    Transform.makeScale(2, 2));
	        var p1: Point = Point.makeXY(5, 5);
	        assertTrue(Point.makeXY(20, 20).equals(p1.project(t)));
	    }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new PointTest("testMakePoint"));
            suite.addTest(new PointTest("testEquals"));
            suite.addTest(new PointTest("testAddPoint"));
            suite.addTest(new PointTest("testPolar"));
            suite.addTest(new PointTest("testSubtractPoint"));
            suite.addTest(new PointTest("testDistanceTo"));
            suite.addTest(new PointTest("testAngleTo"));
            suite.addTest(new PointTest("testProject"));
            return suite;
        }

	}
}
