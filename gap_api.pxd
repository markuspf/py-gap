cdef extern from "libgap-api.h":
    ctypedef void* Obj "Obj"
    ctypedef void (*CallbackFunc)()
    void GAP_Initialize(int argc, char ** argv, char ** env,
        CallbackFunc, CallbackFunc)
    Obj GAP_EvalString(const char *)
    Obj GAP_ValueGlobalVariable(const char *)
