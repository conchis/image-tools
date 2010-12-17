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

from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()
class ImageModel(Base):
    __tablename__ = 'images'

    id          = Column(Integer, primary_key=True)
    image_url   = Column(String, index=True, unique=True)
    is_tiled    = Column(Boolean, default=False)
    created     = Column(DateTime)

    def __init__(self, image_url):
        self.image_url = image_url
        self.created = datetime.now()

    def __repr__(self):
        return "<ImageModel({}, {})>".format(self.id, self.image_url)