import types

class Dimensions:
   """Dimensions class.
   
   self.width - width value
   self.height - height value
   """
   
   def __init__(self, width = 0, height = 0):
      """Initialize dimensions"""
      self.width = width
      self.height = height 
      
   def __eq__(self, other):
      """Test if two dimensions objects are equal"""
      if not isinstance(other, Dimensions):
         return False
      if self.width != other.width or self.height != other.height:
         return False
      return True
   
   def __ne__(self, other):
      """Return true if not equal"""
      return not self == other
      
   def __repr__(self):
      """Return a string represenation"""
      return "Dimensions(width=%s, height=%s)" % (self.width, self.height)
   