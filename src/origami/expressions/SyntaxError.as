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

    /**
     * Exception signaling a syntax error while compiling an expression.
     *
     * @author Jonathan A. Smith
     */

    public class SyntaxError extends Error
    {
    	/**
    	 * Constructs a SyntaxError.
    	 */

    	public function SyntaxError(tokens: Tokenizer, message: String)
    	{
    		super(message + ": " + tokens.marked_string);
    	}
    }

}