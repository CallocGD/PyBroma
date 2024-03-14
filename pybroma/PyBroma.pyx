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
    broma.OutOfLineField DEPACK(broma.OutOfLineField* x)
    broma.MemberField DEPACK(broma.MemberField* x)
    broma.InlineField DEPACK(broma.InlineField* x)
    broma.FunctionBindField DEPACK(broma.FunctionBindField* x)
    broma.Class DEPACK(broma.Class* x)

cdef class ImmutableError(Exception):
    """Object is an immutable property and cannot mutate"""
    def __init__(self, str name):
        super().__init__(name + " is immutable")



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

    @property
    def is_struct():
        return self.type.is_struct



cdef Type make_type(broma.Type t) noexcept:
    cdef Type ty = Type(t)
    ty.type = t
    return ty




cdef class MemberFunctionProto:
    cdef:
        broma.MemberFunctionProto proto
        dict _args 

    def __cinit__(self):
        self._args = dict()
        pass 
    
    cdef void init(self, broma.MemberFunctionProto proto):
        self.proto = proto
        self._args = {<str>a.second : make_type(a.first) for a in proto.args}
    
    property args:
        def __get__(self):
            return self._args

        def __set__(self, obj):
            raise ImmutableError("args")

    # TODO: Make More Fields Immutable
    @property
    def ret(self):
        return make_type(self.proto.ret) 
    
    @property
    def is_const(self):
        return self.proto.is_const

    @property
    def is_virtual(self):
        return self.proto.is_virtual
    
    @property
    def is_callback(self):
        return self.proto.is_callback
    
    @property
    def is_static(self):
        return self.proto.is_static
    
    @property
    def type(self):
        return self.proto.type
    
    @property
    def docs(self):
        return <str>self.proto.docs

    @property
    def name(self):
        return <str>self.proto.name
    
    def __eq__(self, MemberFunctionProto mfp):
        return broma.MemberFunctionProtoEquals(self.proto, mfp.proto)


cdef MemberFunctionProto make_MemberFunctionProto(broma.MemberFunctionProto proto) noexcept:
    cdef MemberFunctionProto mfp = MemberFunctionProto()
    mfp.init(proto)
    return mfp


cdef class MemberField:
    cdef:
        broma.MemberField field

    def __cinit__(self):
        pass

    @property
    def name(self):
        return <str>self.field.name
    
    @property
    def type(self):
        return make_type(self.field.type)
    
    @property
    def count(self):
        return self.field.count



cdef MemberField make_MemberField(broma.MemberField field) noexcept:
    cdef MemberField f = MemberField()
    f.field = field
    return f




cdef class OutOfLineField:
    cdef:
        broma.OutOfLineField oolf
    
    def __cinit__(self):
        pass

    @property
    def prototype(self):
        return make_MemberFunctionProto(self.oolf.prototype)

    @property
    def inner(self):
        return <str>self.oolf.inner



cdef OutOfLineField make_OutOfLineField(broma.OutOfLineField oolf) noexcept:
    cdef OutOfLineField _oolf = OutOfLineField()
    _oolf.oolf = oolf
    return _oolf


cdef class FunctionBindField:
    cdef broma.FunctionBindField fbf
    def __cinit__(self):
        pass

    @property
    def prototype(self):
        return make_MemberFunctionProto(self.fbf.prototype)
    
    @property
    def binds(self):
        return make_PlatfornNum(self.fbf.binds)


cdef FunctionBindField make_FunctionBindField(broma.FunctionBindField fbf) noexcept:
    cdef FunctionBindField _fbf = FunctionBindField()
    _fbf.fbf = fbf
    return _fbf


cdef class PadField:
    cdef:
        broma.PadField pf
    def __cinit__(self): 
        pass 
    @property
    def amount(self):
        return make_PlatfornNum(self.amount)


cdef PadField make_PadField(broma.PadField pf) noexcept:
    cdef PadField _pf = PadField()
    _pf.pf = pf
    return _pf


cdef class Field:
    cdef:
        broma.Field field

    def __cinit__(self):
        pass
    
    @property
    def id(self):
        return self.field.id

    @property
    def parent(self):
        return <str>self.field.parent

    def getAsFunctionBindField(self):
        cdef broma.FunctionBindField* x = broma.Field_GetAs_FunctionBindField(&self.field)
        return make_FunctionBindField(DEPACK(x)) if x != nullptr else None

    def getAsMemberField(self):
        cdef broma.MemberField* x = broma.Field_GetAs_MemberField(&self.field)
        return make_MemberField(DEPACK(x)) if x != nullptr else None

    def getAsOutOfLineField(self):
        cdef broma.OutOfLineField* x = broma.Field_GetAs_OutOfLineField(&self.field)
        return make_OutOfLineField(DEPACK(x)) if x != nullptr else None

    def getAsPadField(self):
        cdef broma.PadField* x = broma.Field_GetAs_PadField(&self.field)
        return make_PadField(DEPACK(x)) if x != nullptr else None

    @property
    def missing(self):
        return <int>self.field.missing

    @property
    def links(self):
        return <int>self.field.links


