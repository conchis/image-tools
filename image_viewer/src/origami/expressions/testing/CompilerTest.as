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

    import origami.expressions.Compiler;
    import origami.expressions.SyntaxError;

    import origami.expressions.Bindings;

    public class CompilerTest extends TestCase
    {

    	private static var c: Compiler = new Compiler();

    	public function CompilerTest(method: String)
        {
            super(method);
        }

    	public function testNumber(): void
    	{
    		var f: Function = c.compileExpression("22");
    		assertEquals(22, f(new Bindings()));
    	}

    	public function testBoolean(): void
    	{
    		var f: Function = c.compileExpression("true");
    		assertTrue(f(new Bindings()));
    		f = c.compileExpression("false");
    		assertFalse(f(new Bindings()));
    	}

    	public function testVariable(): void
    	{
    		var f: Function = c.compileExpression("xyz");
    		assertEquals(34, f(new Bindings({xyz: 34, abc: 84})));
    		assertEquals(99, f(new Bindings({abc: 60, xyz: 99})));
    	}

    	public function testVariable2(): void
    	{
    		var f: Function = c.compileExpression("xyz");
    		assertEquals(34, f(new Bindings({xyz: 34, abc: 84})));
    		assertEquals(99, f(new Bindings({abc: 60, xyz: 99})));
    	}

    	public function testFieldAccess1(): void
    	{
    		var f1: Function = c.compileExpression("a.b");
    		assertEquals(7, f1(new Bindings({a: {b: 7, c: 8}})));

    		var f2: Function = c.compileExpression("a.b.c");
    		assertEquals(32, f2(new Bindings({a: {b: {c: 32, d: 23}}, c: 8})));
    	}

    	public function testFieldAccess2(): void
    	{
    		var f1: Function = c.compileExpression("a.b");
    		assertEquals(7, f1(new Bindings({a: {b: 7, c: 8}})));

    		var f2: Function = c.compileExpression("a.b.c");
    		assertEquals(32, f2(new Bindings({a: {b: new Bindings({c: 32, d: 23})}, c: 8})));
    	}

    	public function testMethodCall1(): void
    	{
    		var f1: Function = c.compileExpression("a.size()");
    		assertEquals(7, f1(new Bindings({a: { size: function(): Object { return 7; }}})));

    		var f2: Function = c.compileExpression("a.height(2 + 2)");
    		assertEquals(8, f2(new Bindings({a: { height:
    				function(arg: int): Object { return 2 * arg; }}})));

    		var f3: Function = c.compileExpression("a.height(2, 4)");
    		assertEquals(9, f3(new Bindings({a: { height:
    				function(a1: int, a2: int): Object {
    					return a1 * a2 + 1; }}})));
    	}

    	public function testTerm1(): void
    	{
    		var f: Function = c.compileExpression("2 * 3");
    		assertEquals(6, f(new Bindings()));
    	}

    	public function testTerm2(): void
    	{
    		var f: Function = c.compileExpression("2 * 3 * 4");
    		assertEquals(24, f(new Bindings()));
    	}

    	public function testTerm3(): void
    	{
    		var f: Function = c.compileExpression("8 / 2");
    		assertEquals(4, f(new Bindings()));
    	}

    	public function testTerm4(): void
    	{
    		var f: Function = c.compileExpression("8 / 2 * 2");
    		assertEquals(8, f(new Bindings()));
    	}

    	public function testTerm5(): void
    	{
    		var f: Function = c.compileExpression("8 * 8 / 2");
    		assertEquals(32, f(new Bindings()));
    	}

    	public function testArithmetic1(): void
    	{
    		var f: Function = c.compileExpression("2 + 3");
    		assertEquals(5, f(new Bindings()));
    	}

    	public function testArithmetic2(): void
    	{
    		var f: Function = c.compileExpression("2 + 3 + 4");
    		assertEquals(9, f(new Bindings()));
    	}

    	public function testArithmetic3(): void
    	{
    		var f: Function = c.compileExpression("8 - 6");
    		assertEquals(2, f(new Bindings()));
    	}

    	public function testArithmetic4(): void
    	{
    		var f: Function = c.compileExpression("8 - 6 - 2");
    		assertEquals(0, f(new Bindings()));
    	}

    	public function testArithmetic5(): void
    	{
    		var f: Function = c.compileExpression("8 - 6 + 2");
    		assertEquals(4, f(new Bindings()));
    	}

    	public function testArithmetic6(): void
    	{
    		var f: Function = c.compileExpression("8 + 2 - 10");
    		assertEquals(0, f(new Bindings()));
    	}

    	public function testArithmetic7(): void
    	{
    		var f: Function = c.compileExpression("-5");
    		assertEquals(-5, f(new Bindings()));
    	}

    	public function testArithmetic8(): void
    	{
    		var f: Function = c.compileExpression("-5 + 5");
    		assertEquals(0, f(new Bindings()));
    	}

    	public function testArithmetic9(): void
    	{
    		var f: Function = c.compileExpression("2 * 3 + 4");
    		assertEquals(10, f(new Bindings()));
    	}

    	public function testArithmetic10(): void
    	{
    		var f: Function = c.compileExpression("4 + 3 * 2");
    		assertEquals(10, f(new Bindings()));
    	}

    	public function testArithmetic11(): void
    	{
    		var f: Function = c.compileExpression("(4 + 3) * 2");
    		assertEquals(14, f(new Bindings()));
    	}

    	public function testArithmetic12(): void
    	{
    		var f: Function = c.compileExpression("(((4)))");
    		assertEquals(4, f(new Bindings()));
    	}

    	public function testArithmetic13(): void
    	{
    		var f: Function = c.compileExpression("(4 - 5) + (3 * 2)");
    		assertEquals(5, f(new Bindings()));
    	}

    	public function testArithmetic14(): void
    	{
    		var f: Function = c.compileExpression("-(4 - 5)");
    		assertEquals(1, f(new Bindings()));
    	}

    	public function testRelation1(): void
    	{
    		var f: Function = c.compileExpression("3 > 2");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation2(): void
    	{
    		var f: Function = c.compileExpression("2 > 3");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation3(): void
    	{
    		var f: Function = c.compileExpression("4 >= 4");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation4(): void
    	{
    		var f: Function = c.compileExpression("5 >= 4");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation5(): void
    	{
    		var f: Function = c.compileExpression("4 >= 5");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation6(): void
    	{
    		var f: Function = c.compileExpression("2 < 3");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation7(): void
    	{
    		var f: Function = c.compileExpression("3 < 2");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation8(): void
    	{
    		var f: Function = c.compileExpression("4 <= 4");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation9(): void
    	{
    		var f: Function = c.compileExpression("4 <= 5");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation10(): void
    	{
    		var f: Function = c.compileExpression("5 <= 4");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation11(): void
    	{
    		var f: Function = c.compileExpression("5 == 5");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation12(): void
    	{
    		var f: Function = c.compileExpression("4 == 5");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation13(): void
    	{
    		var f: Function = c.compileExpression("5 != 3");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation14(): void
    	{
    		var f: Function = c.compileExpression("4 != 4");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation15(): void
    	{
    		var f: Function = c.compileExpression("3 + 1 == 5 - 1");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation16(): void
    	{
    		var f: Function = c.compileExpression("3 + 1 == 5 - 2");
    		assertFalse(f(new Bindings()));
    	}

    	public function testRelation17(): void
    	{
    		var f: Function = c.compileExpression("4 * 5 == 10 * 2");
    		assertTrue(f(new Bindings()));
    	}

    	public function testRelation18(): void
    	{
    		var f: Function = c.compileExpression("4 * 5 == 11 * 2");
    		assertFalse(f(new Bindings()));
    	}

    	public function testNegate1(): void
    	{
    		var f: Function = c.compileExpression("not true");
    		assertFalse(f(new Bindings()));
    	}

    	public function testNegate2(): void
    	{
    		var f: Function = c.compileExpression("not false");
    		assertTrue(f(new Bindings()));
    	}

    	public function testNegate3(): void
    	{
    		var f: Function = c.compileExpression("not 2 < 3");
    		assertFalse(f(new Bindings()));
    	}

    	public function testNegate4(): void
    	{
    		var f: Function = c.compileExpression("not 3 < 2");
    		assertTrue(f(new Bindings()));
    	}

    	public function testConjuct1(): void
    	{
    		var f: Function = c.compileExpression("true || false");
    		assertTrue(f(new Bindings()));
    	}

    	public function testConjuct2(): void
    	{
    		var f: Function = c.compileExpression("false || false");
    		assertFalse(f(new Bindings()));
    	}

    	public function testConjuct3(): void
    	{
    		var f: Function = c.compileExpression("3 < 2 || 6 > 7");
    		assertFalse(f(new Bindings()));
    	}

    	public function testConjuct4(): void
    	{
    		var f: Function = c.compileExpression("3 > 2 || 2 > 3");
    		assertTrue(f(new Bindings()));
    	}

    	public function testConjuct5(): void
    	{
    		var f: Function = c.compileExpression("2 > 3 || 3 > 2 ");
    		assertTrue(f(new Bindings()));
    	}

    	public function testDisjunct1(): void
    	{
    		var f: Function = c.compileExpression("true && true");
    		assertTrue(f(new Bindings()));
    	}

    	public function testDisjunct2(): void
    	{
    		var f: Function = c.compileExpression("true && false");
    		assertFalse(f(new Bindings()));
    	}

    	public function testDisjunct3(): void
    	{
    		var f: Function = c.compileExpression("false && true");
    		assertFalse(f(new Bindings()));
    	}

    	public function testDisjunct4(): void
    	{
    		var f: Function = c.compileExpression("false && false");
    		assertFalse(f(new Bindings()));
    	}

    	public function testAssert1(): void
    	{
    		var f: Function = c.compileAssertion("p");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		assertTrue(Boolean(bindings.get("p")));
    	}

    	public function testAssert2(): void
    	{
    		var f: Function = c.compileAssertion("!p");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		assertFalse(Boolean(bindings.get("p")));
    	}

       public function testAssert3(): void
    	{
    		var f: Function = c.compileAssertion("p && q");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		assertTrue(Boolean(bindings.get("p")));
    		assertTrue(Boolean(bindings.get("q")));
    	}

    	public function testAssert4(): void
    	{
    		var f: Function = c.compileAssertion("p and q and not r and s");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		assertTrue(Boolean(bindings.get("p")));
    		assertTrue(Boolean(bindings.get("q")));
    		assertFalse(Boolean(bindings.get("r")));
    		assertTrue(Boolean(bindings.get("s")));
    	}

    	public function testAssert5(): void
    	{
    		var f: Function = c.compileAssertion("p , q , not r , s");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		assertTrue(Boolean(bindings.get("p")));
    		assertTrue(Boolean(bindings.get("q")));
    		assertFalse(Boolean(bindings.get("r")));
    		assertTrue(Boolean(bindings.get("s")));
    	}

    	public function testAssertEquals1(): void
    	{
    		var f: Function = c.compileAssertion("x == 22");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(22, bindings.get("x"));
    	}

    	public function testAssertEquals2(): void
    	{
    		var f: Function = c.compileAssertion("y = 10");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(10, bindings.get("y"));
    	}

    	public function testAssertEquals3(): void
    	{
    		var f: Function = c.compileAssertion("z := 12");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testAssertEquals4(): void
    	{
    		var f: Function = c.compileAssertion("x == 22 && y == 10 && z == 12");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(22, bindings.get("x"));
    		assertEquals(10, bindings.get("y"));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testAssertEquals5(): void
    	{
    		var f: Function = c.compileAssertion("x = 22 and y = 10 and z = 12");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(22, bindings.get("x"));
    		assertEquals(10, bindings.get("y"));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testAssertEquals6(): void
    	{
    		var f: Function = c.compileAssertion("x := 22, y := 10, z := 12");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(22, bindings.get("x"));
    		assertEquals(10, bindings.get("y"));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testAssertEquals7(): void
    	{
    		var f: Function = c.compileAssertion(
    			"x = 11 * 2, y = 2 * (3 + 2), z = 3 + 3 + 3 + 3");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals(22, bindings.get("x"));
    		assertEquals(10, bindings.get("y"));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testAssertEquals8(): void
    	{
    		var f: Function = c.compileAssertion("x := 2, y := x * 2, z := y * 3");
    		var bindings: Bindings = new Bindings();
    		f(bindings);
    		//trace(asString(bindings));
    		assertEquals( 2, bindings.get("x"));
    		assertEquals( 4, bindings.get("y"));
    		assertEquals(12, bindings.get("z"));
    	}

    	public function testSyntax1(): void
    	{
    		try
    		{
    			var f: Function = c.compileExpression("123 sowhat is this");
    			assertFalse(true);
    		}
    		catch (except: origami.expressions.SyntaxError)
    		{
    		}
    	}

    	public function testSyntax2(): void
    	{
    		try
    		{
    			var f: Function = c.compileExpression("#2");
    			assertFalse(true);
    		}
    		catch (except: origami.expressions.SyntaxError)
    		{
    		}
    	}

    	public function testSyntax3(): void
    	{
    		try
    		{
    			var f: Function = c.compileExpression("&2");
    			assertFalse(true);
    		}
    		catch (except: origami.expressions.SyntaxError)
    		{
    		}
    	}

        public static function suite(): TestSuite
        {
            var suite: TestSuite = new TestSuite();
            suite.addTest(new CompilerTest("testNumber"));
            suite.addTest(new CompilerTest("testBoolean"));
            suite.addTest(new CompilerTest("testVariable"));
            suite.addTest(new CompilerTest("testVariable2"));
            suite.addTest(new CompilerTest("testFieldAccess1"));
            suite.addTest(new CompilerTest("testFieldAccess2"));
            suite.addTest(new CompilerTest("testMethodCall1"));
            suite.addTest(new CompilerTest("testTerm1"));
            suite.addTest(new CompilerTest("testTerm2"));
            suite.addTest(new CompilerTest("testTerm3"));
            suite.addTest(new CompilerTest("testTerm4"));
            suite.addTest(new CompilerTest("testTerm5"));
            suite.addTest(new CompilerTest("testArithmetic1"));
            suite.addTest(new CompilerTest("testArithmetic2"));
            suite.addTest(new CompilerTest("testArithmetic3"));
            suite.addTest(new CompilerTest("testArithmetic4"));
            suite.addTest(new CompilerTest("testArithmetic5"));
            suite.addTest(new CompilerTest("testArithmetic6"));
            suite.addTest(new CompilerTest("testArithmetic7"));
            suite.addTest(new CompilerTest("testArithmetic8"));
            suite.addTest(new CompilerTest("testArithmetic9"));
            suite.addTest(new CompilerTest("testArithmetic10"));
            suite.addTest(new CompilerTest("testArithmetic11"));
            suite.addTest(new CompilerTest("testArithmetic12"));
            suite.addTest(new CompilerTest("testArithmetic13"));
            suite.addTest(new CompilerTest("testArithmetic14"));
            suite.addTest(new CompilerTest("testRelation2"));
            suite.addTest(new CompilerTest("testRelation3"));
            suite.addTest(new CompilerTest("testRelation4"));
            suite.addTest(new CompilerTest("testRelation5"));
            suite.addTest(new CompilerTest("testRelation6"));
            suite.addTest(new CompilerTest("testRelation7"));
            suite.addTest(new CompilerTest("testRelation8"));
            suite.addTest(new CompilerTest("testRelation9"));
            suite.addTest(new CompilerTest("testRelation10"));
            suite.addTest(new CompilerTest("testRelation11"));
            suite.addTest(new CompilerTest("testRelation12"));
            suite.addTest(new CompilerTest("testRelation13"));
            suite.addTest(new CompilerTest("testRelation14"));
            suite.addTest(new CompilerTest("testRelation15"));
            suite.addTest(new CompilerTest("testRelation16"));
            suite.addTest(new CompilerTest("testRelation17"));
            suite.addTest(new CompilerTest("testRelation18"));
            suite.addTest(new CompilerTest("testNegate1"));
            suite.addTest(new CompilerTest("testNegate2"));
            suite.addTest(new CompilerTest("testNegate3"));
            suite.addTest(new CompilerTest("testNegate4"));
            suite.addTest(new CompilerTest("testConjuct1"));
            suite.addTest(new CompilerTest("testConjuct2"));
            suite.addTest(new CompilerTest("testConjuct3"));
            suite.addTest(new CompilerTest("testConjuct4"));
            suite.addTest(new CompilerTest("testConjuct5"));
            suite.addTest(new CompilerTest("testDisjunct1"));
            suite.addTest(new CompilerTest("testDisjunct2"));
            suite.addTest(new CompilerTest("testDisjunct3"));
            suite.addTest(new CompilerTest("testDisjunct4"));
            suite.addTest(new CompilerTest("testAssert1"));
            suite.addTest(new CompilerTest("testAssert2"));
            suite.addTest(new CompilerTest("testAssert3"));
            suite.addTest(new CompilerTest("testAssert4"));
            suite.addTest(new CompilerTest("testAssert5"));
            suite.addTest(new CompilerTest("testAssertEquals1"));
            suite.addTest(new CompilerTest("testAssertEquals2"));
            suite.addTest(new CompilerTest("testAssertEquals3"));
            suite.addTest(new CompilerTest("testAssertEquals4"));
            suite.addTest(new CompilerTest("testAssertEquals5"));
            suite.addTest(new CompilerTest("testAssertEquals6"));
            suite.addTest(new CompilerTest("testAssertEquals7"));
            suite.addTest(new CompilerTest("testAssertEquals8"));
            suite.addTest(new CompilerTest("testSyntax1"));
            suite.addTest(new CompilerTest("testSyntax2"));
            suite.addTest(new CompilerTest("testSyntax3"));
            return suite;
        }

    }

}