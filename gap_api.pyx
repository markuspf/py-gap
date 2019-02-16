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
        self.value = NULL
    def to_python(self):
        pass
    def blafl(self):
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
    def to_python(self):
        cdef Obj i = _unwrap_obj(self)
        cdef Int cint
        cdef const char * pcint
        cdef Int sz
        if GAP_IsSmallInt(i):
            cint = <Int>i
            cint = cint >> 2
            return cint
        else:
            sz = GAP_SizeInt(i)
            sign = 1
            if sz == 0:
                return 0
            elif sz < 0:
                sign = -1
                sz = -sz
            
            sz = 8 * sz # number of bytes
            pcint = <const char *>GAP_AddrInt(i)
            cbytes = pcint[:sz]
            res = int.from_bytes(cbytes, 'little')
            return sign * res

class String(ObjWrap):
    def __init__(self, val):
        cdef Obj r = GAP_MakeString(_to_bytes(val))
        _setup_objwrap(self, r)
    def to_python(self):
        cdef Obj s = _unwrap_obj(self)
        cdef char * cstr = GAP_CSTR_STRING(s)
        py_string = cstr
        return py_string

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
    def __getitem__(self, pos):
        cdef Obj l = _unwrap_obj(self)
        cdef Int p = pos - 1 # Probably best to behave like a python list?
        return _wrap_obj(GAP_ElmList(l, p))
    def __setitem__(self, pos, val):
        cdef Obj l = _unwrap_obj(self)
        cdef Int p = pos - 1
        cdef Obj v = _unwrap_obj(val)
        GAP_AssList(l, p, v)
    def __len__(self):
        cdef Obj l = _unwrap_obj(self)
        return GAP_LenList(l)
    # We could call ViewString for this
    def __repr__(self):
        return "<wrapped GAP list>"
    def __str__(self):
        return "<wrapped GAP list>"

class Record(ObjWrap):
    pass

class Function(ObjWrap):
    def __init__(self, val):
        cdef Obj f = _unwrap_obj(val)
        _setup_objwrap(self, f)
    def __call__(self, *args):
        cdef Obj func = _unwrap_obj(self)
        # Meh
        cdef Obj argl = _unwrap_obj(List(*args))
        return _wrap_obj(GAP_CallFuncList(func, argl))

class Float(ObjWrap):
    pass

cdef void gasman_callback():
    pass

cdef void error_callback():
    pass

def initialize(args, gasman_cb, error_cb, handle_signals):
    cdef int argc = len(args)
    # This is obviously not safe
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
    return _wrap_obj(GAP_CallFuncList(f, a))

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
