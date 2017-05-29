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

    def __init__(self, config_dir, name, version=None, config_data=None):
        """Initialize package specifications from a file, a dictionary, or
           a string"""

        # Load package information
        self.name = name
        self.cfg = configparser.ConfigParser()
        if ( config_data is None ):
            config_file = os.path.join(config_dir, "%s.cfg" % name)
            if ( os.path.exists(config_file) ):
                self.cfg.read(config_file)
        elif ( isinstance(config_data, dict) ):
            self.cfg.read_dict(config_data)
        else:
            self.cfg.read_string(config_data)
        self.defaults = self.cfg.defaults()
        self.pkg_versions = self.cfg.sections()
        self.pkg_versions.sort()
        self.pkg_versions.reverse()

        # Check that mandatory options are present
        fbk_miss = [item for item in fbk_mandatory_options \
            if not item in self.defaults]
        if ( len(fbk_miss) > 0 ):
            raise KeyError("missing parameters: %s" % fbk_miss)
        assert ( self.name == self.defaults["name"] )

        # Check that the default version is indeed described in the file
        if ( not self.defaults["default_version"] in self.pkg_versions ):
            raise ValueError("invalid default version")

        # We only accept numerical versions for now
        for pkg_version in self.pkg_versions:
            try:
                chk_ver = [int(item) for item in pkg_version.split(".")]
            except ValueError:
                raise NotImplementedError("non-numeric package versions are not supported")

        # Select requested version
        self.version = version
        if ( version is None ):
            self.version = self.defaults["default_version"]
        elif ( not version in self.pkg_versions ):
            raise KeyError("missing package version '%s/%s'" % \
                (self.name, version))

        # Import relevant package information
        self.specs = self.cfg[self.version]


    def __str__(self):

        return "Abinit Fallback Package: %s/%s\nCodename: %s\nDependencies: %s" % \
            (self.name, self,version, self.encode(), self.get_deps())


    def encode(self, version=None):
        """Encode the package name and version number to customize the
           installation path of its reverse dependencies"""

        if ( version is None ):
            ret = self.defaults["abbrev"]
            my_version = self.defaults["default_version"]
        else:
            ret = self.cfg.get(version, "abbrev")
            my_version = version

        for item in my_version.split("."):
            ret += "%2.2x" % int(item)

        return ret


    def get_item(self, item, version=None):
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


    def get_specs(self, version=None):
        """Return a dictionary containing the specifications of the package"""

        if ( version is None ):
            my_version = self.defaults["default_version"]
        else:
            my_version = version

        return dict(self.cfg[my_version])

