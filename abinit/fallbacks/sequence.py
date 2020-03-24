#!/usr/bin/env python3

import configparser
import os

def ConvertVersion2Number(v):   # 8.8 to 808
    Maj,Min=v.split(".")
    if len(Min) == 1:
        Min='0'+Min
    return Maj+Min

def ConvertNumber2Version(a):   # 812 to 8.12
    Min=a[-2:]
    if Min == "00":
       Min="0"
    else:
       if Min[0] == "0" :
          Min=Min[1]
    Maj=a[:-2]
    return "%s.%s" % (Maj,Min)


                    ########################################


class FallbackSequence(object):
    """Define an ordered sequence to process fallbacks"""

    def __init__(self, config_dir, abinit_version=None, fbk_filter=None, config_data=None):
        """Initialize sequence specifications from a file, a dictionary, or
           a string"""

        # Load sequence information
        self.cfg = configparser.ConfigParser()
        if ( config_data is None ):
            config_file = os.path.join(config_dir, "fallbacks.cfg")
            if ( os.path.exists(config_file) ):
                self.cfg.read(config_file)
        elif ( isinstance(config_data, dict) ):
            self.cfg.read_dict(config_data)
        else:
            self.cfg.read_string(config_data)
        self.versions = self.cfg.sections()
        # search the lastest version
        self.versions = list(map(ConvertVersion2Number, self.versions))
        self.versions = sorted(self.versions, reverse=True)
        self.versions = list(map(ConvertNumber2Version, self.versions))

        # Check presence of Abinit version
        self.abinit_version = abinit_version
        if ( abinit_version is None ):
            self.abinit_version = self.versions[0]
        elif ( not abinit_version in self.versions ):
            raise KeyError("missing Abinit version %s" % abinit_version)

        # Look for package descriptions
        self.fbk_list = {}
        fbk_list = fbk_filter
        if ( fbk_filter is None ):
            fbk_list = self.cfg.options(self.abinit_version)
        for fbk in fbk_list:
            if ( self.cfg.has_option(self.abinit_version, fbk)):
                self.fbk_list[fbk] = self.cfg.get(self.abinit_version, fbk)
            else:
                raise KeyError("unknown fallback '%s'" % fbk)


    def __str__(self):

        return "Abinit Fallback Sequence:\n  * " + \
            "\n  * ".join(["%s/%s" % (key, val) for key, val in self.fbk_list.items()])


    def sort_packages(self):
        """Set build order of fallbacks according to their dependencies"""

        # Increment package indices for each package and each of its
        # dependencies
        all_deps = {}
        pkg_num = zip(pkg_list, range(len(pkg_list)))
        for i in range(len(pkg_list)):
            for pkg in pkg_list:
                if ( cnf.has_option(pkg,"depends") ):
                    all_deps[pkg] = cnf.get(pkg,"depends").split()
                    pkg_deps = all_deps[pkg]
                    for dep in pkg_deps:
                        if ( pkg_num[dep] >= pkg_num[pkg] ):
                            pkg_num[pkg] = pkg_num[dep] + 1
                else:
                    all_deps[pkg] = None
        pkg_ranks = pkg_num.values()
        pkg_ranks = list(set(pkg_ranks))
        pkg_ranks.sort()

        # Build package list in the correct order
        abinit_fallbacks = []
        for rnk in pkg_ranks:
            for pkg in pkg_num:
                if ( pkg_num[pkg] == rnk ):
                    abinit_fallbacks.append(pkg)

