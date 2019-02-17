from gap_api import *

initialize(['gap', '-l', '/home/mp397/git/gap', '-A', '--nointeract'], None, None, 0)

EvalString(u'Print("Hello, world\\n");')

Print = Function("Print")
LoadPackage = Function("LoadPackage")

s = NewString("Hello, world\n")

lf = NewString("\n")

i = NewInteger(2 ** 128)
i2 = NewInteger(- 2 ** 128)

l = NewList(s,i,lf,i2,lf)

