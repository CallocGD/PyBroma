# cython: language_level = 3
# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from libcpp cimport nullptr
from libc.stdlib cimport free 
cimport pybroma.broma as broma
cimport cython



cdef extern from *:
    """
#define DEPACK(x) *x
    """
    broma.PadField DEPACK(broma.PadField* x) 
    # broma.OutOfLineField DEPACK(broma.OutOfLineField* x)
    broma.MemberField DEPACK(broma.MemberField* x)
    broma.InlineField DEPACK(broma.InlineField* x)
    broma.FunctionBindField DEPACK(broma.FunctionBindField* x)
    broma.Class DEPACK(broma.Class* x)


# TODO: Apply a new property wrapper instead of needing to write __get__ & __set__ everytime
cdef class ImmutableError(Exception):
    """Object is an immutable property and cannot mutate"""
    def __init__(self, str name):
        super().__init__(name + " is immutable")


# Coming soon (if it's faster...)


# cdef class immutable(property):
#     """simillar to aiohttp's reify helper this property is given immutability"""
#     def __init__(self, func):
#         self.func = func 
#         self.__doc__ = func.__doc__
#         self.name = func.__name__
    
#     def __set__(self):
#         raise ImmutableError(self.name)



cdef class Type:
    cdef:
        broma.Type type
    
    def __cinit__(self):
        pass

    property name:
        def __get__(self):
            return self.type.name
        def __set__(self, obj):
            raise ImmutableError("name")

    def __eq__(self, Type t):
        return broma.TypeEquals(self.type, t)

    property is_struct:
        def __get__(self):
            return self.type.is_struct

        def __set__(self, obj):
            raise ImmutableError("is_struct")

    @staticmethod
    cdef Type init(broma.Type t) noexcept:
        cdef Type cls = Type()
        cls.type = t
        return cls




cdef class MemberFunctionProto:
    cdef:
        broma.MemberFunctionProto proto
        dict _args 

    def __cinit__(self):
        self._args = dict()
        pass 
    
    cdef void _init(self, broma.MemberFunctionProto proto):
        self.proto = proto
        self._args = {<str>a.second : Type.init(a.first) for a in proto.args}
    

    property args:
        def __get__(self):
            return self._args

        def __set__(self, obj):
            raise ImmutableError("args")

    # TODO: Make More Fields Immutable
    property ret:
        def __get__(self):
            return Type.init(self.proto.ret) 
        
        def __set__(self, obj):
            raise ImmutableError("ret")

    property is_const:
        def __get__(self):
            return self.proto.is_const
        
        def __set__(self, obj):
            raise ImmutableError("is_const")

    property is_virtual:
        def __get__(self):
            return self.proto.is_virtual

        def __set__(self, obj):
            raise ImmutableError("is_virtual")

    property is_callback:
        def __get__(self):
            return self.proto.is_callback

        def __set__(self, obj):
            raise ImmutableError("is_callback")

    property is_static:
        def __get__(self):
            return self.proto.is_static

        def __set__(self, obj):
            raise ImmutableError("is_static")

    property type:
        def __get__(self):
            return self.proto.type

        def __set__(self, obj):
            raise ImmutableError("type")
        
    property docs:
        def __get__(self):
            return <str>self.proto.docs

        def __set__(self, obj):
            raise ImmutableError("docs")


    property name:
        def __get__(self):
            return <str>self.proto.name
        def __set__(self, obj):
            raise ImmutableError("name")

    def __eq__(self, MemberFunctionProto mfp):
        return broma.MemberFunctionProtoEquals(self.proto, mfp.proto)

    @staticmethod
    cdef MemberFunctionProto init(broma.MemberFunctionProto proto) noexcept:
        cdef MemberFunctionProto mfp = MemberFunctionProto()
        mfp._init(proto)
        return mfp


cdef class MemberField:
    cdef:
        broma.MemberField field

    def __cinit__(self):
        pass

    property name:
        def __get__(self):
            return <str>self.field.name

        def __set__(self, obj):
            raise ImmutableError("name")


    property type:
        def __get__(self):
            return Type.init(self.field.type)

        def __set__(self, obj):
            raise ImmutableError("type")
        
    property count:
        def __get__(self):
            return self.field.count

        def __set__(self, obj):
            raise ImmutableError("count")


    @staticmethod
    cdef MemberField init(broma.MemberField field) noexcept:
        cdef MemberField f = MemberField()
        f.field = field
        return f


