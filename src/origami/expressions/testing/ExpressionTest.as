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

    import origami.expressions.Expression;
    import origami.expressions.Bindings;

    public class ExpressionTest extends TestCase
    {

        public function ExpressionTest(method: String)
        {
            super(method);
        }

        public function testAccessors(): void
        {
            var ex: Expression = new Expression("x * x + 1");
            assertEquals("x * x + 1", ex.expression);
            assertEquals(10, ex.fn(new Bindings({ x: 3 })));
        }

        public function testExecute(): void
        {
            var ex: Expression = new Expression("x * x + 1");
            assertEquals(10, ex.execute(new Bindings({ x: 3 })));
        }

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new ExpressionTest("testAccessors"));
            suite.addTest(new ExpressionTest("testExecute"));
            return suite;
        }

    }

}