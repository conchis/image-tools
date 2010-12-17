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

    import origami.expressions.SyntaxError;

    /**
     * Simple lexical analyzer for expressions. With a few added alternatives, this
     * follows C / Java language conventions.
     *
     * @author Jonathan A. Smith
     */

    public class Tokenizer
    {
    	// **** Token Type Constants

    	// Start of Line / End of Line
    	public static var START_TOKEN:	   	int =   -1;
    	public static var END_TOKEN:	   	int =	 0;

    	// Constants
    	public static var BOOLEAN_TOKEN:  	int =	 1;	 // true | false
    	public static var NUMBER_TOKEN:   	int =	 2;	 // 10 3.14
    	public static var STRING_TOKEN:   	int =	 3;	 // "sample"

    	// Identifiers
    	public static var ID_TOKEN:	   	    int =	 4;	 // x_offset

    	// Brackets
    	public static var LPAREN_TOKEN:  	int =	 5;	 // '('
    	public static var RPAREN_TOKEN:   	int =	 6;	 // ')'
    	public static var LBRACKET_TOKEN: 	int =	 7;	 // '['
    	public static var RBRACKET_TOKEN: 	int =	 8;	 // ']'

    	// Dot
    	public static var DOT_TOKEN:        int =     9;  // "."

    	// Arithmetic and Relational
    	public static var MULOP_TOKEN:	   	int =    10; // '*'	 or '/'
    	public static var ADDOP_TOKEN:	   	int =    11; // '+'	 or '-'
    	public static var RELOP_TOKEN:	   	int =    12; // '>'	 or '>=' or '<'	 or '<='
    	public static var EQOP_TOKEN:	   	int =    13; // '==' or '!='

    	// Logical
    	public static var NOT_TOKEN:	   	int =    14; // '!'	 or 'not'
    	public static var AND_TOKEN:	   	int =    15; // '&&' or 'and'
    	public static var OR_TOKEN:	   		int =    16; // '||' or 'or'

    	// Assignment
    	public static var ASSIGN_TOKEN:   	int =    17;	 // '='	 or ':='
    	public static var COMMA_TOKEN:	   	int =    18;	 // ','
    	public static var SEMI_TOKEN:	   	int =    19;	 // ';'
    	public static var COLON_TOKEN:	   	int =    20;	 // ':'

    	// Unknown
    	public static var UNKNOWN_TOKEN:  	int =    99;

    	// **** Character Code Constants

    	private static var UNDERSCORE:	int = "_".charCodeAt(0);
    	private static var QUOTE: 		int = "\"".charCodeAt(0);
    	private static var APOSTROPHE: 	int = "'".charCodeAt(0);
    	private static var BACKSLASH:   int = "\\".charCodeAt(0);

    	// **** Instance Variables

    	/** Text to be scanned. */
    	private var __source_text: String;

    	/** Next character to be scanned. */
    	private var __source_index: int;

    	/** Current token kind. */
    	private var __token_kind: int;

    	/** Current token text. */
    	private var __token_text: String;

    	/** Index of start of current token. */
    	private var __token_start: int;

    	// **** Initialization

    	/**
    	 * Constructs a Tokenizer.
    	 *
    	 * @param text (optional) text to be tokenized
    	 */

    	public function Tokenizer(text: String)
    	{
    		if (text != null)
    			source_text = text;
    	}

    	/**
    	 * Sets the source text (reset the scan).
    	 *
    	 * @param text text to be tokenized
    	 */

    	public function set source_text(text: String): void
    	{
    		__source_text = text;
    		__source_index = 0;
    		__token_kind = START_TOKEN;
    		__token_text = "";
    		__token_start = -1;
    	}

    	// **** Current Token

    	/**
    	 * Returns the current token type.
    	 *
    	 * @return current token type. See constants above.
    	 */

    	public function get token_kind(): int
    	{
    		return __token_kind;
    	}

    	/**
    	 * Returns the current token text.
    	 *
    	 * @return current token text
    	 */

    	public function get token_text(): String
    	{
    		return __token_text;
    	}

    	/**
    	 * Returns the current token value as a string.
    	 *
    	 * @return the current token's value string
    	 */

    	public function get token_string(): String
    	{
    		return __token_text;
    	}

    	/**
    	 * Returns the current token value as a boolean.
    	 *
    	 * @return the current token's value as a Boolean
    	 */

    	public function get token_boolean(): Boolean
    	{
    		if (__token_kind != BOOLEAN_TOKEN)
    			return false;
    		return __token_text == "true";
    	}

    	/**
    	 * Returns the current token value as a number.
    	 *
    	 * @return the current token's value as a Number
    	 */

    	public function get token_number(): Number
    	{
    		if (__token_kind != NUMBER_TOKEN)
    			return 0;
    		if (__token_text.indexOf(".") > -1 || __token_text.indexOf("e") > -1)
    			return parseFloat(__token_text);
    		return parseInt(__token_text);
    	}

    	/**
    	 * Returns a string containing the entire source text with the current
    	 * token marked in the text.
    	 *
    	 * @return the scanned text with the current token marked. This is used for
    	 * error reporting.
    	 */

    	public function get marked_string(): String
    	{
    		return __source_text.substring(0, __token_start) +
    			   "[[" + __token_text + "]]" +
    			   __source_text.substring(__token_start + __token_text.length);
    	}

    	// **** Advance To Next Token

    	/**
    	 * Advances to the next token in the string. Returns a token kind for the
    	 * next token.
    	 *
    	 * @return the next token kind (see constants in this class.)
    	 */

    	public function next(): int
    	{
    		skipSpace();
    		__token_kind = END_TOKEN;
    		__token_text = "";
    		__token_start = __source_index;
    		return scanToken();
    	}

    	/**
    	 * Skips to next non-white space character.
    	 */

    	private function skipSpace(): void
    	{
    		for (var index: int = __source_index; index < __source_text.length;
    				index += 1)
    		{
    			if (!isWhiteSpace(__source_text.charCodeAt(index)))
    			{
    				__source_index = index;
    				return;
    			}
    		}
    		__source_index = __source_text.length;
    	}

    	/**
    	 * Scans the token starting at the current source index.
    	 */

    	private function scanToken(): int
    	{
    		// No text left to scan
    		if (__source_index	>= __source_text.length)
    			return END_TOKEN;

    		// Scan depending on first character
    		var first_char: int = __source_text.charCodeAt(__source_index);
    		if (isLetter(first_char))
    			__token_kind = scanIdentifier();
    		else if (isDigit(first_char))
    			__token_kind = scanNumber();
    		else if (first_char == QUOTE || first_char == APOSTROPHE)
    			__token_kind = scanString();
    		else
    			__token_kind = scanOperator();
    		return __token_kind;
    	}

    	/**
    	 * Scans an identifier.
    	 */

    	private function scanIdentifier(): int
    	{
    		var index: int = __source_index;
    		while(index < __source_text.length)
    		{
    			if (!isIdentifierChar(__source_text.charCodeAt(index))) break;
    			index += 1;
    		}
    		__token_text = __source_text.substring(__source_index, index);
    		__source_index = index;

    		// Check for keywords
    		if (__token_text == "true" ) return BOOLEAN_TOKEN;
    		if (__token_text == "false") return BOOLEAN_TOKEN;
    		if (__token_text == "and"  ) return AND_TOKEN;
    		if (__token_text == "or"   ) return OR_TOKEN;
    		if (__token_text == "not"  ) return NOT_TOKEN;

    		return ID_TOKEN;
    	}

    	/**
    	 * Scans a number. Supports formats: 3, 3.14159, 3.5e8, and so on. Numbers
    	 * must start with a digit: 0.5, not .5.
    	 */

    	private function scanNumber(): int
    	{
    		var index: int = __source_index;
    		while (index < __source_text.length)
    		{
    			if (!isDigit(__source_text.charCodeAt(index))) break;
    			index += 1;
    		}
    		if (__source_text.charAt(index) == '.')
    		{
    			index += 1;
    			while (index < __source_text.length)
    			{
    				if (!isDigit(__source_text.charCodeAt(index))) break;
    				index += 1;
    			}
    		}
    		if (__source_text.charAt(index) == 'e')
    		{
    			index += 1;
    			while (index < __source_text.length)
    			{
    				if (!isDigit(__source_text.charCodeAt(index))) break;
    				index += 1;
    			}
    		}
    		__token_text = __source_text.substring(__source_index, index);
    		__source_index = index;
    		return NUMBER_TOKEN;
    	}

    	/**
    	 * Scans a string enclosed in quote marks or apostrophes. Embedded
    	 * quotes may be escaped with a backslash. Numeric character values
    	 * are not yet supported.
    	 */

    	private function scanString(): int
    	{
    		var index: int = __source_index;
    		var quote_mark: int = __source_text.charCodeAt(index);
    		var result_chars: Array = new Array();

    		index += 1;
    		while (index < __source_text.length)
    		{
    			var next_char: int = __source_text.charCodeAt(index);
    			if (next_char == quote_mark) break;
    			if (next_char == BACKSLASH)
    			{
    				index += 1;
    				if (index < __source_text.length)
    					result_chars.push(String.fromCharCode(__source_text.charCodeAt(index)));
    			}
    			else
    				result_chars.push(String.fromCharCode(next_char));
    			index += 1;
    		}

    		__token_text = result_chars.join("");
    		if (__source_text.charCodeAt(index) == quote_mark)
    			index += 1;
    		__source_index = index;
    		return STRING_TOKEN;
    	}

    	/**
    	 * Scans a bracket or operator.
    	 */

    	private function scanOperator(): int
    	{
    		var next_char: String = __source_text.charAt(__source_index);
    		var kind: int = UNKNOWN_TOKEN;
    		switch (next_char)
    		{
    			case "(": kind = LPAREN_TOKEN;     break;
    			case ")": kind = RPAREN_TOKEN;     break;
    			case "[": kind = LBRACKET_TOKEN;   break;
    			case "]": kind = RBRACKET_TOKEN;   break;
    			case ",": kind = COMMA_TOKEN;	   break;
    			case ";": kind = SEMI_TOKEN;	   break;

    			case ".": kind = DOT_TOKEN;	       break;

    			case "*": kind = MULOP_TOKEN;	   break;
    			case "/": kind = MULOP_TOKEN;	   break;
    			case "%": kind = MULOP_TOKEN;	   break;
    			case "+": kind = ADDOP_TOKEN;	   break;
    			case "-": kind = ADDOP_TOKEN;	   break;

    			case ">": return scanDoubleOp("=", RELOP_TOKEN,	  RELOP_TOKEN );
    			case "<": return scanDoubleOp("=", RELOP_TOKEN,	  RELOP_TOKEN );
    			case "=": return scanDoubleOp("=", ASSIGN_TOKEN,  RELOP_TOKEN );
    			case "!": return scanDoubleOp("=", NOT_TOKEN,	  RELOP_TOKEN );
    			case "&": return scanDoubleOp("&", UNKNOWN_TOKEN, AND_TOKEN	  );
    			case "|": return scanDoubleOp("|", UNKNOWN_TOKEN, OR_TOKEN	  );
    			case ":": return scanDoubleOp("=", COLON_TOKEN,	  ASSIGN_TOKEN);

    			default:
    			{
    				__token_text = __source_text.charAt(__source_index);
    				__source_index += 1;
    				throw new origami.expressions.SyntaxError(this, "Unknown operator");
    			}
    		}
    		__token_text = next_char;
    		__source_index += 1;
    		return kind;
    	}

    	/**
    	 * Scans a one or two character operator. Return a token kind depending
    	 * on the match.
    	 */

    	private function scanDoubleOp(second_char: String, kind1: int, kind2: int): int
    	{
    		var operator_length: int = 1;
    		var second_index: int = __source_index + 1;
    		if (second_index >= __source_text.length
    				|| __source_text.charAt(second_index) != second_char)
    		{
    			__token_text = __source_text.charAt(__source_index);
    			__source_index += 1;
    			if (kind1 == UNKNOWN_TOKEN)
    				throw new origami.expressions.SyntaxError(this, "Invalid operator");
    			return kind1;
    		}
    		else
    		{
    			__token_text = __source_text.substr(__source_index, 2);
    			__source_index += 2;
    			if (kind2 == UNKNOWN_TOKEN)
    				throw new origami.expressions.SyntaxError(this, "Invalid operator");
    			return kind2;
    		}
    	}

    	// *** Character Type Functions

    	/**
    	 * Determines if char_code is a code for a Latin 1 letter.
    	 *
    	 * @param char_code numeric code for a character
    	 * @return true if the character code represents a letter
    	 */

    	public function isLetter(char_code: int): Boolean
    	{
    		// Upper case
    		if (char_code >= 65 && char_code <= 90)
    			return true;

    		// Lower case
    		if (char_code >= 97 && char_code <= 122)
    			return true;

    		// Otherwise not a letter
    		return false;
    	}

    	/**
    	 * Determines if char_code is code for a Latin 1 digit (0..9).
    	 *
    	 * @param char_code numeric code for a character
    	 * @return true if the character code represents a digit
    	 */

    	public function isDigit(char_code: int): Boolean
    	{
    		return char_code >= 48 && char_code <= 57;
    	}

    	/**
    	 * Determines if char_code is a code for a white space character.
    	 *
    	 * @param char_code numeric code for a character
    	 * @return true if the code represents a whitespace character
    	 */

    	public function isWhiteSpace(char_code: int): Boolean
    	{
    		return (char_code == 10			 // LF
    			 || char_code == 13			 // CR
    			 || char_code == 32			 // SP
    			 || char_code == 160);		 // NBSP
    	}

    	/**
    	 * Determines if the character is a legal identifier character: a letter,
    	 * a digit, or an underscore.
    	 *
    	 * @param char_code numeric code for a character
    	 * @return true if the character code represents a letter or digit or '_'
    	 */

    	public function isIdentifierChar(char_code: int): Boolean
    	{
    		return isLetter(char_code) || isDigit(char_code)
    				|| char_code == UNDERSCORE;
    	}

    }

}