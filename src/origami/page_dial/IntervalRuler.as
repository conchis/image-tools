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

	import mx.containers.Canvas;
	import mx.controls.Text;

	public class IntervalRuler extends Canvas
	{
		private static const TAB_TOP: int = 18;

		private var __outline: Outline;

		private var tabs: Array = new Array();

		private var label_field: Text;

		private var highlight_tab: IntervalTab;


		public function IntervalRuler()
		{
			setStyle("backgroundColor", 0xFFFFFF);
			this.horizontalScrollPolicy = "off";
		}

		public function set outline(outline: Outline): void
		{
			__outline = outline;
			__outline.addEventListener(Event.CHANGE, onSelectionChange);
			createTabs();

			onSelectionChange();
		}

		public function get outline(): Outline
		{
			return __outline;
		}

		override protected function createChildren(): void
		{
			super.createChildren();
			label_field = new Text();
			label_field.height = 16;
			label_field.width = 500;
			addChild(label_field);
		}

		private function createTabs(): void
		{
			var left: int = 0;
			for each (var item: OutlineItem in outline.root.children)
			{
				var tab_width: int = 20;
				var tab: IntervalTab = new IntervalTab();
				tab.item = item;
				tab.x = left;
				tab.y = TAB_TOP;
				tab.width = tab_width;
				tab.height = 12;
				addChild(tab);

				tabs.push(tab);

				left += tab_width + 3;
			}
		}

		private function measureTabs(): int
		{
			var count: int = 0;
			for each (var item: OutlineItem in outline.root.children)
				count += item.children.length;
			return count;
		}

		private function positionTabs(width: int): void
		{
			if (outline == null) return;

			var count: int = measureTabs();
			var left: int = 0;

			for each (var tab: IntervalTab in tabs)
			{
				var tab_width: int = (width * tab.size) / count;
				tab.x = left;
				tab.width = tab_width;
				left += tab_width;
			}
		}

		private function positionLabel(): void
		{
			if (__outline == null || highlight_tab == null) return;

			if (highlight_tab.x < (width / 2))
				label_field.x = highlight_tab.x - 2;
			else
				label_field.x = (highlight_tab.x + highlight_tab.width) - label_field.textWidth;
		}

		override protected function updateDisplayList(width:Number, height:Number): void
		{
			super.updateDisplayList(width, height);
			positionTabs(width);
			positionLabel();
		}

		private function overTab(): IntervalTab
		{
			if (tabs == null)
				return null;

			for each (var tab: IntervalTab in tabs)
			{
				if (tab.hitTestPoint(mouseX, mouseY))
					return tab;
			}
			return null;
		}

		internal function onSelect(item: OutlineItem): void
		{
			if (item != null)
			{
				__outline.selected = item;
				showChapter(__outline.selected_chapter);
			}
		}

		private function tabForItem(item: OutlineItem): IntervalTab
		{
			var chapter: OutlineItem = item.chapter;
			for each (var tab: IntervalTab in tabs)
			{
				if (tab.item === chapter)
					return tab;
			}
			return null;
		}

		private function showChapter(chapter: OutlineItem): void
		{
			label_field.text = chapter.title;
			var interval_tab: IntervalTab = tabForItem(chapter);
			invalidateDisplayList();
		}

		private function onSelectionChange(event: Event = null): void
		{
			onHighlightTab(null);
		}

		internal function onHighlightTab(tab: IntervalTab): void
		{
			if (tab === highlight_tab) return;

			if (highlight_tab != null)
				highlight_tab.is_selected = false;

			if (tab != null)
			{
				highlight_tab = tab;
				highlight_tab.is_selected = true;
				label_field.text = highlight_tab.item.chapter.title;
			}
			else
			{
				highlight_tab = tabForItem(__outline.selected);
				highlight_tab.is_selected = true;
				label_field.text = highlight_tab.item.chapter.title;
			}

			invalidateDisplayList();
		}

	}
}