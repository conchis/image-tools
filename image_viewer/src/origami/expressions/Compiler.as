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

package origami.expressions
{

    import origami.expressions.Tokenizer;
    import origami.expressions.SyntaxError;
    import origami.expressions.IBindings;

    /**
     * This class compiles any simple expression (represented as a string) in to a
     * function object. The function takes a single argument: an object that
     * implements IBindings that maps variables that may appear in the expression
     * to values.
     *
     * @author Jonathan A. Smith
     */

    public class Compiler
    {
    	public static var default_compiler: Compiler = new Compiler();

    	/**
    	 * Translate an expression into a function object. The returned function
    	 * will evaluate the expression using variable bindings passed as an
    	 * Object instance.
    	 *
    	 * @param expression expression to compile
    	 * @return Function for computing the expression
    	 */

    	public function compileExpression(expression: String): Function
    	{
    		var tokens: Tokenizer = new Tokenizer(expression);
    		tokens.next();
    		var expression_function: Function = translateDisjunction(tokens);
    		if (tokens.token_kind != Tokenizer.END_TOKEN)
    			throw new origami.expressions.SyntaxError(tokens, "Unexpected end of expression");
    		return expression_function;
    	}

    	/**
    	 * Compiles a disjunction (e {or e}).
    	 */

    	private function translateDisjunction(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateConjunction(tokens);
    		while (tokens.token_kind == Tokenizer.OR_TOKEN)
    			left_function = translateOr(left_function, tokens);
    		return left_function;
    	}

    	/**
    	 * Compiles an expression p or q.
    	 */

    	private function translateOr(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateConjunction(tokens);
    		function closure (bindings: IBindings): Object
    		{
    			return left_function(bindings) || right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles a conjunction (e {and e}).
    	 */

    	private function translateConjunction(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateRelation(tokens);
    		while (tokens.token_kind == Tokenizer.AND_TOKEN)
    			left_function = translateAnd(left_function, tokens);
    		return left_function;
    	}

    	/**
    	 * Compiles an expression p and q.
    	 */

    	private function translateAnd(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateRelation(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) && right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles a relation [not] (e [relop e]).
    	 */

    	private function translateRelation(tokens: Tokenizer): Function
    	{
    		var is_not: Boolean = false;
    		if (tokens.token_kind == Tokenizer.NOT_TOKEN)
    		{
    			is_not =true;
    			tokens.next();
    		}
    		var left_function: Function = translateArithmetic(tokens);
    		if (tokens.token_kind == Tokenizer.RELOP_TOKEN)
    		{
    			var operator: String = tokens.token_text;
    			if (operator == "==")
    				left_function = translateEaual(left_function, tokens);
    			else if (operator == "!=")
    				left_function = translateNotEaual(left_function, tokens);
    			else if (operator == "<")
    				left_function = translateLess(left_function, tokens);
    			else if (operator == "<=")
    				left_function = translateLessEaual(left_function, tokens);
    			else if (operator == ">")
    				left_function = translateGreater(left_function, tokens);
    			else if (operator == ">=")
    				left_function = translateGreaterEqual(left_function, tokens);
    		}
    		if (is_not)
    			return generateNot(left_function);
    		else
    			return left_function;
    	}

    	/**
    	 * Compiles an expression negating a value.
    	 */

    	private function generateNot(right_function: Function): Function
    	{
    		function closure(bindings: IBindings): Object
    		{
    			return !right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression comparing two values for equality.
    	 */

    	private function translateEaual(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) == right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression comparing two values for inequality.
    	 */

    	private function translateNotEaual(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) != right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression testing if one value is less than another.
    	 */

    	private function translateLess(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) < right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression testing if one value is less or equal to another.
    	 */

    	private function translateLessEaual(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) <= right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression testing if one value is greater than another.
    	 */

    	private function translateGreater(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) > right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression testing if one value is less or equal to another.
    	 */

    	private function translateGreaterEqual(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateArithmetic(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) >= right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an arithmetic expression.
    	 */

    	private function translateArithmetic(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateTerm(tokens);
    		while (tokens.token_kind == Tokenizer.ADDOP_TOKEN)
    		{
    			var operator: String = tokens.token_text;
    			if (operator == "+")
    				left_function = translateAdd(left_function, tokens);
    			else if (operator == "-")
    				left_function = translateSubtract(left_function, tokens);
    			else
    				throw new Error("Program error. Not ADDOP: " + operator);
    		}
    		return left_function;
    	}

    	/**
    	 * Compiles an expression adding two values.
    	 */

    	private function translateAdd(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateTerm(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) + right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression subtracting two values.
    	 */

    	private function translateSubtract(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateTerm(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) - right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles a term expression in to a function.
    	 */

    	private function translateTerm(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateMemberReference(tokens);
    		while (tokens.token_kind == Tokenizer.MULOP_TOKEN)
    		{
    			var operator: String = tokens.token_text;
    			if (operator == "*")
    				left_function = translateMultiply(left_function, tokens);
    			else if (operator == "/")
    				left_function = translateDivide(left_function, tokens);
    			else if (operator == "%")
    				left_function = translateMod(left_function, tokens);
    			else
    				throw new Error("Program error. Not MULLOP: " + operator);
    		}
    		return left_function;
    	}

    	/**
    	 * Compiles an expression multiplying two values.
    	 */

    	private function translateMultiply(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateMemberReference(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) * right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression dividing two values.
    	 */

    	private function translateDivide(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateMemberReference(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) / right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression computing the mod of two expressions.
    	 */

    	private function translateMod(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateMemberReference(tokens);
    		function closure(bindings: IBindings): Object
    		{
    			return left_function(bindings) % right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles a simple factor or member reference expression such
    	 * as a.f or a.f(argument list) into a function.
    	 */

    	private function translateMemberReference(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateFactor(tokens);

    		while (tokens.token_kind == Tokenizer.DOT_TOKEN)
    		{
    			tokens.next();
    			if (tokens.token_kind != Tokenizer.ID_TOKEN)
    				throw new origami.expressions.SyntaxError(tokens, "Must be identifier.");
    			var field_id: String = tokens.token_text;
    			tokens.next();

    			if (tokens.token_kind == Tokenizer.LPAREN_TOKEN)
    				left_function = translateMethodCall(left_function, field_id, tokens);
    			else
    				left_function = generateReference(left_function, field_id);
    		}

    		return left_function;
    	}

    	/**
    	 * Compiles a method call in to a function.
    	 */

    	private function translateMethodCall(target_function: Function, method_name: String,
    			tokens: Tokenizer): Function
    	{
    		var argument_functions: Array = translateArgumentList(tokens);

			function closure (bindings: IBindings): Object
			{
				// Compute target value
				var target: Object = target_function(bindings);

				// Compute array of method arguments
				var arguments: Array = new Array();
				for (var index: int = 0; index < argument_functions.length; index += 1)
					arguments.push(argument_functions[index](bindings));

				// Get method function from target
				var method: Function = target[method_name];
				if (method == null)
					throw new Error("Unknown method: " + method_name);

				// Apply method function to target and arguments
				return method.apply(target, arguments);
			};
        	return closure;
    	}

    	/**
    	 * Compiles a list of argument expressions into a function that
    	 * returns an array of argument values.
    	 */

    	private function translateArgumentList(tokens: Tokenizer): Array
    	{
    		tokens.next();

    		var argument_functions: Array = new Array();
    		while (tokens.token_kind != Tokenizer.RPAREN_TOKEN)
    		{
    			argument_functions.push(translateDisjunction(tokens));
    			if (tokens.token_kind == Tokenizer.COMMA_TOKEN)
    				tokens.next();
    			else if (tokens.token_kind != Tokenizer.RPAREN_TOKEN)
    				throw new origami.expressions.SyntaxError(tokens, "Expected comma or right parenthesis");
    		}
    		tokens.next();

    		return argument_functions;
    	}

    	/**
    	 * Generates a function to reference a member variable in the
    	 * result of a function.
    	 */

    	private function generateReference(right_function: Function,
    			member_name: String): Function
    	{
			function closure(bindings: IBindings): Object
			{
				var value: Object = right_function(bindings);
				if (value is IBindings)
					return IBindings(value).get(member_name);
				return value[member_name];
			};
    		return closure;
    	}

    	/**
    	 * Compiles an expression consisting of a numeric or boolean constant or a
    	 * variable reference.
    	 */

    	private function translateFactor(tokens: Tokenizer): Function
    	{
    		var is_negated: Boolean = false;
    		if (tokens.token_text == "-")
    		{
    			is_negated = true;
    			tokens.next();
    		}
    		var expression_function: Function;
    		switch (tokens.token_kind)
    		{
    			case Tokenizer.LPAREN_TOKEN:
    				expression_function = translateParentheses(tokens);
    				break;
    			case Tokenizer.NUMBER_TOKEN:
    				expression_function = translateNumber(tokens);
    				break;
    			case Tokenizer.BOOLEAN_TOKEN:
    				expression_function = translateBoolean(tokens);
    				break;
    			case Tokenizer.ID_TOKEN:
    				expression_function = translateVariable(tokens);
    				break;
    			default:
    				return null;
    		}
    		if (is_negated)
    			return generateNegate(expression_function);
    		else
    			return expression_function;
    	}

    	/**
    	 * Compiles a subexpression in parentheses.
    	 */

    	private function translateParentheses(tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateDisjunction(tokens);
    		if (tokens.token_kind != Tokenizer.RPAREN_TOKEN)
    			throw new origami.expressions.SyntaxError(tokens, "Missing right parenthesis");
    		tokens.next();
    		return right_function;
    	}

    	/**
    	 * Compiles an expression negating a numeric result.
    	 */

    	private function generateNegate(right_function: Function): Function
    	{
    		function closure(bindings: IBindings): Object
    		{
    			return -(right_function(bindings));
    		};
    		return closure;
    	}

    	/**
    	 * Compiles an expression consisting of a numeric constant.
    	 */

    	private function translateNumber(tokens: Tokenizer): Function
    	{
    		var number: Number = tokens.token_number;
    		tokens.next();
    		function closure(bindings: IBindings): Object { return number; };
    		return closure;
    	}

    	/**
    	 * Compiles an expression consisting of a boolean constant.
    	 */

    	private function translateBoolean(tokens: Tokenizer): Function
    	{
    		var boolean: Boolean = tokens.token_boolean;
    		tokens.next();
    		function closure(bindings: IBindings): Object { return boolean; };
    		return closure;
    	}

    	/**
    	 * Compiles an expression consisting of a variable reference.
    	 */

    	private function translateVariable(tokens: Tokenizer): Function
    	{
    		if (tokens.token_kind != Tokenizer.ID_TOKEN) return null;
    		var id: String = tokens.token_text;
    		tokens.next();
    		function closure(bindings: IBindings): Object
    		{
    		    return bindings.get(id);
    		};
    		return closure;
    	}

    	// **** Assertions

    	/**
    	 * Compiles an assertion: an expression that changes bindings so as
    	 * to make a specified (limited) expression true.
    	 *
    	 * @param expression expression to compile
    	 * @return function for asserting the expression
    	 */

    	public function compileAssertion(expression: String): Function
    	{
    		var tokens: Tokenizer = new Tokenizer(expression);
    		tokens.next();
    		var assertion_function: Function = translateAssertConjunction(tokens);
    		if (tokens.token_kind != Tokenizer.END_TOKEN)
    			throw new origami.expressions.SyntaxError(tokens, "Unexpected end of expression");
    		return assertion_function;
    	}

    	/**
    	 * Asserts a conjunction (e {and e}).
    	 */

    	private function translateAssertConjunction(tokens: Tokenizer): Function
    	{
    		var left_function: Function = translateAssertRelation(tokens);
    		while (tokens.token_kind == Tokenizer.AND_TOKEN
    				|| tokens.token_kind == Tokenizer.COMMA_TOKEN )
    			left_function = translateAssertAnd(left_function, tokens);
    		return left_function;
    	}

    	/**
    	 * Compiles an assertion p and q.
    	 */

    	private function translateAssertAnd(
    			left_function: Function, tokens: Tokenizer): Function
    	{
    		tokens.next();
    		var right_function: Function = translateAssertRelation(tokens);
    		function closure(bindings: IBindings): void
    		{
    			left_function(bindings); right_function(bindings);
    		};
    		return closure;
    	}

    	/**
    	 * Compiles the assertion of a relation (id | not id | id = e).
    	 */

    	private function translateAssertRelation(tokens: Tokenizer): Function
    	{
    		var is_not: Boolean = parseNot(tokens);
    		var id: String = parseId(tokens);
    		var index_function: Function = parseIndex(tokens);
    		var value_function: Function = parseEquals(tokens);
    		if (value_function != null && is_not)
    			throw new origami.expressions.SyntaxError(tokens, "Assert not equals");
    		return generateAssert(is_not, id, index_function, value_function);
    	}

    	/**
    	 * Looks for 'not' token at current position, If found, removes the token
    	 * and returns true. Returns false otherwise.
    	 */

    	private function parseNot(tokens: Tokenizer): Boolean
    	{
    		if (tokens.token_kind == Tokenizer.NOT_TOKEN)
    		{
    			tokens.next();
    			return true;
    		}
    		return false;
    	}

    	/**
    	 * Looks for an id token at the current position. If not found throws
    	 * SyntaxError exception. Removes the id token and returns the id.
    	 */

    	private function parseId(tokens: Tokenizer): String
    	{
    		if (tokens.token_kind != Tokenizer.ID_TOKEN)
    			throw new origami.expressions.SyntaxError(tokens, "Expected id");
    		var id: String = tokens.token_text;
    		tokens.next();
    		return id;
    	}

    	/**
    	 * Translates an expression surrounded by brackets [] into a function
    	 * for computing the value of the index expression. Returns null if
    	 * no opening bracket is found. Throws a syntax exception if the closing
    	 * bracket is missing.
    	 */

    	private function parseIndex(tokens: Tokenizer): Function
    	{
    		if (tokens.token_kind != Tokenizer.LBRACKET_TOKEN) return null;
    		tokens.next();
    		var index_function: Function = translateArithmetic(tokens);
    		if (tokens.token_kind != Tokenizer.RBRACKET_TOKEN)
    			throw new origami.expressions.SyntaxError(tokens, "Expecting ]");
    		tokens.next();
    		return index_function;
    	}

    	/**
    	 * Parses an equals or assign operator followed by a value (relation)
    	 * expression.	Returns a function for computing the value or null if
    	 * not found.
    	 */

    	private function parseEquals(tokens: Tokenizer): Function
    	{
    		if (tokens.token_text != "=="
    				&& tokens.token_kind != Tokenizer.ASSIGN_TOKEN)
    			return null;
    		tokens.next();
    		return translateRelation(tokens);
    	}

    	/**
    	 * Generates a function to set a variable to a value as specified by
    	 * one conjunct in an assertion expression.
    	 */

    	private function generateAssert(is_not: Boolean, id: String,
    			index_function: Function, value_function: Function): Function
    	{
    		if (index_function == null)
    		{
    			if (value_function != null)
    				return generateAssertEquals(id, value_function);
    			else if (!is_not)
    				return generateAssertTrue(id);
    			else
    				return generateAssertFalse(id);
    		}
    		else
    		{
    			if (value_function != null)
    				return generateElementEquals(
    						id, index_function, value_function);
    			else if (!is_not)
    				return generateElementTrue(id, index_function);
    			else
    				return generateElementFalse(id, index_function);
    		}
    	}

    	/**
    	 * Generates a function to set a variable to true.
    	 */

    	private function generateAssertTrue(id: String): Function
    	{
    		function closure(bindings: IBindings): void
    		{
    			bindings.put(id, true);
    		};
    		return closure;
    	}

    	/**
    	 * Generates a function to set a variable to false.
    	 */

    	private function generateAssertFalse(id: String): Function
    	{
    		function closure(bindings: IBindings): void
    		{
    			bindings.put(id, false);
    		};
    		return closure;
    	}

    	/**
    	 * Generates a function to set a variable to a computed value.
    	 */

    	private function generateAssertEquals(id: String,
    			value_function: Function): Function
    	{
    		function closure(bindings: IBindings): void
    		{
				var value: Object = value_function(bindings);
				bindings.put(id, value);
    		};
    		return closure;
    	}

    	/**
    	 * Generates a function to set an array element to true.
    	 */

    	private function generateElementTrue(id: String,
    			index_function: Function): Function
    	{
    		function closure(bindings: IBindings): void
    		{
    		};
    		return closure;
    	}

    	/**
    	 * Generates a function to set an array element to false.
    	 */

    	private function generateElementFalse(id: String,
    			index_function: Function): Function
    	{
    		function closure(bindings: IBindings): void
    		{
    		};
    		return closure;
    	}

    	/**
    	 * Generates a function to set an array element to a computed value.
    	 */

    	private function generateElementEquals(d: String,
    			index_function: Function, value_function: Function): Function
    	{
    		function closure(bindings: IBindings): void
    		{
    		};
    		return closure;
    	}
    }

}
