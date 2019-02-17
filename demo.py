from gap_api import *

initialize(['gap', '-l', '/home/mp397/git/gap', '-A', '--nointeract'], None, None, 0)

EvalString(u'Print("Hello, world\\n");')

Print = Function("Print")
LoadPackage = Function("LoadPackage")

s = String("Hello, world\n")
lf = String("\n")

i = Integer(2 ** 128)
i2 = Integer(- 2 ** 128)

l = List(s,i,lf,i2,lf)

