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
	import origami.geometry.Rectangle;

	// Test the Dimensions class

	public class DimensionsTest extends TestCase
	{

	    function DimensionsTest(method: String)
	    {
	        super(method);
	    }

	    public function testMakeDimensions(): void
	    {
	        var d1: Dimensions = Dimensions.makeWidthHeight(3, 4);
	        assertEquals(3, d1.width);
	        assertEquals(4, d1.height);
	    }

	    public function testEquals(): void
	    {
	        var d1: Dimensions = Dimensions.makeWidthHeight(3, 4);
	        assertTrue( d1.equals(Dimensions.makeWidthHeight(3, 4)));
	        assertFalse(d1.equals(Dimensions.makeWidthHeight(3, 2)));
	        assertFalse(d1.equals(Dimensions.makeWidthHeight(2, 4)));
	    }

	    public function testAsRectangle(): void
	    {
	    		var d1: Dimensions = Dimensions.makeWidthHeight(3, 4);
	    		var r1: Rectangle = d1.rectangle;
	    		assertEquals(0, r1.left);
	    		assertEquals(0, r1.top);
	    		assertEquals(d1.width, r1.width);
	    		assertEquals(d1.height, r1.height);
	    }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new DimensionsTest("testMakeDimensions"));
            suite.addTest(new DimensionsTest("testEquals"));
            suite.addTest(new DimensionsTest("testAsRectangle"));
            return suite;
        }

	}
}
