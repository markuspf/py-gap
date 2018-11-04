from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


# we could support just building GAP
# otherwise we'll have to work out a way to
# detect paths
extensions = [
            Extension("gap_api", ["gap_api.pyx"],
            include_dirs=['/home/mp397/git/gap/src',
                          '/home/mp397/git/gap/bin/x86_64-pc-linux-gnu-default64-kv6/'],
            libraries=['gap'],
            library_dirs=['/home/mp397/git/gap/.libs']),
        ]

setup(name='GAP Python bindings',
      ext_modules=cythonize(extensions))

