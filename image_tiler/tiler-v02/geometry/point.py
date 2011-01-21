class Point:
   """Point class.

   self.x - x value
   self.y - y value
   """
   
   def __init__(self, x = 0, y = 0):
      """Initialize a point"""
      self.x = x
      self.y = y  
      
   def project(self, transform):
      """Project the point into a new coordinate system"""
      from transform import Transform
      assert isinstance(transform, Transform)
      return transform.project(self)
      
   def __eq__(self, other):
      """Determine if two points are equal"""
      if not isinstance(other, Point):
         return False
      if self.x != other.x or self.y != other.y:
         return False
      return True
   
   def __ne__(self, other):
      """Return True if not equal"""
      return not self == other
      
   def __repr__(self):
      """Return a string represenation"""
      return "Point(x=%s, y=%s)" % (self.x, self.y)
   