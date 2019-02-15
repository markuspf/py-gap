cdef _setup_gapobj(GAPObj go, Obj o):
    go.value = o

cdef Obj _extract_obj(GAPObj gobj):
    cdef Obj r = gobj.value
    return r

cdef GAPObj _wrap_obj(Obj o):
    go = GAPObj()
    _setup_gapobj(go, o)
    return go

cdef Obj _gap_integer(pyint):
    sign = 1
    if pyint == 0:
        r = GAP_MakeObjInt([], 0)
    elif pyint < 0:
        sign = -1
        pyint = -pyint

    bytec = (pyint.bit_length() + 7) // 8
    limbs = pyint.to_bytes(bytec, 'little')

    cdef char * climbs = limbs
    return GAP_MakeObjInt(<UInt *>climbs, sign * bytec)

cdef class GAPObj(object):
    def __init__(self):
        pass
    def __hash__(self):
        return <unsigned long>(self.value)

class GAPInteger(GAPObj):
    def __init__(self, val):
        cdef Obj r
        cdef char * climbs

        sign = 1
        if val == 0:
            _setup_gapobj(self, GAP_MakeObjInt([], 0))
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
        _setup_gapobj(self, r)

class GAPString(GAPObj):
    def __init__(self, val):
        cdef Obj r = GAP_MakeString(<const char *>val)
        _setup_gapobj(self, r)

class GAPPermutation(GAPObj):
    def __init__(self, val):
        self.value = None

class GAPList(GAPObj):
    def __init__(self, *args):
        cdef Int i
        cdef Int nargs = len(args)
        cdef Obj r
        cdef Obj v
        r = GAP_NewPlist(nargs)
        for i in range(nargs):
            v = _extract_obj(args[i])
            GAP_AssList(r, i+1, v)
        _setup_gapobj(self, r)

    def __repr__(self):
        return "<blalist>"
    def __str__(self):
        return "<blalist>"

class GAPRecord(GAPObj):
    pass

class GAPFunction(GAPObj):
    pass


cdef void gasman_callback():
    pass

cdef void error_callback():
    pass

cdef gap_to_python(GAPObj obj):
    return None

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

def EvalString(command):
#    cdef char * cbla = command
    return _wrap_obj(GAP_EvalString(command))

def ValueGlobalVariable(name):
    return _wrap_obj(GAP_ValueGlobalVariable(name))

def CallFuncList(GAPObj func, GAPObj args):
    cdef Obj f = _extract_obj(func)
    cdef Obj a = _extract_obj(args)
    GAP_CallFuncList(f, a)