cdef class Attributes:
    cdef broma.Attributes attributes

    def __cinit__(self):
        self._depends = []
    
    property docs:
        def __get__(self):
            return <str>self.attributes.docs
        def __set__(self, obj):
            raise ImmutableError("docs")

    property links:
        def __get__(self):
            return broma.fix_platformname(self.attributes.links)

        def __set__(self, obj):
            raise ImmutableError("links")

    property missing:
        def __get__(self):
            return broma.fix_platformname(self.attributes.missing)
        
        def __set__(self, obj):
            raise ImmutableError("missing")

    property depends:
        def __get__(self):
            if not self._depends:
                self._depends = [<str>d for d in self.attributes.depends]
            return self._depends
        
        def __set__(self, obj):
            raise ImmutableError("depends")
    
    @staticmethod
    cdef Attributes init(broma.Attributes attrs):
        cdef Attributes cls = Attributes()
        cls.attributes = attrs
        return cls




cdef class FunctionBindField:
    cdef broma.FunctionBindField fbf
    def __cinit__(self):
        pass

    property prototype:
        def __get__(self):
            return MemberFunctionProto.init(self.fbf.prototype)
        def __set__(self, obj):
            raise ImmutableError("prototype")

    property binds:
        def __get__(self):
            return PlatformNumber.init(self.fbf.binds)

        def __set__(self, obj):
            raise ImmutableError("binds")

    @staticmethod
    cdef FunctionBindField init(broma.FunctionBindField fbf) noexcept:
        cdef FunctionBindField cls = FunctionBindField()
        cls.fbf = fbf
        return cls


cdef class PadField:
    cdef:
        broma.PadField pf
    def __cinit__(self): 
        pass 

    property amount:
        def __get__(self):
            return PlatformNumber.init(self.pf.amount)

        def __set__(self, obj):
            raise ImmutableError("amount")

    @staticmethod
    cdef PadField init(broma.PadField pf):
        cdef PadField _pf = PadField()
        _pf.pf = pf
        return _pf


cdef class Field:
    cdef:
        broma.Field field

    def __cinit__(self):
        pass
    
    property id:
        def __get__(self):
            return self.field.field_id
        
        def __set__(self, obj):
            raise ImmutableError("id")

    property parent:
        def __get__(self):
            return <str>self.field.parent

        def __set__(self, obj):
            raise ImmutableError("parent")


    def getAsFunctionBindField(self):
        cdef broma.FunctionBindField* x = broma.Field_GetAs_FunctionBindField(&self.field)
        return FunctionBindField.init(DEPACK(x)) if x != nullptr else None

    def getAsMemberField(self):
        cdef broma.MemberField* x = broma.Field_GetAs_MemberField(&self.field)
        return MemberField.init(DEPACK(x)) if x != nullptr else None

    def getAsPadField(self):
        cdef broma.PadField* x = broma.Field_GetAs_PadField(&self.field)
        return PadField.init(DEPACK(x)) if x != nullptr else None

    # Same as broma's function which's documentation reads
    # Convenience function to get the function prototype of the field, if the field is a function of some sort.
    def get_fn(self):
        fn = self.getAsFunctionBindField()
        return fn.prototype if fn else None


    @staticmethod
    cdef Field init(broma.Field field) noexcept:
        cdef Field f = Field()
        f.field = field
        return f


cdef class PlatformNumber:
    cdef:
        broma.PlatformNumber binds
    
    def __cinit__(self):
        pass

    @staticmethod
    cdef PlatformNumber init(broma.PlatformNumber pn) noexcept:
        number = PlatformNumber()
        number.binds = pn
        return number
    
    property imac:
        def __get__(self):
            return self.binds.imac
    
        def __set__(self, obj):
            raise ImmutableError("imac")

    property m1:
        def __get__(self):
            return self.binds.m1

        def __set__(self, obj):
            raise ImmutableError("m1")

    property ios:
        def __get__(self):
            return self.binds.ios

        def __set__(self, obj):
            raise ImmutableError("ios")


    property win:
        def __get__(self):
            return self.binds.win
        def __set__(self, obj):
            raise ImmutableError("win")

    property android32:
        def __get__(self):
            return self.binds.android32

        def __set__(self, obj):
            raise ImmutableError("android32")

    property android64:
        def __get__(self):
            return self.binds.android64

        def __set__(self, obj):
            raise ImmutableError("android64")





cdef class InlineField:
    cdef broma.InlineField _if
    def __cinit__(self):
        pass 
    
    property inner:
        def __get__(self):
            return <str>self._if.inner
        
        def __set__(self, obj):
            raise ImmutableError("inner")

    @staticmethod
    cdef InlineField init(broma.InlineField _if):
        cdef InlineField cls = InlineField()
        cls._if = _if
        return cls    




