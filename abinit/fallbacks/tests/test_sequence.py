#!/usr/bin/env python3

import os
import unittest

from abinit.fallbacks.sequence import FallbackSequence


                    ########################################


# Default parameters
default_cfgdir = os.path.join("config", "specs")
abinit_versions = ["8.%d" % i for i in range(5,-1,-1)]


                    ########################################


class TestFallbackSequence(unittest.TestCase):

    def test_init_read_config_file(self):

        x = FallbackSequence(default_cfgdir)

        assert ( x.versions == abinit_versions )