cdef Field make_Field(broma.Field field) noexcept:
    cdef Field f = Field()
    f.field = field
    return f


cdef class PlatformNumber:
    cdef:
        broma.PlatformNumber binds
    
    def __cinit__(self):
        pass
    
    @property
    def mac(self):
        return self.binds.mac

    @property
    def ios(self):
        return self.binds.ios

    @property
    def win(self):
        return self.binds.win

    @property
    def android32(self):
        return self.binds.android32

    @property
    def android64(self):
        return self.binds.android64



cdef PlatformNumber make_PlatfornNum(broma.PlatformNumber pn) noexcept:
    cdef PlatformNumber f = PlatformNumber()
    f.binds = pn    
    return f


cdef class InlineField:
    cdef broma.InlineField _if
    def __cinit__(self):
        pass 
    
    @property
    def inner(self):
        return <str>self._if.inner



cdef InlineField make_InlineField(broma.InlineField _if) noexcept:
    cdef InlineField c = InlineField()
    c._if = _if
    return c


cdef class FunctionProto:
    cdef:
        broma.FunctionProto proto
        dict _args 

    def __cinit__(self):
        self._args = dict()
        pass 
    
    
    cdef void init(self, broma.FunctionProto proto) noexcept:
        cdef vector[pair[broma.Type, string]] args = proto.args
        cdef size_t i
        self.proto = proto
        self._args = {<str>args[i].second : make_type(args[i].first) for i in range(args.size())}
    
    property args:
        def __get__(self):
            return self._args

        def __set__(self, obj):
            raise ImmutableError("args")

    @property
    def ret(self):
        return make_type(self.proto.ret) 
    
    @property 
    def name(self):
        return <str>self.proto.name
    
    @property
    def docs(self):
        return <str>self.proto.docs
    



cdef FunctionProto make_FunctionProto(broma.FunctionProto fp) noexcept:
    cdef FunctionProto _fp = FunctionProto() 
    _fp.init(fp)
    return _fp


cdef class Function:
    cdef:
        broma.Function func
    def __init__(self):
        pass
    
    @property
    def prototype(self):
        return make_FunctionProto(self.func.prototype)

    @property
    def binds(self):
        return make_PlatfornNum(self.func.binds)
    
    @property
    def missing(self):
        return self.func.missing

    @property
    def links(self):
        return self.func.links




cdef Function make_Function(broma.Function func) noexcept:
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

    property depends:
        def __get__(self):
            cdef size_t i
            # Have we made these into a list?
            if not self._depends_ran:
                self._depends = [self._cls.depends[i] for i in range(self._cls.depends.size())]
                self._depends_ran = True
            return self._depends

        def __set__(self, obj):
            raise ImmutableError("depends")

    property fields:
        def __get__(self):
            return [make_Field(f) for f in self._cls.fields]
        def  __set__(self, obj):
            raise ImmutableError("fields")
    
cdef make_Class(broma.Class cls):
    cdef Class _cls = Class()
    _cls._cls = cls
    return _cls
    

cdef class Root:
    cdef:
        broma.Root root

    def __init__(self, str fileName):
        self.root = broma.parse_file(<string>fileName)

    def __getitem__(self, str _class_name_):
        cdef Class c
        cdef broma.Class* _class_ = broma.RootgetClassFromStr(&self.root, <string>_class_name_)
        if _class_ == NULL:
            return None 
        else:
            return make_Class(DEPACK(_class_))

    @property 
    def functions(self):
        return [make_Function(x) for x in self.root.functions]

    @property
    def classes(self):
        return [make_Class(x) for x in self.root.classes]
    

    @property
    def functions(self):
        return [make_Function(x) for x in self.root.functions]
        
    def functionsAsDict(self) -> dict:
        """Converts Functions to A Dictionary"""
        return {<str>c.prototype.name: make_Function(c) for c in self.root.functions}

    def classesAsDict(self) -> dict:
        """Converts Classes to a dictionary"""
        return {<str>c.name:make_Class(c) for c in self.root.classes}


