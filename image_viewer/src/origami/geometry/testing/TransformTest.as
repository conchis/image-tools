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
    import origami.geometry.Transform;

	public class TransformTest extends TestCase
	{
	    function TransformTest(method: String)
	    {
	        super(method);
	    }

	    private function assertApprox(value_a: Number, value_b: Number): void
	    {
	    	assertEquals(Math.round(value_a * 100000), Math.round(value_b * 100000));
	    }

	    public function testIdentity(): void
	    {
	        var t: Transform = Transform.makeIdentity();
	        assertTrue(Point.makeXY(6, 11).equals(t.project(Point.makeXY(6, 11))));
	        assertTrue(Point.makeXY(10, 10).equals(t.project(Point.makeXY(10, 10))));
	        assertTrue(Point.makeXY(0, 0).equals(t.project(Point.makeXY(0, -0))));
	    }

	    public function testTranslate(): void
	    {
	        var t: Transform = Transform.makeTranslate(5, 10);
	        assertTrue(Point.makeXY(6, 11).equals(t.project(Point.makeXY(1, 1))));
	        assertTrue(Point.makeXY(10, 10).equals(t.project(Point.makeXY(5, 0))));
	        assertTrue(Point.makeXY(0, 0).equals(t.project(Point.makeXY(-5, -10))));
	    }

	    public function testScale(): void
	    {
	        var t1: Transform = Transform.makeScale(0.5, 0.5);
	        assertTrue(Point.makeXY(5, 5).equals(t1.project(Point.makeXY(10, 10))));
	        var t2: Transform = Transform.makeScale(0.5, 1.0);
	        assertTrue(Point.makeXY(5, 10).equals(t2.project(Point.makeXY(10, 10))));
	        var t3: Transform = Transform.makeScale(2, 2);
	        assertTrue(Point.makeXY(20, 20).equals(t3.project(Point.makeXY(10, 10))));
	    }

	    public function testRotate(): void
	    {
	        var t1: Transform = Transform.makeRotate(Math.PI / 2);
	        var p2: Point = t1.project(Point.makeXY(2, 0));
	        assertApprox(0, p2.x);
	        assertApprox(2, p2.y);
	        var t2: Transform = Transform.makeRotate(Math.PI);
	        var p3: Point = t2.project(Point.makeXY(2, 0));
	        assertApprox(-2, p3.x);
	        assertApprox( 0, p3.y);
	    }

	    public function testCompose1(): void
	    {
	        var t1: Transform = Transform.makeTranslate(1, 1);
	        var t2: Transform = Transform.makeTranslate(4, 5);
	        var t3: Transform = t1.compose(t2);
	        assertTrue(Point.makeXY(10, 10).equals(t3.project(Point.makeXY(5, 4))));
	    }

	    public function testCompose2(): void
	    {
	        var t1: Transform = Transform.makeRotate(Math.PI / 2);
	        var t2: Transform = Transform.makeTranslate(1, 1);
	        var t3: Transform = t1.compose(t2);
	        var p1: Point = t3.project(Point.makeXY(5, 0));
	        assertApprox(-1, p1.x);
	        assertApprox( 6, p1.y);
	    }

	    public function testCompose3(): void
	    {
	        var t1: Transform = Transform.makeTranslate(1, 1);
	        var t2: Transform = Transform.makeRotate(Math.PI / 2);
	        var t3: Transform = t1.compose(t2);
	        var p1: Point = t3.project(Point.makeXY(5, 0));
	        assertApprox(1, p1.x);
	        assertApprox(6, p1.y);
	    }

	    public function testInverse1(): void
	    {
	        var t1: Transform = Transform.makeTranslate(1, 1);
	        var t2: Transform = t1.inverse();
	        var p1: Point = Point.makeXY(3, 4);
	        var p2: Point = t2.project(t1.project(p1));
	        assertApprox(p1.x, p2.x);
	        assertApprox(p1.y, p2.y);
	    }

	    public function testInverse2(): void
	    {
	        var t1: Transform = Transform.makeRotate(Math.PI / 3);
	        var t2: Transform = t1.inverse();
	        var p1: Point = Point.makeXY(3, 4);
	        var p2: Point = t2.project(t1.project(p1));
	        assertApprox(p1.x, p2.x);
	        assertApprox(p1.y, p2.y);
	    }

	    public function testInverse3(): void
	    {
	        var t1: Transform = Transform.makeRotate(
	                Math.PI / 3).compose(
	                        Transform.makeTranslate(4, 3));
	        var t2: Transform = t1.inverse();
	        var p1: Point = Point.makeXY(3, 4);
	        var p2: Point = t2.project(t1.project(p1));
	        assertApprox(p1.x, p2.x);
	        assertApprox(p1.y, p2.y);
	    }

	    public function testInverse4(): void
	    {
	        var t1: Transform = Transform.makeScale(0.5, 0.25);
	        var t2: Transform = t1.inverse();
	        var p1: Point = Point.makeXY(3, 4);
	        var p2: Point = t2.project(t1.project(p1));
	        assertApprox(p1.x, p2.x);
	        assertApprox(p1.y, p2.y);
	    }

	    public function testEqual(): void
	    {
	        var t1: Transform = Transform.makeTranslate(1, 1);
	        var t2: Transform = Transform.makeTranslate(1, 1);
	        var t3: Transform = Transform.makeTranslate(1, 0);
	        var t4: Transform = Transform.makeScale(2, 2);
	        var t5: Transform = Transform.makeScale(2, 2);
	        assertTrue(t1.equals(t1));
	        assertTrue(t1.equals(t2));
	        assertTrue(t2.equals(t1));
	        assertFalse(t1.equals(t3));
	        assertTrue(t4.equals(t5));
	        assertFalse(t4.equals(t1));
	     }

	     public function testRotateAround(): void
	     {
	     	var t1: Transform = Transform.makeRotateAround(-Math.PI / 2, Point.makeXY(1, 0));
	        var p1: Point = Point.makeXY(1, 1).project(t1);
	        assertApprox(2, p1.x);
	        assertApprox(0, p1.y);
	     	var t2: Transform = Transform.makeRotateAround(Math.PI / 2, Point.makeXY(0, 1));
	        var p2: Point = Point.makeXY(1, 1).project(t2);
	        assertApprox(0, p2.x);
	        assertApprox(2, p2.y);
	     }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new TransformTest("testIdentity"));
            suite.addTest(new TransformTest("testTranslate"));
            suite.addTest(new TransformTest("testScale"));
            suite.addTest(new TransformTest("testRotate"));
            suite.addTest(new TransformTest("testCompose1"));
            suite.addTest(new TransformTest("testCompose2"));
            suite.addTest(new TransformTest("testCompose3"));
            suite.addTest(new TransformTest("testInverse1"));
            suite.addTest(new TransformTest("testInverse2"));
            suite.addTest(new TransformTest("testInverse3"));
            suite.addTest(new TransformTest("testInverse4"));
            suite.addTest(new TransformTest("testEqual"));
            suite.addTest(new TransformTest("testRotateAround"));
            return suite;
        }

	}
}