
cdef extern from "libgap-api.h":
    ctypedef long Int
    ctypedef unsigned long UInt
    ctypedef unsigned char UChar
    ctypedef void* Obj "Obj"
    ctypedef void (*GAP_CallbackFunc)()
    void GAP_Initialize(int argc, char ** argv,
        GAP_CallbackFunc, GAP_CallbackFunc, int)
    Obj GAP_EvalString(const char *)
    Obj GAP_ValueGlobalVariable(const char *)

    int GAP_EQ(Obj a, Obj b)
    int GAP_LT(Obj a, Obj b)
    int GAP_IN(Obj a, Obj b)

    Obj GAP_SUM(Obj a, Obj b)
    Obj GAP_DIFF(Obj a, Obj b)
    Obj GAP_PROD(Obj a, Obj b)
    Obj GAP_QUO(Obj a, Obj b)
    Obj GAP_LQUO(Obj a, Obj b)
    Obj GAP_POW(Obj a, Obj b)
    Obj GAP_COMM(Obj a, Obj b)
    Obj GAP_MOD(Obj a, Obj b)

    Obj GAP_True
    Obj GAP_False
    Obj GAP_Fail

    Obj GAP_CallFuncList(Obj func, Obj args)
    Obj GAP_CallFuncArray(Obj func, UInt narg, Obj args[])

    Int GAP_IsMacFloat(Obj obj)
    double GAP_ValueMacFloat(Obj obj)
    Obj GAP_NewMacFloat(double x)

    int GAP_IsInt(Obj obj)
    int GAP_IsSmallInt(Obj obj)
    int GAP_IsLargeInt(Obj obj)

    Obj GAP_MakeObjInt(const UInt * limbs, Int size)
    Int GAP_SizeInt(Obj obj)
    const UInt * GAP_AddrInt(Obj obj)


    int GAP_IsList(Obj obj)
    UInt GAP_LenList(Obj list)
    void GAP_AssList(Obj list, UInt pos, Obj val)

    Obj GAP_ElmList(Obj list, UInt pos)
    Obj GAP_NewPlist(Int capacity)


    int GAP_IsString(Obj obj)

    UInt GAP_LenString(Obj string)
    char * GAP_CSTR_STRING(Obj obj)
    Obj GAP_MakeString(const char * string)
    Obj GAP_MakeImmString(const char * string)

    Int GAP_ValueOfChar(Obj obj)
    Obj GAP_CharWithValue(UChar obj)

cdef class ObjWrap(object):
    cdef Obj value
