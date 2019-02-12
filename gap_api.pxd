
cdef extern from "libgap-api.h":
    ctypedef long Int
    ctypedef unsigned long UInt
    ctypedef void* Obj "Obj"
    ctypedef void (*GAP_CallbackFunc)()
    void GAP_Initialize(int argc, char ** argv,
        GAP_CallbackFunc, GAP_CallbackFunc, int)
    Obj GAP_EvalString(const char *)
    Obj GAP_ValueGlobalVariable(const char *)
    Obj GAP_MakeObjInt(const UInt * limbs, Int size)

cdef class GAPObj(object):
    cdef Obj value

cdef GAPObj gap_obj(Obj obj)
