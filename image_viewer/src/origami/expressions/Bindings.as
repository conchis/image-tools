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
    import origami.expressions.IBindings;

    /**
     * Class for object implementing variable bindings. Note that this interface
     * is optional on actual bindings: the generated function will set a field if
     * bindings does not implement this interface.
     *
     * @author Jonathan A. Smith
     */

    public class Bindings implements IBindings
    {
        /** Map from indentifier to value. */
        private var __map: Object;

        /**
         * Constructs a bindings.
         *
         * @param (optional) initial binding map
         */

        public function Bindings(... rest)
        {
            if (rest.length > 0)
                __map = rest[0];
            else
                __map = new Object();
        }

        /**
         * Returns the indentifier -> value map.
         */

        public function get map(): Object
        {
            return __map;
        }

    	/**
    	 * Associates a variable with a value.
    	 *
    	 * @param variable name of the variable
    	 * @param value value to associate with the variable
    	 */

    	public function put(variable: String, value: Object): void
    	{
    	    __map[variable] = value;
    	}

    	/**
    	 * Gets a value associated with a variable.
    	 *
    	 * @param variable name of variable to look up
    	 * @return value associated with the variable.
    	 */

    	public function get(variable: String): Object
    	{
    	    return __map[variable];
    	}

    	/**
    	 * Returns an XML representation of the bindings.
    	 *
    	 * @return XML representation of the bindings
    	 */

    	public function toXML(): XML
    	{
    	    var bindings_xml: XML = <bindings/>;
    	    for (var name: String in __map)
    	        bindings_xml.appendChild(<let name={name}>{__map[name]}</let>);
    	    return bindings_xml;
    	}

    	/**
    	 * Returns an XML string represenation of the current bindings.
    	 *
    	 * @return String representation of the bindings
    	 */

    	public function toString(): String
    	{
    	    return toXML().toXMLString();
    	}
    }

}