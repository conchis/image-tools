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
     * Interface for object implementing variable bindings. Note that this interface
     * is optional on actual bindings: the generated function will set a field if
     * bindings does not implement this interface.
     *
     * @author Jonathan A. Smith
     */

    public interface IBindings
    {
    	/**
    	 * Associates a variable with a value.
    	 *
    	 * @param variable name of the variable
    	 * @param value value to associate with the variable
    	 */

    	function put(variable: String, value: Object): void;

    	/**
    	 * Gets a value associated with a variable.
    	 *
    	 * @param variable name of variable to look up
    	 * @return value associated with the variable.
    	 */

    	function get(variable: String): Object;
    }

}