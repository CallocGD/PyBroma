# cython: language_level = 3
# distutils: language = c++

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair


ctypedef long long ptrdiff_t

cdef extern from "ast.hpp" namespace "broma" nogil:
    
    enum class Platform:
        pass

    struct Attributes:
        string docs # Any docstring pulled from a `[[docs(...)]]` attribute.
        Platform links # All the platforms that link the class or function
        Platform missing # All the platforms that are missing the class or function
        vector[string] depends # List of classes that this class or function depends on

    # offsets for each platform
    struct PlatformNumber:
        ptrdiff_t imac
        ptrdiff_t m1
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
        string name # The function's name.

    enum class FunctionType:
        Normal = 0
        Ctor = 1 # A constructor.
        Dtor = 2 # A destructor.
     
    struct MemberFunctionProto:
        Attributes attributes 
        Type ret # The return type of the function.
        vector[pair[Type, string]] args # All arguments, represented by their type and their name.
        string name # The function's name.
        FunctionType type
        bint is_const
        bint is_virtual
        bint is_callback
        bint is_static

    # @brief A class's member variables.
    struct MemberField:
        Platform platform # For platform-specific members, all platforms this member is defined on 
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


    
     # @brief A function body that should go in a header file (.hpp).
    struct InlineField:
        string inner # The body of the function as a raw string.
    
    struct Field:
        size_t field_id # The index of the field. This starts from 0 and counts up across all classes.
        string parent # The name of the parent class.
        # NOTE: I wrote a special function for handling "inner" in helper.cpp since Cython can't handle variants yet
        # Platform links # All the platforms that link the field
        # Platform missing # All the platforms that are missing the field

    struct Function:
        FunctionProto prototype # The free function's signature.
        PlatformNumber binds # The offsets of free function, separated per platform.

    struct Class:
        Attributes attributes
        string name # The name of the class.
        vector[string] superclasses # Parent classes that the current class inherits.
        vector[Field] fields # All the fields parsed in the class.

    
    struct Root:
        vector[Class] classes
        vector[Function] functions



cdef extern from "helper.hpp" nogil:
    InlineField* Field_GetAs_InlineField(Field* f)
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

    # Removes Innappropreate Enum Names from being used with python 
    # NOTE: I did not take this decision with much enthusiasm 
    enum class PyPlatform:
        NONE = 0
        Mac = 1
        Windows = 2
        Android = 4
        iOS = 8
        Android32 = 16 | 4
        Android64 = 32 | 4 
        MacIntel = 64 | 1
        MacArm = 128 | 1

    # fixes Unacceptable/innapropreate names allowing for python to maintain compatability 
    PyPlatform fix_platformname(Platform platform)


cdef extern from "broma.hpp" namespace "broma" nogil:
    Root parse_file(string fname)