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
     * An Assertion is a wrapper for an assertion function that maintains
     * the original text that the expression was compiled from.
     *
     * @author Jonathan A. Smith
     */

    public class Assertion
    {
        /** Text of the expression. */
        private var __expression: String;

        /** Compiled function for evaluating the expression. */
        private var __function: Function;

        /**
         * Constructs an asertion by compiling the expression text.
         *
         * @param expression text of the expression to be compiled
         */

        public function Assertion(expression: String)
        {
            var compiler: Compiler = Compiler.default_compiler;
            __expression = expression;
            __function = compiler.compileAssertion(expression);
        }

        /**
         * Returns the original expression text.
         *
         * @return original expression text
         */

        public function get expression(): String
        {
            return __expression;
        }

        /**
         * Returns the function used to execute the expression.
         *
         * @return expression function
         */

        public function get fn(): Function
        {
            return __function;
        }

        /**
         * Executes the expression function on the supplied bindings.
         *
         * @param bindings The bindings to use when executing the expression
         * @return the result of applying the expression to the bindings
         */

        public function execute(bindings: IBindings): Object
        {
            return __function(bindings);
        }

        /**
         * Returns a string represenation of the expression (the original expression text).
         *
         * @return Original expression text
         */

        public function toString(): String
        {
            return expression;
        }

    }

}