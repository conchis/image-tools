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

import sys, os, urlparse, re, httplib

import cherrypy
from cherrypy.lib.static import serve_file
from cherrypy._cperror import HTTPRedirect

HOME_DIRECTORY     = '/Users/jonathan/Projects/image_service'
RESOURCE_DIRECTORY = os.path.join(HOME_DIRECTORY, "resources")
IMAGE_DIRECTORY    = os.path.join(HOME_DIRECTORY, "images")
IMAGE_CACHE        = os.path.join(HOME_DIRECTORY, "cache")

# Import modules
sys.path.append(HOME_DIRECTORY)
from image_service.tiled_image.tiled_image import TiledImage

REQUEST_PATTERN = re.compile(
        '.*/(contents.xml|thumbnail.jpg|layer[0-9]+/tile[0-9n]+\.jpg)')

IMAGE_EXTENSIONS = re.compile(r'(\.jpg|\.jpeg|\.png|\.gif|\.tif|\.tiff)\W*$')

# http://localhost:8888/upload.wikimedia.org/wikipedia/commons/1/10/Aqueduct_of_Segovia_02.jpg

class ImageService(object):

    @cherrypy.expose
    def index(self):
        return "<h1>Image Service</h1>"

    @cherrypy.expose
    def default(self, *tokens, **parameters):
        last_token = tokens[-1]
        if last_token  == 'viewer.swf' or last_token  == 'index.html':
            return serve_file(os.path.join(RESOURCE_DIRECTORY, last_token))

        try:
            request_url = "http://" + "/".join(tokens)
            (domain, port, path, request) = self.parse_url(request_url)
        except httplib.InvalidURL:
            raise HTTPRedirect(cherrypy.request.path_info + "/index.html")

        cache_path = os.path.join(IMAGE_CACHE, domain, path[1:])
        tile_path  = os.path.join(IMAGE_DIRECTORY, domain, path[1:])
        if not os.path.exists(os.path.join(tile_path, 'contents.xml')):
            self.cache_image(domain, port, path, cache_path)
            TiledImage.fromSourceImage(cache_path, tile_path)
        file_path = os.path.join(tile_path, request)
        return serve_file(file_path)

    def parse_url(self, url):
        matches = REQUEST_PATTERN.match(url)
        if not matches:
            raise httplib.InvalidURL(url)
        request_path = matches.group(1)
        image_url = url[0:len(url) - len(request_path) - 1]
        split_url = urlparse.urlsplit(image_url)
        pair = split_url.netloc.split(":")
        if len(pair) == 1:
            (domain, port) = pair[0], 80
        else:
            (domain, port) = pair
        return (domain, port, split_url.path, request_path)

    def cache_image(self, domain, port, path, cache_path):
        image_data = self.load_image(domain, port, path)
        cache_directory = os.path.dirname(cache_path)
        if not os.path.exists(cache_directory):
            os.makedirs(cache_directory)
        out = open(cache_path, "w")
        out.write(image_data)
        out.close()

    def load_image(self, domain, port, path):
        if not IMAGE_EXTENSIONS.findall(path):
            path += "/"
        connection = httplib.HTTPConnection(domain, port)
        connection.request("GET", path)
        response = connection.getresponse()
        print response.status, response.reason
        image_data = response.read()
        connection.close()
        return image_data

if __name__ == '__main__':
    cherrypy.config.update('service.ini')
    cherrypy.quickstart(ImageService(), '/', config='service.ini')
