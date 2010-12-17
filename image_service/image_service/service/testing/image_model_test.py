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

from sqlalchemy import create_engine

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm.session import sessionmaker

Base = declarative_base()

from image_service.service.image_model import ImageModel

class ImageModelTest(unittest.TestCase):

    def setUp(self):
        print "setup.."
        #engine = create_engine('sqlite:///data/test.db', echo=True)
        engine = create_engine('sqlite://', echo=True)
        Session = sessionmaker(bind=engine)
        self.session = Session()
        ImageModel.metadata.create_all(engine)

    def testOme(self):
        session = self.session
        m1 = ImageModel("image.jpg")
        m2 = ImageModel("somwhere.jpg")
        session.add_all([m1, m2])
        session.commit()
        id1 = m1.id
        id2 = m2.id
        r1 = session.query(ImageModel).filter(ImageModel.id == id1).one()
        r2 = session.query(ImageModel).filter(ImageModel.id == id2).one()
        self.assertEqual(m1.id, r1.id)
        self.assertEqual(m1.image_url, r1.image_url)
        self.assertEqual(m2.id, r2.id)
        self.assertEqual(m2.image_url, r2.image_url)