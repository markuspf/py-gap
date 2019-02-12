

cdef class GAPObj(object):
    def __init__(self):
        self.value = NULL
    def __hash__(self):
        return <int>(self.value)

cdef GAPObj gap_obj(Obj obj):
    cdef GAPObj r = GAPObj()
    r.value = obj
    return r

cdef void gasman_callback():
    pass

cdef void error_callback():
    pass


cdef Obj _gap_integer(pyint):
    if pyint == 0:
        r = GAP_MakeObjInt([], 0)
    elif pyint < 0:
        pyint = -pyint

    bytec = (pyint.bit_length() + 7) // 8
    limbs = pyint.to_bytes(bytec, 'little')

    cdef char * climbs = limbs
    return GAP_MakeObjInt(<UInt *>climbs, bytec)

def gap_integer(pyint):
    return gap_obj(_gap_integer(pyint))



cdef gap_to_python(GAPObj obj):
    return None

cdef python_to_gap(obj):
    return gap_obj(NULL)

class GAP:
    def initialize(self, args, gasman_cb, error_cb, handle_signals):
        cdef int argc = len(args)
        cdef char* argv[128]

        for i in xrange(argc):
            args[i] = bytes(args[i], 'utf-8')
            argv[i] = args[i]

        argv[argc] = NULL

        cdef GAP_CallbackFunc mcb = &gasman_callback
        cdef GAP_CallbackFunc ecb = &error_callback
        cdef int hsg = handle_signals

        GAP_Initialize(argc, argv, &gasman_callback, &error_callback, hsg)

    def EvalString(self, string):
        return gap_obj(GAP_EvalString(bytes(string, 'utf-8')))

    def ValueGlobalVariable(self, name):
        return gap_obj(GAP_ValueGlobalVariable(name))

    def MakeObjInt(self, pyint):
        return gap_obj(_gap_integer(pyint))

#    def EQ(self, a, b):
#        return GAP_EQ(a,b)
#    def LT(self, a, b):
#        return GAP_LT(a,b)
#    def IN(self, a, b):
#        return GAP_IN(a,b)
#
#    def SUM(self, a, b):
#        return GAP_SUM(a, b)
#    def DIFF(self, a, b):
#        return GAP_DIFF(a,b)
#    def PROD(self, a, b):
#        return GAP_PROD(a,b)
#    def QUO(self, a, b):
#        return GAP_QUO(a,b)
#    def LQUO(self, a, b):
#        return GAP_LQUO(a,b)
#    def POW(self, a, b):
#        return GAP_POW(a,b)
#    def COMM(self, a, b):
#        return GAP_COMM(a,b)
#    def MOD(self, a, b):
#        return GAP_MOD(a,b)
#
#
#    # GAP_True
#    # GAP_False
#    # GAP_Fail
#
#    def CallFuncList(self, op, args):
#        return GAP_CallFuncList(op, args)
#    def CallFuncArray(self, op, args):
#        return GAP_CallFuncArray(op, len(args), args)
#
#    def IsInt(self, o):
#        return GAP_IsInt(o)
#    def IsSmallInt(self, o):
#        return GAP_IsSmallInt(o)
#    def IsLargeInt(self, o):
#        return GAP_IsLargeInt(o)
#
#    def MakeObjInt(self, limbs, size):
#        return GAP_MakeObjInt(limbs, size)
#    def SizeInt(self, o):
#        return GAP_SizeInt(o)
#    def AddrInt(self, o):
#        return GAP_AddrInt(o)
#
#    def IsList(self, o):
#        return GAP_IsList(o)
#    def LenList(self, o):
#        return GAP_LenList(o)
#    def AssList(self, l, v):
#        GAP_AssList(l, v)
#    def ElmList(self, l, i):
#        return GAP_ElmList(l, i)
#
#    def NewPlist(self, cap):
#        return GAP_NewPlist(cap)
#
#    def IsString(self, o):
#        return GAP_IsString(o)
#    def LenString(self, o):
#        return GAP_LenString(o)
#    def CSTR_STRING(self, s):
#        return GAP_CSTR_STRING(self, s)
#    def MakeString(self, s):
#        return GAP_MakeString(s)
#    def MakeImmString(self, s):
#        return GAP_MakeImmString(s)
#
#
#    def ValueOfChar(self, o):
#        return GAP_ValueOfChar(o)
#    def CharWithValue(self, o):
#        return GAP_CharWithValue(o)
