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

package origami.expressions.testing
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import origami.expressions.Template;
    import origami.expressions.Bindings;

    public class TemplateTest extends TestCase
    {

    	public function  TemplateTest(method: String)
        {
            super(method);
        }

    	public function testToString(): void
    	{
    		var t: Template = new Template("one {two} three");
    		assertEquals("one {two} three", t.toString());
    	}

    	public function testConstants(): void
    	{
    		var bind: Bindings = new Bindings({xyz: 34, abc: 84});
    		var t: Template = new Template("one two");
    		assertEquals("one two", t.expand(bind));
    	}

    	public function testExpandVariable(): void
    	{
    		var bind: Bindings = new Bindings({xyz: 34, abc: 84});
    		var t: Template = new Template("before {xyz} after");
    		assertEquals("before 34 after", t.expand(bind));
    	}

    	public function testExpandExpression(): void
    	{
    		var bind: Bindings = new Bindings({xyz: 34, abc: 84});
    		var t: Template = new Template("before {xyz + abc} after");
    		assertEquals("before " + (34 + 84) + " after", t.expand(bind));
    	}

    	public function testExpandTwo(): void
    	{
    		var bind: Bindings = new Bindings({xyz: 34, abc: 84});
    		var t: Template = new Template("before {xyz}, {abc} after");
    		assertEquals("before 34, 84 after", t.expand(bind));
    	}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new TemplateTest("testToString"));
            suite.addTest(new TemplateTest("testConstants"));
            suite.addTest(new TemplateTest("testExpandVariable"));
            suite.addTest(new TemplateTest("testExpandExpression"));
            suite.addTest(new TemplateTest("testExpandTwo"));
            return suite;
        }
    }

}