#!/usr/bin/env python3

import os
import unittest

from abinit.fallbacks.package import FallbackPackage


                    ########################################


# Default parameters
default_cfgdir = os.path.join("config", "specs")

# File specifications for the tests
yaml_specs_dir = os.path.join("abinit", "fallbacks", "tests")

# Dict specifications for the test
yaml_specs_dict = dict(
    [('DEFAULT', dict([('name', 'yaml'), ('abbrev', 'YL'), ('default_version', '0.1.6'), ('description', "YAML Ain't Markup Language library"), ('headers', '\nyaml.h'), ('libraries', '\nlibyaml.a'), ('languages', 'C'), ('pkgconfig', 'yes')])),
     ('0.1.6', {'abbrev': 'YL', 'pkgconfig': 'yes', 'headers': '\nyaml.h', 'default_version': '0.1.6', 'description': "YAML Ain't Markup Language library", 'urls': '\nhttp://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz\nhttp://forge.abinit.org/fallbacks/yaml-0.1.6.tar.gz', 'libraries': '\nlibyaml.a', 'name': 'yaml', 'md5sum': '5fe00cda18ca5daeb43762b80c38e06e', 'languages': 'C'})]
)

# String specifications for the tests
yaml_specs_string = """\
[DEFAULT]
name = yaml
abbrev = YL
default_version = 0.1.6
description = YAML Ain't Markup Language library
headers =
  yaml.h
libraries =
  libyaml.a
languages = C
pkgconfig = yes

[0.1.6]
urls =
  http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz
  http://forge.abinit.org/fallbacks/yaml-0.1.6.tar.gz
md5sum = 5fe00cda18ca5daeb43762b80c38e06e
"""


                    ########################################


class TestFallbackPackage(unittest.TestCase):

    def test_init_read_config_file(self):

        x = FallbackPackage(yaml_specs_dir, "yaml")

        assert ( x.name == "yaml")
        assert ( x.version == "0.1.6" )


    def test_init_read_config_dict(self):

        x = FallbackPackage(yaml_specs_dir, "yaml", config_data=yaml_specs_dict)

        assert ( x.name == "yaml")
        assert ( x.version == "0.1.6" )


    def test_init_read_config_string(self):

        x = FallbackPackage(yaml_specs_dir, "yaml", config_data=yaml_specs_string)

        assert ( x.name == "yaml")
        assert ( x.version == "0.1.6" )

