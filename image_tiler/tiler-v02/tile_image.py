#!/usr/local/bin/python

from tiled_image import *
from optparse import OptionParser
   
if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-b", "--bgcolor", dest="bgcolor", default = "0xFFFFFF",
            help="background color as an RBG hex number, ex: 0xFFFFFF")
    (options, args) = parser.parse_args()
    bgcolor = eval(options.bgcolor)
    if len(args) < 1:
        parser.error("mising image")
    source_file_path = args[0]
    
    if len(args) < 2:
        tiled_image = TiledImage.fromSourceImage(source_file_path)
    else:
        output_path = args[1]
        tiled_image = TiledImage.fromSourceImage(source_file_path, output_path)
        
    print "\nDone."