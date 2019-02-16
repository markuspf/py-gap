# cython: c_string_type=unicode, c_string_encoding=utf-8

# Helper to handle stringy inputs
cdef char * _to_bytes(string):
    py_bytes = string.encode('utf-8')
    cdef char * cstring = py_bytes
    return cstring

cdef _setup_objwrap(ObjWrap go, Obj o):
    go.value = o

cdef Obj _unwrap_obj(ObjWrap gobj):
    cdef Obj r = gobj.value
    return r

cdef ObjWrap _wrap_obj(Obj o):
    go = ObjWrap()
    _setup_objwrap(go, o)
    return go

cdef class ObjWrap(object):
    def __init__(self):
        pass
    def to_python(self):
        pass
    def __hash__(self):
        return <unsigned long>(self.value)

class Integer(ObjWrap):
    def __init__(self, val):
        cdef Obj r
        cdef char * climbs

        sign = 1
        if val == 0:
            _setup_objwrap(self, GAP_MakeObjInt([], 0))
            return
        elif val < 0:
            sign = -1
            val = -val

        # number of limbs, a limb is 8 bytes
        nlimbs = ((val.bit_length() + 7) // 8 + 7) // 8
        limbs = val.to_bytes(8 * nlimbs, 'little')
        # TODO: Why does cython make me do this dance?
        climbs = limbs

        r = GAP_MakeObjInt(<const UInt *>climbs, sign * nlimbs)
        _setup_objwrap(self, r)

class String(ObjWrap):
    def __init__(self, val):
        cdef Obj r = GAP_MakeString(_to_bytes(val))
        _setup_objwrap(self, r)
    def to_python(self):
        return "blabla"

class Permutation(ObjWrap):
    def __init__(self, val):
        self.value = None

class List(ObjWrap):
    def __init__(self, *args):
        cdef Int i
        cdef Int nargs = len(args)
        cdef Obj r
        cdef Obj v
        r = GAP_NewPlist(nargs)
        for i in range(nargs):
            v = _unwrap_obj(args[i])
            GAP_AssList(r, i+1, v)
        _setup_objwrap(self, r)

    def __repr__(self):
        return "<wrapped GAP list>"
    def __str__(self):
        return "<wrapped GAP list>"

class Record(ObjWrap):
    pass

class Function(ObjWrap):
    pass

class Float(ObjWrap):
    pass

cdef void gasman_callback():
    pass

cdef void error_callback():
    pass

def initialize(args, gasman_cb, error_cb, handle_signals):
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

def EvalString(cmd):
    return _wrap_obj(GAP_EvalString(_to_bytes(cmd)))

def ValueGlobalVariable(name):
    return _wrap_obj(GAP_ValueGlobalVariable(_to_bytes(name)))

def CallFuncList(ObjWrap func, ObjWrap args):
    cdef Obj f = _unwrap_obj(func)
    cdef Obj a = _unwrap_obj(args)
    GAP_CallFuncList(f, a)

# Possible to deduplicate this?
def EQ(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return GAP_EQ(ca, cb)

def LT(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return GAP_LT(ca, cb)

def IN(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return GAP_IN(ca, cb)

def SUM(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_SUM(ca, cb))

def DIFF(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_DIFF(ca, cb))

def PROD(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_PROD(ca, cb))

def QUO(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_QUO(ca, cb))

def LQUO(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_LQUO(ca, cb))

def POW(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_POW(ca, cb))

def COMM(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_COMM(ca, cb))

def MOD(ObjWrap a, ObjWrap b):
    cdef Obj ca = _unwrap_obj(a)
    cdef Obj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_MOD(ca, cb))

#    Obj GAP_True
#    Obj GAP_False
#    Obj GAP_Fail
#
