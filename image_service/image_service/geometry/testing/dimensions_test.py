# Copyright 2010 Northwestern University.
#
# Licensed under the Educational Community License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
#    http://www.osedu.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Author Jonathan A. Smith

import unittest
from image_service.geometry.dimensions import *

class DimensionsTest(unittest.TestCase):
   
   def testPoint(self):
      p1 = Dimensions(width = 1, height = 2)
      self.assertEqual(1, p1.width)
      self.assertEqual(2, p1.height)
      
   def testEquals(self):
      d1 = Dimensions(2, 3)
      d2 = Dimensions(3, 4)
      d3 = Dimensions(2, 3)
      self.assertEqual(d1, d3)
      self.assertNotEqual(d1, d2)
   
def suite():
   return unittest.makeSuite(DimensionsTest)
   
if __name__ == "__main__":
   unittest.TextTestRunner(verbosity=2).run(suite())
   
   