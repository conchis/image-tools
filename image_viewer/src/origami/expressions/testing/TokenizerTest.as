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

    import origami.expressions.Tokenizer;

    public class TokenizerTest extends TestCase
    {

    	public function TokenizerTest(method: String)
        {
            super(method);
        }

        private function isArrayEqual(array_a: Array, array_b: Array): Boolean
        {
            if (array_a.length != array_b.length)
                return false;
            for (var index: int = 0; index < array_a.length; index += 1)
            {
                if (array_a[index] != array_b[index])
                    return false;
            }
            return true;
        }

    	public function testId(): void
    	{
    		var t: Tokenizer = new Tokenizer("one two three");
    		assertEquals(Tokenizer.START_TOKEN, t.token_kind);
    		assertEquals(Tokenizer.ID_TOKEN, t.next());
    		assertEquals("one", t.token_text);
    		assertEquals(Tokenizer.ID_TOKEN, t.next());
    		assertEquals("two", t.token_text);
    		assertEquals(Tokenizer.ID_TOKEN, t.next());
    		assertEquals("three", t.token_text);
    		assertEquals(Tokenizer.END_TOKEN, t.next());
    	}

    	public function testNumber(): void
    	{
    		var t: Tokenizer = new Tokenizer("0 3.14159 1e5");
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("0", t.token_text);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("3.14159", t.token_text);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("1e5", t.token_text);
    		assertEquals(Tokenizer.END_TOKEN, t.next());
    	}

    	public function testBoolean(): void
    	{
    		var t: Tokenizer = new Tokenizer("true false");
    		assertEquals(Tokenizer.BOOLEAN_TOKEN, t.next());
    		assertEquals("true", t.token_text);
    		assertEquals(Tokenizer.BOOLEAN_TOKEN, t.next());
    		assertEquals("false", t.token_text);
    		assertEquals(Tokenizer.END_TOKEN, t.next());
    	}

    	public function testExpression(): void
    	{
    		var t: Tokenizer = new Tokenizer("(4 * 6) - 8");
    		assertEquals(Tokenizer.LPAREN_TOKEN, t.next());
    		assertEquals("(", t.token_text);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("4", t.token_text);
    		assertEquals(Tokenizer.MULOP_TOKEN, t.next());
    		assertEquals("*", t.token_text);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("6", t.token_text);
    		assertEquals(Tokenizer.RPAREN_TOKEN, t.next());
    		assertEquals(")", t.token_text);
    		assertEquals(Tokenizer.ADDOP_TOKEN, t.next());
    		assertEquals("-", t.token_text);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals("8", t.token_text);
    		assertEquals(Tokenizer.END_TOKEN, t.next());
    	}

    	public function testExpression2(): void
    	{
    		var t: Tokenizer = new Tokenizer("4 +( 7* 8)");
    		var tokens: Array = new Array();
    		while (t.next() != Tokenizer.END_TOKEN)
    			tokens.push(t.token_text);
    		assertTrue(isArrayEqual(["4", "+", "(", "7", "*", "8", ")"], tokens));
    	}

    	public function testExpression3(): void
    	{
    		var t: Tokenizer = new Tokenizer("true&&false||false&&true");
    		var tokens: Array = new Array();
    		while (t.next() != Tokenizer.END_TOKEN)
    			tokens.push(t.token_text);
    		assertTrue(isArrayEqual(["true", "&&", "false", "||", "false", "&&", "true"], tokens));
    	}

    	public function testExpression4(): void
    	{
    		var t: Tokenizer = new Tokenizer("not a and not b or c");
    		var tokens: Array = new Array();
    		while (t.next() != Tokenizer.END_TOKEN)
    			tokens.push(t.token_text);
    		assertTrue(isArrayEqual(["not", "a", "and", "not", "b", "or", "c"], tokens));
    	}

    	public function testOperators(): void
    	{
    		var t: Tokenizer = new Tokenizer("+-*/>>=<<===!=&&||!:=");
    		var tokens: Array = new Array();
    		while (t.next() != Tokenizer.END_TOKEN)
    			tokens.push(t.token_text);
    		assertTrue(isArrayEqual(["+", "-", "*", "/", ">", ">=", "<", "<=", "==", "!=",
    				"&&", "||", "!", ":="], tokens));
    	}

    	public function testIdentifiers(): void
    	{
    		var t: Tokenizer = new Tokenizer("(a1,b_2,c__2,a1b2c3, x____)");
    		var tokens: Array = new Array();
    		while (t.next() != Tokenizer.END_TOKEN)
    			tokens.push(t.token_text);
    		assertTrue(isArrayEqual(["(", "a1", ",", "b_2", ",", "c__2", ",", "a1b2c3", ",",
    				"x____", ")"], tokens));
    	}

    	public function testTokenBoolean(): void
    	{
    		var t: Tokenizer = new Tokenizer("true false 22");
    		assertEquals(Tokenizer.BOOLEAN_TOKEN, t.next());
    		assertTrue(t.token_boolean);
    		assertEquals(Tokenizer.BOOLEAN_TOKEN, t.next());
    		assertFalse(t.token_boolean);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertFalse(t.token_boolean);
    	}

    	public function testTokenNumber(): void
    	{
    		var t: Tokenizer = new Tokenizer("3.14159 32 10e3 false");
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals(314159, Math.round(100000 * t.token_number));
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals(32, t.token_number);
    		assertEquals(Tokenizer.NUMBER_TOKEN, t.next());
    		assertEquals(10000, t.token_number);
    		assertEquals(Tokenizer.BOOLEAN_TOKEN, t.next());
    		assertEquals(0, t.token_boolean);
    	}

    	public function testTokenString(): void
    	{
    		var t1: Tokenizer = new Tokenizer("\"one two three\"");
    		assertEquals(Tokenizer.STRING_TOKEN, t1.next());
    		assertEquals("one two three", t1.token_string);

    		var t2: Tokenizer = new Tokenizer("'one two three'");
    		assertEquals(Tokenizer.STRING_TOKEN, t2.next());
    		assertEquals("one two three", t1.token_string);

    		var t3: Tokenizer = new Tokenizer("\"one two\\\"three\"");
    		assertEquals(Tokenizer.STRING_TOKEN, t3.next());
    		assertEquals("one two\"three", t3.token_string);

    		var t4: Tokenizer = new Tokenizer("\'one two\\\'three\'");
    		assertEquals(Tokenizer.STRING_TOKEN, t4.next());
    		assertEquals("one two\'three", t4.token_string);
    	}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new TokenizerTest("testId"));
            suite.addTest(new TokenizerTest("testNumber"));
            suite.addTest(new TokenizerTest("testBoolean"));
            suite.addTest(new TokenizerTest("testExpression"));
            suite.addTest(new TokenizerTest("testExpression2"));
            suite.addTest(new TokenizerTest("testExpression3"));
            suite.addTest(new TokenizerTest("testExpression4"));
            suite.addTest(new TokenizerTest("testOperators"));
            suite.addTest(new TokenizerTest("testIdentifiers"));
            suite.addTest(new TokenizerTest("testOperators"));
            suite.addTest(new TokenizerTest("testTokenNumber"));
            suite.addTest(new TokenizerTest("testTokenBoolean"));
            suite.addTest(new TokenizerTest("testTokenString"));
            return suite;
        }
    }

}