cdef class FunctionProto:
    cdef:
        broma.FunctionProto proto
        dict _args 

    def __cinit__(self):
        self._args = dict()
        pass 
    
    
    cdef void _init(self, broma.FunctionProto proto) noexcept:
        cdef vector[pair[broma.Type, string]] args = proto.args
        cdef size_t i
        self.proto = proto
        self._args = {<str>args[i].second : Type.init(args[i].first) for i in range(args.size())}
    
    property args:
        def __get__(self):
            return self._args

        def __set__(self, obj):
            raise ImmutableError("args")

    property ret:
        def __get__(self):
            return Type.init(self.proto.ret) 

        def __set__(self, obj):
            raise ImmutableError("ret")

    property name:
        def __get__(self):
            return <str>self.proto.name

        def __set__(self, obj):
            raise ImmutableError("name")

    property docs:
        def __get__(self):
            return <str>self.proto.docs

        def __set__(self, obj):
            raise ImmutableError("docs")


    property attributes:
        def __get__(self):
            return Attributes.init(self.proto.attributes)

        def __set__(self, obj):
            raise ImmutableError("attributes")

    @property
    def attrs(self):
        """shorthand equivilent to saying attributes"""
        return self.attributes


    @staticmethod
    cdef FunctionProto init(broma.FunctionProto fp) noexcept:
        cdef FunctionProto _fp = FunctionProto() 
        _fp._init(fp)
        return _fp


cdef class Function:
    cdef:
        broma.Function func

    def __cinit__(self):
        pass
    
    property prototype:
        def __get__(self):
            return FunctionProto.init(self.func.prototype)

        def __set__(self, obj):
            raise ImmutableError("prototype")

    property binds:
        def __get__(self):
            return PlatformNumber.init(self.func.binds)
        
        def __set__(self, obj):
            raise ImmutableError("binds")

    @staticmethod
    cdef Function init(broma.Function func) noexcept:
        cdef Function fn = Function()
        fn.func = func
        return fn


cdef class Class:
    cdef:
        broma.Class _cls
        list _superclasses
        bint _superclasses_ran
        list _depends
        bint _depends_ran

    def __cinit__(self):
        self._superclasses = []
        self._superclasses_ran = False
        self._depends = []
        self._depends_ran = False
        
    # You might be asking why? Simple truth is that these 
    # properties aren't meant to be modified
    property name:
        def __get__(self):
            return <str>self._cls.name
        def __set__(self, obj):
            raise ImmutableError("name")

    property links:
        def __get__(self):
            return <str>self._cls.name
        def __set__(self, obj):
            raise ImmutableError("links")
    
    property missing:
        def __get__(self):
            # TODO: Make Python Enum for defining Platform so that None is not used...
            return self._cls.missing
        def __set__(self, obj):
            raise ImmutableError("missing")

    property superclasses:
        def __get__(self):
            cdef size_t i
            # Have we made these into a list?
            if not self._superclasses_ran:
                self._superclasses = [self._cls.superclasses[i] for i in range(self._cls.superclasses.size())]
                self._superclasses_ran = True
            return self._superclasses

        def __set__(self, obj):
            raise ImmutableError("superclass")

    property fields:
        def __get__(self):
            return [Field.init(f) for f in self._cls.fields]
        def  __set__(self, obj):
            raise ImmutableError("fields")
    
    property attributes:
        def __get__(self):
            return Attributes.init(self._cls.attributes)
        def __set__(self, obj):
            raise ImmutableError("attributes")
    
    @property
    def attrs(self):
        """shorthand equivilent to saying attributes"""
        return self.attributes

    @staticmethod
    cdef Class init(broma.Class cls):
        cdef Class _cls = Class()
        _cls._cls = cls
        return _cls

    def __eq__(self, object other):

        if isinstance(other, str):
            return (<str>self._cls.name) == other
        
        elif isinstance(other, Class):
            return (<str>self._cls.name) == (<str>other._cls.name)
        
        else:
            raise ValueError("pybroma.Class can only be checked against strings and other pybroma.Class Types")

    

cdef class Root:
    cdef:
        broma.Root root
        list _functions
        list _classes

    def __init__(self, str fileName):
        self.root = broma.parse_file(<string>fileName)
        self._functions = []
        self._classes = []

        self._optimized_class_dict = {<str>c.name: Class.init(c) for c in self.root.classes}

    def __getitem__(self, str _class_name_):
        return self._optimized_class_dict[_class_name_]
    
    property functions:
        def __get__(self):
            if not self._functions:
                self._functions = [Function.init(x) for x in self.root.functions]
            return self._functions
        
        def __set__(self, obj):
            raise ImmutableError("functions")

    property classes:
        def __get__(self):
            if not self._classes:
                self._classes = [Class.init(x) for x in self.root.classes]
            return self._classes
        
        def __set__(self, obj):
            raise ImmutableError("classes")

    # NOTE: Deprecation will be soon for classesAsDict & functionsAsDict Use __getitem__ instead...
    def functionsAsDict(self) -> dict:
        """Converts Functions to A Dictionary"""
        return {<str>c.prototype.name: Function.init(c) for c in self.root.functions}

    def classesAsDict(self) -> dict:
        """Converts Classes to a dictionary"""
        return {<str>c.name: Class.init(c) for c in self.root.classes}


