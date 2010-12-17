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
	import origami.geometry.Point;
	import origami.geometry.Rectangle;
	import origami.geometry.Transform;

	import origami.spatial.Viewport;

	public class ViewportTest extends TestCase
	{
		private var viewport: Viewport;

		public function ViewportTest(methodName: String)
		{
			super(methodName);
		}

		public override function setUp(): void
		{
			viewport = new Viewport();
			viewport.setViewSize(Dimensions.makeWidthHeight(256, 256));
			viewport.setSceneSize(Dimensions.makeWidthHeight(1024, 1024));
		}

		public function testMakeViewport(): void
		{
			viewport.zoomReset();
			assertEquals(0.25, viewport.scale);
		}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new ViewportTest("testMakeViewport"));
            return suite;
        }

	}
}