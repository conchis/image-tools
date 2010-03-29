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

package origami.page_dial.testing
{
	import flash.events.Event;

	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	import origami.page_dial.Outline;
	import origami.page_dial.OutlineItem;

	public class OutlineTest extends TestCase
	{
		public function OutlineTest(method: String)
		{
			super(method);
		}

		public function testItemToXML(): void
		{
			var item1: OutlineItem = new OutlineItem();
			var element1: XML = item1.toXML();
			assertEquals("item", element1.name());

			var item2: OutlineItem = new OutlineItem("one");
			var element2: XML = item2.toXML();
			assertEquals("one", element2.@id);

			var item3: OutlineItem = new OutlineItem("one", "A Title");
			var element3: XML = item3.toXML();
			assertEquals("A Title", element3.@title);

			var item4: OutlineItem = new OutlineItem("one", "A Title", "resource.jpg");
			var element4: XML = item4.toXML();
			assertEquals("resource.jpg", element4.@resource);
		}

		public function testItemFromXML(): void
		{
			var xml: XML = new XML(
				"<item id='id1' title='title2' resource='resource3'>\n" +
				"	<item id='child_id1' title='child_title2' resource='child_resource3' />\n" +
				"</item>");
			var item: OutlineItem = OutlineItem.fromXML(xml);
			assertEquals("id1", item.id);
			assertEquals("title2", item.title);
			assertEquals("resource3", item.resource);

			var children: Array = item.children;
			assertEquals(1, children.length);

			var child: OutlineItem = children[0];
			assertEquals("child_id1", child.id);
			assertEquals("child_title2", child.title);
			assertEquals("child_resource3", child.resource);
		}

		private function makeOutline(): Outline
		{
			var xml: XML = new XML(
				"<outline>\n" +
				"    <item title='Shuilu Book'>\n" +
				"    	<item title='前'>\n" +
				"        	<item resource='Shuilu_book_001' title='封面正面' />\n" +
				"        	<item resource='Shuilu_book_002' title='封面反面' />\n" +
				"        	<item resource='Shuilu_book_003' title='书名页' />\n" +
				"     	</item>\n" +
				"     	<item title='照片'>\n" +
				"        	<item resource='Shuilu_book_007' title='照片 1' />\n" +
				"        	<item resource='Shuilu_book_008' title='照片 2' />\n" +
				"     	</item>\n" +
				"    </item>\n" +
				"</outline>\n"
				);
			return Outline.fromXML(xml);
		}

		public function testOutlineFromXML(): void
		{
			var outline: Outline = makeOutline();
			assertEquals("Shuilu Book", outline.root.title);
			var child: OutlineItem = outline.root.children[0];
			assertEquals("前", child.title);
		}

		public function testSelection(): void
		{
			var outline: Outline = makeOutline();
			outline.selected_index = 0;
			assertEquals(2, outline.selected_index); // Note first selectable item
			assertEquals(outline.items[outline.selected_index], outline.selected);

			outline.selected_index = 6;
			assertEquals(6, outline.selected_index);
			assertEquals(outline.items[outline.selected_index], outline.selected);
		}

		public function testEvents(): void
		{
			var caught: Boolean = false;

			var outline: Outline = makeOutline();
			outline.addEventListener(Event.CHANGE,
				function (event: Event): void { caught = true; });
			assertFalse(caught);

			// Events fired every time index changes
			outline.selected_index = 0;
			assertTrue(caught);

			// No events fired when index changes
			caught = false;
			outline.selected_index = 0;
			assertFalse(caught);
		}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();

            suite.addTest(new OutlineTest("testItemToXML"));
            suite.addTest(new OutlineTest("testItemFromXML"));
            suite.addTest(new OutlineTest("testOutlineFromXML"));
            suite.addTest(new OutlineTest("testSelection"));
            suite.addTest(new OutlineTest("testEvents"));
            return suite;
        }
 	}
}