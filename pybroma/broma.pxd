# cython: language_level = 3
# distutils: language = c++

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair


ctypedef long long ptrdiff_t

cdef extern from "include/ast.hpp" namespace "broma" nogil:
    # NOTE: "None" can't be used as a keyword in python...
    # TODO: Throw an issue on geode-sdk/Broma about this problem 
    enum class Platform:
        # None = 0 # Currently Invalid and impossible to compile 
        Mac = 1
        Windows = 2
        Android = 4
        iOS = 8
        Android32 = 16
        Android64 = 32


    # offsets for each platform
    struct PlatformNumber:
        ptrdiff_t mac
        ptrdiff_t ios
        ptrdiff_t win
        ptrdiff_t android32
        ptrdiff_t android64
    
    struct Type:
        string name
        bint is_struct
     
    struct FunctionProto:
        Type ret # The return type of the function.
        vector[pair[Type, string]] args # All arguments, represented by their type and their name.
        string docs # Any docstring pulled from a `[[docs(...)]]` attribute.
        string name # The function's name.

    enum class FunctionType:
        Normal = 0
        Ctor = 1 # A constructor.
        Dtor = 2 # A destructor.
     
    struct MemberFunctionProto:
        Type ret # The return type of the function.
        vector[pair[Type, string]] args # All arguments, represented by their type and their name.
        string docs # Any docstring pulled from a `[[docs(...)]]` attribute.
        string name # The function's name.
        FunctionType type
        bint is_const
        bint is_virtual
        bint is_callback
        bint is_static

    # @brief A class's member variables.
    struct MemberField:
        string name # The name of the field.
        Type type # The type of the field.
        size_t count # The number of elements in the field when it's an array (pretty much unused since we use array).
     

     # @brief Any class padding.
    struct PadField:
        PlatformNumber amount # The amount of padding, separated per platform.
     

     # @brief A function that is bound to an offset.
    struct FunctionBindField:
        MemberFunctionProto prototype
        PlatformNumber binds # The offsets, separated per platform.
     

     # @brief An function body that should go in a source file (.cpp).
    struct OutOfLineField:
        MemberFunctionProto prototype
        string inner # The body of the function as a raw string.
     

     # @brief A function body that should go in a header file (.hpp).
    struct InlineField:
        string inner # The body of the function as a raw string.
     

    struct Field:
        size_t field_id # The index of the field. This starts from 0 and counts up across all classes.
        string parent # The name of the parent class.
        # NOTE: I wrote a special function for handling "inner" in helper.cpp since Cython can't handle variants yet
        Platform links # All the platforms that link the field
        Platform missing # All the platforms that are missing the field

    struct Function:
        FunctionProto prototype # The free function's signature.
        PlatformNumber binds # The offsets of free function, separated per platform.
        Platform links # All the platforms that link the function
        Platform missing # All the platforms that are missing the function

    struct Class:
        string name # The name of the class.
        vector[string] superclasses # Parent classes that the current class inherits.
        vector[string] depends # Classes the current class depends on.
                                                    # This includes parent classes, and any classes declared in a `[[depends(...)]]` attribute.
        vector[Field] fields # All the fields parsed in the class.

        Platform links # All the platforms that link the class
        Platform missing # All the platforms that are missing the class

    
    struct Root:
        vector[Class] classes
        vector[Function] functions



cdef extern from "include/helper.hpp" nogil:
    InlineField* Field_GetAs_InlineField(Field* f)
    OutOfLineField* Field_GetAs_OutOfLineField(Field* f)
    FunctionBindField* Field_GetAs_FunctionBindField(Field* f)
    PadField* Field_GetAs_PadField(Field* f)
    MemberField* Field_GetAs_MemberField(Field* f)
    bint MemberFunctionProtoEquals(MemberFunctionProto a, MemberFunctionProto b)
    bint FunctionProtoEquals(FunctionProto a, FunctionProto b)
    bint TypeEquals(Type a, Type b)
    bint ClassEqualsTo(Class a, Class b)
    bint ClassEqualsToName(Class a, string b)
    MemberFunctionProto* FieldGetFn(Field* field)
    Class* RootgetClassFromStr(Root* root, string name)

cdef extern from "include/broma.hpp" namespace "broma" nogil:
    Root parse_file(string fname)
