# py-gap

Python bindings for GAP. Uses Cython. Is just done.

## Running

Bit messy at the moment. You need a GAP build (I use the `master` branch), just
configured and built in the way documented at `https://github.com/gap-system/gap`.

Build this heap of code (you'll need to adjust setup.py to point to your GAP installation atm,
patches welcome to make that slightly less awkward).
```
python3 setup.py build_ext --inplace
```

run it.

```
env LD_LIBRARY_PATH=/home/mp397/git/gap/.libs python3 demo.py
```


