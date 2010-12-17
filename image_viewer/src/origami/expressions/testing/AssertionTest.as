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

    import origami.expressions.Assertion;
    import origami.expressions.Bindings;

    public class AssertionTest extends TestCase
    {

        public function AssertionTest(method: String)
        {
            super(method);
        }

        public function testAccessors(): void
        {
            var ex: Assertion = new Assertion("x = 22 - 2, y = 1");
            assertEquals("x = 22 - 2, y = 1", ex.expression);

            var bindings: Bindings = new Bindings();
            ex.fn(bindings);
            assertEquals(20, bindings.get("x"));
            assertEquals(1, bindings.get("y"));
        }

        public function testExecute(): void
        {
            var ex: Assertion = new Assertion("x = 22 - 2, y = 1");
            var bindings: Bindings = new Bindings();
            ex.execute(bindings);
            assertEquals(20, bindings.get("x"));
            assertEquals(1, bindings.get("y"));
        }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new AssertionTest("testAccessors"));
            suite.addTest(new AssertionTest("testExecute"));
            return suite;
        }

    }

}