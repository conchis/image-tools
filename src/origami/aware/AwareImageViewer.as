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

package origami.aware
{
	import origami.viewer.ImageViewer;
	import origami.tiled_image.ImageModel;

	public class AwareImageViewer extends ImageViewer
	{
		public function AwareImageViewer()
		{
			super();
		}

		/**
		 * Method to create the image model and start it's initialization.
		 * Override this to create a different ImageModel object.
		 *
		 * @return new AwareImageModel object
		 */

		override protected function makeImageModel(): ImageModel
		{
			return new AwareImageModel();
		}

	}
}