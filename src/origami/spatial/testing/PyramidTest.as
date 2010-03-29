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

package origami.spatial.testing
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import origami.geometry.Dimensions;
    import origami.geometry.Rectangle;
    import origami.spatial.Pyramid;

	public class PyramidTest extends TestCase
	{

		public function PyramidTest(method: String)
		{
			super(method);
		}

	    private function assertApprox(value_a: Number, value_b: Number): void
	    {
	    	assertEquals(Math.round(value_a * 100000), Math.round(value_b * 100000));
	    }

		private function makeTestPyramid(): Pyramid
		{
			var image_size: Dimensions = Dimensions.makeWidthHeight(8 * 128, 8 * 128);
			var tile_size: Dimensions = Dimensions.makeWidthHeight(128, 128);
			return new Pyramid(image_size, tile_size);
		}

		public function testMakePyramid(): void
		{
			var p: Pyramid = makeTestPyramid();
			var image_size: Dimensions = Dimensions.makeWidthHeight(8 * 128, 8 * 128);
			assertTrue(Dimensions.makeWidthHeight(128, 128).equals(p.tile_size));
			assertApprox(Math.SQRT2, p.resolution_multiplier);
			assertTrue(image_size.equals(p.image_size));
		}

		public function testLayerCount(): void
		{
			var p1: Pyramid = new Pyramid(Dimensions.makeWidthHeight(8 * 128, 8 * 128),
				Dimensions.makeWidthHeight(128, 128));
			assertEquals(7, p1.layer_count);
		}

		public function testLayerForScale(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertEquals(6, p.layerForScale(1));
			assertEquals(4, p.layerForScale(1/2));
			assertEquals(2, p.layerForScale(1/4));
			assertEquals(0, p.layerForScale(1/8));

			assertEquals(6, p.layerForScale(0.90));
			assertEquals(6, p.layerForScale(0.72));
			assertEquals(5, p.layerForScale(0.70));

			assertEquals(0, p.layerForScale(1/8.1));
			assertEquals(0, p.layerForScale(1/32));
		}

		public function testScaleForLayer(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertApprox(1,   p.scaleForLayer(6));
			assertApprox(1/2, p.scaleForLayer(4));
			assertApprox(1/4, p.scaleForLayer(2));
			assertApprox(1/8, p.scaleForLayer(0));
		}

		public function testTileExtent(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertTrue(Dimensions.makeWidthHeight(128, 128).equals(p.tileExtent(6)));
			assertTrue(Dimensions.makeWidthHeight(256, 256).equals(p.tileExtent(4)));
			assertTrue(Dimensions.makeWidthHeight(512, 512).equals(p.tileExtent(2)));
		}

		public function testGridSize(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertTrue(Dimensions.makeWidthHeight(8, 8).equals(p.tileGridSize(6)));
			assertTrue(Dimensions.makeWidthHeight(4, 4).equals(p.tileGridSize(4)));
			assertTrue(Dimensions.makeWidthHeight(2, 2).equals(p.tileGridSize(2)));
		}

		public function testSourceRectangle(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertTrue(
				Rectangle.makeLeftTopWidthHeight(0, 0, 128, 128).equals(
				p.tileSourceRectangle(0, 0, 6)));
			assertTrue(
				Rectangle.makeLeftTopWidthHeight(256, 256, 256, 256).equals(
				p.tileSourceRectangle(1, 1, 4)));
			assertTrue(
				Rectangle.makeLeftTopWidthHeight(1024, 1024, 512, 512).equals(
				p.tileSourceRectangle(2, 2, 2)));
		}

		public function testTileColumn(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertEquals(0, p.tileColumn(0, 6));
			assertEquals(0, p.tileColumn(127, 6));
			assertEquals(1, p.tileColumn(128, 6));
			assertEquals(7, p.tileColumn(8 * 128 - 1, 6));

			assertEquals(0, p.tileColumn(0, 4));
			assertEquals(0, p.tileColumn(2 * 128 - 1, 4));
			assertEquals(1, p.tileColumn(2 * 128 + 1, 4));
			assertEquals(3, p.tileColumn(8 * 128 - 1, 4));
		}

		public function testTileRow(): void
		{
			var p: Pyramid = makeTestPyramid();
			assertEquals(0, p.tileRow(0, 6));
			assertEquals(0, p.tileRow(127, 6));
			assertEquals(1, p.tileRow(128, 6));
			assertEquals(7, p.tileRow(8 * 128 - 1, 6));

			assertEquals(0, p.tileRow(0, 4));
			assertEquals(0, p.tileRow(2 * 128 - 1, 4));
			assertEquals(1, p.tileRow(2 * 128 + 1, 4));
			assertEquals(3, p.tileRow(8 * 128 - 1, 4));
		}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new PyramidTest("testMakePyramid"));
            suite.addTest(new PyramidTest("testLayerCount"));
            suite.addTest(new PyramidTest("testLayerForScale"));
            suite.addTest(new PyramidTest("testScaleForLayer"));
            suite.addTest(new PyramidTest("testTileExtent"));
            suite.addTest(new PyramidTest("testGridSize"));
            suite.addTest(new PyramidTest("testSourceRectangle"));
            suite.addTest(new PyramidTest("testTileColumn"));
            suite.addTest(new PyramidTest("testTileRow"));
            return suite;
        }
	}

}
