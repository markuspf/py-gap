from gap_api cimport Obj as CObj
from gap_api cimport ObjWrap as Obj

# cython: c_string_type=unicode, c_string_encoding=utf-8

# Helper to handle stringy inputs
cdef char * _to_bytes(string):
    py_bytes = string.encode('utf-8')
    cdef char * cstring = py_bytes
    return cstring

cdef _setup_objwrap(Obj go, CObj o):
    go.value = o

cdef CObj _unwrap_obj(Obj gobj):
    cdef CObj r = gobj.value
    return r

# TODO: Sensible?
#       Do we need to wrap this in GAP_EnterStack/GAP_LeaveStack?
cdef Obj _wrap_obj(CObj o):
    go = None
    if GAP_IsInt(o):
        go = Integer()
    elif GAP_IsString(o):
        go = String()
    elif GAP_IsList(o):
        go = List()
    else:
        go = Obj()
    _setup_objwrap(go, o)
    return go

cdef class Obj(object):
    def __init__(self):
        self.value = NULL
    def from_python(self, val):
            pass
    def to_python(self):
        pass
    def __repr__(self):
        # Should be calling ViewString or somesuch
        return "A GAP object"
    def __hash__(self):
        return <unsigned long>(self.value)

def NewInteger(val):
    int = Int()
    int.from_python(val)
    return int

class Integer(Obj):
    def from_python(self, val):
        cdef CObj r
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
        cdef CObj i = _unwrap_obj(self)
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

# TODO: Immutable strings?
def NewString(val):
    str = String()
    str.from_python(val)
    return str

class String(Obj):
    def from_python(self, val):
        cdef CObj r
        GAP_EnterStack()
        try:
            r = GAP_MakeString(_to_bytes(val))
        finally:
            GAP_LeaveStack()
            _setup_objwrap(self, r)
    def to_python(self):
        cdef CObj s = _unwrap_obj(self)
        cdef char * cstr
        GAP_EnterStack()
        try:
            cstr = GAP_CSTR_STRING(s)
        finally:
            py_string = cstr
            GAP_LeaveStack()
            return py_string
    def __repr__(self):
        return "<GAP String: %s>" % (self.to_python())

# TODO: As an initial hack we could call "PermList" and
#       "ListPerm" on
#       a list of images. Otherwise we'll have to define
#       an api that can create PERM4 and PERM2
class Permutation(Obj):
    def from_python(self, val):
        pass
    def to_python(self):
        pass

# TODO: Allow initialisation from Python list
def NewList(val):
    l = List()
    l.from_python(val)
    return l

class List(Obj):
    def from_python(self, *args):
        cdef Int i
        cdef Int nargs = len(args)
        cdef CObj r
        cdef CObj v
        GAP_EnterStack()
        try:
            r = GAP_NewPlist(nargs)
            for i in range(nargs):
                v = _unwrap_obj(args[i])
                GAP_AssList(r, i+1, v)
        finally:
            GAP_LeaveStack()
            _setup_objwrap(self, r)
    # TODO: deep?
    def to_python(self):
        pass
    def __getitem__(self, pos):
        cdef CObj l = _unwrap_obj(self)
        cdef Int p = pos - 1 # Probably best to behave like a python list?
        return _wrap_obj(GAP_ElmList(l, p))
    def __setitem__(self, pos, val):
        cdef CObj l = _unwrap_obj(self)
        cdef Int p = pos - 1
        cdef CObj v = _unwrap_obj(val)
        GAP_AssList(l, p, v)
    def __len__(self):
        cdef CObj l = _unwrap_obj(self)
        return GAP_LenList(l)

# TODO: For this we first need a GAP API for records
class Record(Obj):
    pass

class Function(Obj):
    def __init__(self, name):
        self.name = name
        self.from_gap_by_name(name)
    # TODO: The following two do not work/do not make sense. This object
    #       is the incarnation of "to_python"
    def from_python(self, val):
        pass
    def to_python(self):
        pass
    def from_gap_by_name(self, name):
        self.name = name
        # Meh, should also check that we are getting something
        # callable (function, operation)
        cdef CObj f = GAP_ValueGlobalVariable(_to_bytes(name))
        _setup_objwrap(self, f)
    def __call__(self, *args):
        cdef CObj func = _unwrap_obj(self)
        # Meh
        l = List()
        l.from_python(*args)
        cdef CObj argl = _unwrap_obj(l)
        cdef CObj r
        GAP_EnterStack()
        try:
            r = GAP_CallFuncList(func, argl)
        finally:
            GAP_LeaveStack()
            return _wrap_obj(r)
    def __repr__(self):
        return "<GAP Function: %s>" %(self.name,)
# needs float back-and-forth geshuffle
class Float(Obj):
    pass

# TODO: Implement refcounting
cdef void gasman_callback():
    pass

# TODO: Implement some kind of error handling
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
    cdef CObj r
    GAP_EnterStack()
    try:
        r = GAP_EvalString(_to_bytes(cmd))
    finally:
        GAP_LeaveStack()
        return _wrap_obj(r)

def ValueGlobalVariable(name):
    cdef CObj r
    GAP_EnterStack()
    try:
        r = GAP_ValueGlobalVariable(_to_bytes(name))
    finally:
        GAP_LeaveStack()
        return _wrap_obj(r)

def CallFuncList(Obj func, Obj args):
    cdef CObj f = _unwrap_obj(func)
    cdef CObj a = _unwrap_obj(args)
    cdef CObj r
    GAP_EnterStack()
    try:
        r = GAP_CallFuncList(f, a)
    finally:
        GAP_LeaveStack()
        return _wrap_obj(r)

# Possible to deduplicate this?
def EQ(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return GAP_EQ(ca, cb)

def LT(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return GAP_LT(ca, cb)

def IN(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return GAP_IN(ca, cb)

def SUM(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_SUM(ca, cb))

def DIFF(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_DIFF(ca, cb))

def PROD(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_PROD(ca, cb))

def QUO(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_QUO(ca, cb))

def LQUO(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_LQUO(ca, cb))

def POW(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_POW(ca, cb))

def COMM(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_COMM(ca, cb))

def MOD(Obj a, Obj b):
    cdef CObj ca = _unwrap_obj(a)
    cdef CObj cb = _unwrap_obj(b)
    return _wrap_obj(GAP_MOD(ca, cb))

#    CObj GAP_True
#    CObj GAP_False
#    CObj GAP_Fail
#
