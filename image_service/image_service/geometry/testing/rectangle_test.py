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
from image_service.geometry.rectangle import *
from image_service.geometry.point import *
from image_service.geometry.dimensions import *
from image_service.geometry.transform import *

class RectangleTest(unittest.TestCase):
   
   def testCoordinates(self):
      r = Rectangle(0, 0, 100, 100)
      self.assertEqual(Point(0, 0), r.getTopLeft())
      self.assertEqual(Point(100, 100), r.getBottomRight()) 
      
   def testSetTopLeft(self):
      r = Rectangle(0, 0, 100, 100)
      r.setTopLeft(Point(100, 100))
      self.assertEqual(100, r.left)
      self.assertEqual(100, r.top)
      self.assertEqual(200, r.right)
      self.assertEqual(200, r.bottom)
      
   def testEqual(self):
      r1 = Rectangle(0, 0, 100, 100)
      r2 = Rectangle(1, 0, 101, 100)
      r3 = Rectangle(0, 0, 100, 100)
      self.assertEqual(r1, r3)
      self.assertNotEqual(r1, r2)
      
   def testDimensions(self):
      r1 = Rectangle(0, 0, 8, 16)
      r2 = Rectangle(-1, -1, 1, 1)
      self.assertEqual(Dimensions(8, 16), r1.getDimensions())
      self.assertEqual(Dimensions(2, 2), r2.getDimensions())
      
   def testSetDimensions(self):
      r = Rectangle(20, 20, 50, 82)
      r.setDimensions(Dimensions(10, 10))
      self.assertEqual(Point(20, 20), r.getTopLeft())
      self.assertEqual(Point(30, 30), r.getBottomRight())
      
   def testOverlaps(self):
      r1 = Rectangle(0, 0, 100, 100)
      r2 = Rectangle(200, 200, 210, 210)
      r3 = Rectangle(99, 99, 109, 109)
      self.assert_(not r1.overlaps(r2))
      self.assert_(not r2.overlaps(r1))
      self.assert_(r1.overlaps(r3))
      self.assert_(r3.overlaps(r1))
 
   def testContains(self):
      r1 = Rectangle(0, 0, 100, 100)
      r2 = Rectangle(5, 5,  10,  10)
      r3 = Rectangle(101, 0, 201, 100)
      r4 = Rectangle(5, 5, 101, 10)
      self.assert_(r1.contains(r2))
      self.assert_(not r2.contains(r1))
      self.assert_(not r1.contains(r3))
      self.assert_(not r3.contains(r1))
      self.assert_(not r1.contains(r4))
      self.assert_(not r4.contains(r1))
      
   def testContainsPoint(self):
      r1 = Rectangle(0, 0, 10, 10)
      self.assert_(r1.containsPoint(Point(0,0)))
      self.assert_(r1.containsPoint(Point(10, 10)))
      self.assert_(not r1.containsPoint(Point(100, 100)))
      self.assert_(not r1.containsPoint(Point(3, 10.1)))
      
   def testProject(self):
      t = Transform.makeTranslate(10, 10).compose(Transform.makeScale(2, 2))
      r1 = Rectangle(0, 0, 5, 5)
      r2 = r1.project(t)
      self.assertEqual(Rectangle(10, 10, 20, 20), r2)
      
   def testInset(self):
      r1 = Rectangle(-10, -10, 110, 110)
      r2 = r1.inset(Dimensions(10, 10))
      self.assertEqual(Rectangle(0, 0, 100, 100), r2)
      
   def testInsersect(self):
      r1 = Rectangle(0, 0, 10, 10)
      r2 = Rectangle(5, 5, 20, 20)
      self.assertEqual(Rectangle(5, 5, 10, 10), r1.intersect(r2))
      self.assertEqual(r1.intersect(r2), r2.intersect(r1))

   def testExtend(self):
      r1 = Rectangle(0, 0, 10, 10)
      r2 = Rectangle(5, 5, 20, 20)
      self.assertEqual(Rectangle(0, 0, 20, 20), r1.extend(r2))
      self.assertEqual(r1.extend(r2), r2.extend(r1))
      
   def testCenter(self):
       r1 = Rectangle(0, 0, 10, 10)
       self.assertEqual(Point(5, 5), r1.getCenter())
      
def suite():
   return unittest.makeSuite(RectangleTest)
   
if __name__ == "__main__":
   unittest.TextTestRunner(verbosity=2).run(suite())
   
   
   