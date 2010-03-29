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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import mx.controls.Button;
	import mx.events.ResizeEvent;

	import origami.framework.Component;;

	/**
	 * Navigation widget for flipping through a collection of URLs.
	 *
	 * @author Jonathan A. Smith
	 */

	public class SingleDial extends Component
	{
	    /** Button left position. */
	    public static const BUTTON_LEFT: int = 5;

	    /** Button top position. */
	    public static const BUTTON_TOP: int = 5;

	    /** Width of buttons. */
	    public static const BUTTON_WIDTH: int = 16;

	    /** Height of buttons. */
	    public static const BUTTON_HEIGHT: int = 16;

	    /** Button gap size. */
	    public static const BUTTON_GAP: int = 3;

	    /** Left margin. */
	    public static const MARK_LEFT: int =  5 + BUTTON_LEFT + 4 * (BUTTON_WIDTH + BUTTON_GAP);

	    [Embed(source="../assets/viewer.swf", symbol="vcrRewindIcon")]
		private static var rewindIcon: Class;

	    [Embed(source="../assets/viewer.swf", symbol="vcrBackIcon")]
		private static var backIcon: Class;

	    [Embed(source="../assets/viewer.swf", symbol="vcrForwardIcon")]
		private static var forwardIcon: Class;

	    [Embed(source="../assets/viewer.swf", symbol="vcrEndIcon")]
		private static var endIcon: Class;

		/** URL of outline. */
		private var __outline_url: String;

		/** Outlne displayed in view. */
		private var __outline : Outline;

	    /** Width of active part of dial. */
	    private var dial_width: int;

		/** Ruler view. */
		private var ruler: SingleDialRuler;

		/** Rewinds to beginning of outline. */
		private var first_button: Button;

		/** Back one item. */
		private var previous_button: Button;

		/** Forward one item. */
		private var next_button: Button;

		/** Forward to last item. */
		private var last_button: Button;

		public function SingleDial()
		{
			super();
			addEventListener(Component.PARAMETERS_CHANGED, onParametersChanged);
			addEventListener(ResizeEvent.RESIZE, onResize);
		}

		/**
		 * Called when the component's paramters are set.
		 */

		private function onParametersChanged(event: Event): void
		{
			if (hasParameter("outline"))
			{
				outline_url = getStringParameter("outline");
				if (outline_url != null)
					outline_url = decodeURI(outline_url);
			}
			else
				outline_url = "contents.xml";
			load();
		}

		// **** Accessors

		/**
		 * Sets the outline URL, initiates outline loading.
		 *
		 * @param url URL of outline
		 */

		public function set outline_url(url: String): void
		{
			__outline_url = url;
		}

		/**
		 * Returns the outline URL.
		 *
		 * @return URL of outline XML.
		 */

		public function get outline_url(): String
		{
			return __outline_url;
		}

		// **** Outline Loading

		/**
		 * Loads an outline from a specified URL.
		 */

		protected function load(): void
		{
			var loader: URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onOutlineLoaded);
			loader.load(new URLRequest(__outline_url));
		}

		/**
		 * Called when the outline has been loaded.
		 *
		 * @param event event fired when outline XML is loaded.
		 */

		protected function onOutlineLoaded(event: Event): void
		{
			var xml: XML = new XML(event.target.data);
			__outline = Outline.fromXML(xml);
			__outline.addEventListener(Event.CHANGE, update);
			setupButtons();

			ruler.outline = __outline;

			var start_id: String = getStringParameter("id");
			if (start_id != null)
				__outline.selectById(start_id);
			else
				__outline.selected_index = __outline.items.length - 1;
		}

		// **** Create Child Views

		override protected function createChildren():void
		{
			super.createChildren();
			var ruler_top: int = BUTTON_TOP + 3;

			ruler = new SingleDialRuler();
			ruler.x = MARK_LEFT;
			ruler.y = BUTTON_TOP;
			//ruler.width = 600;
			ruler.percentWidth = 90;
			ruler.height = 25;
			addChild(ruler);

			var left: int = BUTTON_LEFT;

			first_button = new Button();
			first_button.x = left;
			first_button.y = BUTTON_TOP;
			first_button.width = BUTTON_WIDTH;
			first_button.height = BUTTON_HEIGHT;
			first_button.setStyle("icon", rewindIcon);
			addChild(first_button);

			left += BUTTON_WIDTH + BUTTON_GAP;
			previous_button = new Button();
			previous_button.x = left;
			previous_button.y = BUTTON_TOP;
			previous_button.width = BUTTON_WIDTH;
			previous_button.height = BUTTON_HEIGHT;
			previous_button.setStyle("icon", backIcon);
			addChild(previous_button);

			left += BUTTON_WIDTH + BUTTON_GAP;
			next_button = new Button();
			next_button.x = left;
			next_button.y = BUTTON_TOP;
			next_button.width = BUTTON_WIDTH;
			next_button.height = BUTTON_HEIGHT;
			next_button.setStyle("icon", forwardIcon);
			addChild(next_button);

			left += BUTTON_WIDTH + BUTTON_GAP;
			last_button = new Button();
			last_button.x = left;
			last_button.y = BUTTON_TOP;
			last_button.width = BUTTON_WIDTH;
			last_button.height = BUTTON_HEIGHT;
			last_button.setStyle("icon", endIcon);
			addChild(last_button);
		}

		private function setupButtons(): void
		{
			if (__outline == null) throw new Error("Outline not initialized");
			first_button.addEventListener(MouseEvent.CLICK, __outline.first);
			previous_button.addEventListener(MouseEvent.CLICK, __outline.previous);
			next_button.addEventListener(MouseEvent.CLICK, __outline.next);
			last_button.addEventListener(MouseEvent.CLICK, __outline.last);
		}

		// **** Updates

		override protected function updateDisplayList(width: Number, height: Number): void
		{
			super.updateDisplayList(width, height);

			//ruler.setActualSize(width - ruler.x, height);
			//background.setActualSize(width, height);
		}

		private function update(event: Event = null): void
		{
			if (__outline == null) return;
			first_button.enabled = __outline.canFirst();
			previous_button.enabled = __outline.canPrevious();
			next_button.enabled = __outline.canNext();
			last_button.enabled = __outline.canLast();

	        ExternalInterface.call("openPage", __outline.selected.resource);
		}

		// **** View Changes

		/**
		 * Called when the view is resized.
		 *
		 * @param event resize event
		 */

		private function onResize(event: ResizeEvent): void
		{
			//tiled_image.setActualSize(width, height);
		}

	}
}