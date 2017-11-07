#!/usr/bin/env python3
# encoding: utf-8

import os
import sys

import configparser


                    ########################################


fbk_mandatory_options = (
    "abbrev",
    "default_version",
    "name")

                    ########################################


class FallbackPackage(object):
    """Store information about a package and its available versions"""

    def __init__(self, config_data):
        """Initialize package specifications from a file, a dictionary, or
           a string"""

        # Get package information from config file
        self.cfg = configparser.ConfigParser()
        if ( os.path.exists(config_data) ):
            self.cfg.read(config_data)
        elif ( isinstance(config_data, dict) ):
            self.cfg.read_dict(config_data)
        else:
            self.cfg.read_string(config_data)
        self.defaults = self.cfg.defaults()
        self.versions = self.cfg.sections()

        # Check that mandatory options are present
        fbk_miss = [item for item in fbk_mandatory_options \
            if not item in self.defaults]

        # Check that the default version is indeed described in the file
        if ( not self.defaults["default_version"] in self.versions ):
            raise ValueError("invalid default version")

        # We only accept numerical versions for now
        for version in self.versions:
            try:
                chk_ver = [int(item) for item in version.split(".")]
            except ValueError:
                raise NotImplementedError("non-numeric package versions are not supported yet")


    def encode_package(self, version=None):
        """Encode the package name and version number to customize the
           installation path of its reverse dependencies"""

        if ( version is None ):
            ret = self.defaults["abbrev"]
            my_version = self.defaults["default_version"]
        else:
            ret = self.cfg.get(version, "abbrev")
            my_version = version

        for item in my_version.split("."):
            ret + = "%2.2x" % int(item)

        return ret


    def get(self, item, version=None):
        """Return a piece of information from the package, or None
           if it does not exist"""

        if ( version is None ):
            my_version = self.defaults["default_version"]
        else:
            my_version = version

        if ( self.cfg.has_option(my_version, item) ):
            return self.cfg.get(my_version, item)
        else:
            return None

