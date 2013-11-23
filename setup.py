#!/usr/bin/env python

import os
import sys

from setuptools import setup
from distutils.core import Command
from subprocess import call


class NoseCommand(Command):
    description = "run test suite"
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        status = self._run_tests()
        sys.exit(status)

    def _run_tests(self):
        try:
            import nose
            nose
        except ImportError:
            print('Missing "nose" library. You can install it using pip: '
                  "pip install nose")
            sys.exit(1)

        retcode = call("nosetests")
        sys.exit(retcode)
        return not res.wasSuccessful()


class Pep8Command(Command):
    description = "run pep8 script"
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        try:
            import pep8
            pep8
        except ImportError:
            print('Missing "pep8" library. You can install it using pip: '
                  "pip install pep8")
            sys.exit(1)

        cwd = os.getcwd()
        retcode = call(("pep8 %s/groove/ %s/tests/ %s/setup.py" %
                        (cwd, cwd, cwd)).split(" "))
        sys.exit(retcode)


setup(
    name="Groove-dl",
    version="0.1",
    description="Grooveshark song downloader",
    author="Pierre Rambaud (GoT)",
    author_email="pierre.rambaud86@gmail.com",
    url="https://github.com/PierreRambaud/groove-dl",
    license="GPLv3",
    scripts=["groove-dl"],
    packages=["groove"],
    install_requires=[],
    tests_require=[
            "mock",
            "nose",
            "pep8"
        ],
    cmdclass={
        "pep8": Pep8Command,
        "nose": NoseCommand
        },
    )
