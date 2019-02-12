from gap_api import *

g = GAP()
g.initialize(['gap', '-l', '/home/mp397/git/gap', '-A', '--nointeract'], None, None, 0)
g.EvalString('Print("Hello, world\\n");')

