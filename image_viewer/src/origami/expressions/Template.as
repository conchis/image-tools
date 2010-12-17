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

    import origami.expressions.Compiler;

    /**
     * A template is initialized with a string that contains embedded expressions.
     * When requested the template evaluates the expressions in the environment
     * (bindings) provided and returns the resulting string.
     *
     * @author Jonathan A. Smith
     */

    public class Template
    {
    	/** Original template string. */
    	private var pattern_string: String;

    	/** Strings and compiled expressions used to evaluate the template. */
    	private var segments: Array;

    	/**
    	 * Constructs a Template.
    	 *
    	 * @param pattern pattern to be compiled into the template
    	 */

    	public function Template(pattern: String)
    	{
    		pattern_string = pattern;
    		parseTemplate(pattern);
    	}

    	/**
    	 * Parses the template string into a series of segments.
    	 */

    	private function parseTemplate(pattern_string: String): void
    	{
    		segments = new Array();
    		var start: int = 0;
    		while (start < pattern_string.length)
    		{
    			if (pattern_string.charAt(start) == "{")
    				start = scanExpressionSegment(pattern_string, start);
    			else
    				start = scanLiteralSegment(pattern_string, start);
    		}
    	}

    	/**
    	 * Scans and adds a literal segment. Returns the index of the character
    	 * after the literal segment.
    	 */

    	private function scanLiteralSegment(pattern: String, start: int): int
    	{
    		var next: int = pattern_string.indexOf("{", start);
    		if (next < 0) next = pattern_string.length;
    		var fill: String = pattern_string.substring(start, next);
    		segments.push(fill);
    		return next;
    	}

    	/**
    	 * Scans and adds a segment containing an expression. Returns the index of
    	 * the character after the expression.
    	 */

    	private function scanExpressionSegment(pattern: String, start: int): int
    	{
    		var expression_compiler: Compiler = Compiler.default_compiler;
    		var next: int = pattern_string.indexOf("}", start);
    		if (next < 0) next = pattern_string.length;
    		var expression: String =
    				pattern_string.substring(start + 1, next);
    		segments.push(
    			expression_compiler.compileExpression(expression));
    		return next + 1;
    	}

    	// **** Expansion

    	/**
    	 * Expands the template while evaluating expressions in the supplied bindings.
    	 *
    	 * @param bindings bindings to use in the expansion
    	 * @return the result of the template expansion
    	 */

    	public function expand(bindings: Bindings): String
    	{
    	    var out: Array = new Array();
    		for (var index: int = 0; index < segments.length; index += 1)
    		{
    			var segment: Object = segments[index];
    			var segment_type: String = typeof(segment);
    			if (segment_type == "string")
    				out.push(String(segment));
    			else if (segment_type == "function")
    				out.push("" + segment(bindings));
    		}
    		return out.join("");
    	}

    	// **** String Representation

    	/**
    	 * Return original template string.
    	 *
    	 * @return the template string
    	 */

    	public function toString(): String
    	{
    		return pattern_string;
    	}

    }

}

