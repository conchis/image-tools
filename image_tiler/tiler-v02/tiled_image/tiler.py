class Tiler:
   """Creates or adds tiles to a tiled image"""
   
   def __init__(self, tiled_image):
      self.tiled_image = tiled_image
   
   def tileLayer(self, layer_number):
      """Generate all tiles in a specified tile layer"""
      raise "Implement in subclasses"