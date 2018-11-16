
cdef void gasman_callback():
    """
    """
    pass


class GAP:
    def initialize(self): # , argv, env, gasman_cb, error_cb):
        # TODO: find out how argument conversion works...
        GAP_Initialize(4, ['gap', '-l', '/home/mp397/git/gap/', '-A', NULL], [ NULL ], NULL, NULL)

    def EvalString(self, string):
        GAP_EvalString(string)

    def ValueGlobalVariable(self, name):
        return GAP_ValueGlobalVariable(name)

    def EQ(self, a, b):
        return GAP_EQ(a,b)
    def LT(self, a, b):
        return GAP_LT(a,b)
    def IN(self, a, b):
        return GAP_IN(a,b)

    def SUM(self, a, b):
        return GAP_SUM(a, b)
    def DIFF(self, a, b):
        return GAP_DIFF(a,b)
    def PROD(self, a, b):
        return GAP_PROD(a,b)
    def QUO(self, a, b):
        return GAP_QUO(a,b)
    def LQUO(self, a, b):
        return GAP_LQUO(a,b)
    def POW(self, a, b):
        return GAP_POW(a,b)
    def COMM(self, a, b):
        return GAP_COMM(a,b)
    def MOD(self, a, b):
        return GAP_MOD(a,b)


    # GAP_True
    # GAP_False
    # GAP_Fail

    def CallFuncList(self, op, args):
        return GAP_CallFuncList(op, args)
    def CallFuncArray(self, op, args):
        return GAP_CallFuncArray(op, len(args), args)

    def IsInt(self, o):
        return GAP_IsInt(o)
    def IsSmallInt(self, o):
        return GAP_IsSmallInt(o)
    def IsLargeInt(self, o):
        return GAP_IsLargeInt(o)

    def MakeObjInt(self, limbs, size):
        return GAP_MakeObjInt(limbs, size)
    def SizeInt(self, o):
        return GAP_SizeInt(o)
    def AddrInt(self, o):
        return GAP_AddrInt(o)

    def IsList(self, o):
        return GAP_IsList(o)
    def LenList(self, o):
        return GAP_LenList(o)
    def AssList(self, l, v):
        GAP_AssList(l, v)
    def ElmList(self, l, i):
        return GAP_ElmList(l, i)

    def NewPlist(self, cap):
        return GAP_NewPlist(cap)

    def IsString(self, o):
        return GAP_IsString(o)
    def LenString(self, o):
        return GAP_LenString(o)
    def CSTR_STRING(self, s):
        return GAP_CSTR_STRING(self, s)
    def MakeString(self, s):
        return GAP_MakeString(s)
    def MakeImmString(self, s):
        return GAP_MakeImmString(s)


    def ValueOfChar(self, o):
        return GAP_ValueOfChar(o)
    def CharWithValue(self, o):
        return GAP_CharWithValue(o)
