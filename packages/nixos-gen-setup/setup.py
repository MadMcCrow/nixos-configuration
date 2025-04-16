#!/usr/bin/env python
# build script for nixos-gen-setup
from setuptools  import setup, find_packages

_pname    = 'nixosgensetup'       # program name
_srcdir   = 'src'                   # where are located the python sources
_modname  = _pname.replace('-', '') # python module name
_packages = find_packages()

print(_packages)
# ['cli', 'private', 'private.singletons', 'private.volumes', 'private.filesystems']

setup(  
    name=_modname,
    version='1.0',
    description='Script to generate a bash install script for a nixos machine',
    author='MadMcCrow',
    #package_dir={ '': 'nixosgensetup' },
    packages= _packages ,
    entry_points={
        'console_scripts': [
            f'{_pname} = nixosgensetup:main'
        ]
    },
)