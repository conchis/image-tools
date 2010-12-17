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
	import flash.display.Graphics;
	import flash.events.MouseEvent;

	import mx.containers.Canvas;

	public class IntervalTab extends Canvas
	{
		private var __item: OutlineItem;

		private var __selected: Boolean;

		public function IntervalTab()
		{
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);
		}

		public function set item(item: OutlineItem): void
		{
			__item = item;
		}

		public function get item(): OutlineItem
		{
			return __item;
		}

		public function get text(): String
		{
			if (__item == null) return "";
			return __item.title;
		}

		public function get size(): int
		{
			if (__item == null) return 0;
			return __item.children.length;
		}

		public function set is_selected(selected: Boolean): void
		{
			if (selected == __selected) return;
			__selected = selected;
			invalidateDisplayList();
		}

		public function get is_selected(): Boolean
		{
			return __selected;
		}

		override protected function updateDisplayList(width:Number, height:Number): void
		{
			super.updateDisplayList(width, height);

			var graphics: Graphics = this.graphics;

			if (__selected)
			{
				graphics.beginFill(0x000000);
				graphics.lineStyle(0, 0x000000, 1, true);
				graphics.drawRect(0, 0, width - 1, height - 1);
				graphics.endFill();
			}
			else
			{
				graphics.beginFill(0xFFFFFF);
				graphics.lineStyle(0, 0x000000, 1, true);
				graphics.drawRect(0, 0, width - 1, height - 1);
				graphics.endFill();
			}
		}

		private function onMouseMove(event: MouseEvent): void
		{
			IntervalRuler(parent).onHighlightTab(this);
		}

		private function onMouseOut(event: MouseEvent): void
		{
			IntervalRuler(parent).onHighlightTab(null);
		}

		private function onClick(event: MouseEvent): void
		{
			IntervalRuler(parent).onSelect(item);
		}
	}
}