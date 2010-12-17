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

package origami.page_dial
{
	import mx.core.UIComponent;

	public class PageDialPointer extends UIComponent
	{
		public function PageDialPointer()
		{
			//TODO: implement function
			super();
		}

		override protected function updateDisplayList(unscaledWidth: Number, unscaledHeight: Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
	        graphics.clear();
	        graphics.lineStyle(0, 0xEE0000, 100);
	        graphics.moveTo(-4, 0);
	        graphics.lineTo(4, 0);
	        graphics.lineTo(0, 4);
	        graphics.lineTo(-4, 0);
		}

	}
}