#ifndef __HELPER_HPP__
#define __HELPER_HPP__

#include "Broma/include/broma.hpp"
#include "Broma/include/ast.hpp"

/* Used as a primary helpers around Field's variant and other Types since variants
are not supported by cython yet as far as I am aware... */

/* These help to provide compatability to python */

inline broma::InlineField *Field_GetAs_InlineField(broma::Field *f)
{
    broma::InlineField *x;
    if (x = std::get_if<broma::InlineField>(&f->inner))
    {
        return x;
    };
    return nullptr;
}



inline broma::FunctionBindField *Field_GetAs_FunctionBindField(broma::Field *f)
{
    broma::FunctionBindField *x;
    if (x = std::get_if<broma::FunctionBindField>(&f->inner))
    {
        return x;
    };
    return nullptr;
}

inline broma::PadField *Field_GetAs_PadField(broma::Field *f)
{
    broma::PadField *x;
    if (x = std::get_if<broma::PadField>(&f->inner))
    {
        return x;
    };
    return nullptr;
}

inline broma::MemberField *Field_GetAs_MemberField(broma::Field *f)
{
    broma::MemberField *x;
    if (x = std::get_if<broma::MemberField>(&f->inner))
    {
        return x;
    };
    return nullptr;
}

inline bool MemberFunctionProtoEquals(broma::MemberFunctionProto const &a, broma::MemberFunctionProto const &b)
{
    return a == b;
};

inline bool FunctionProtoEquals(broma::FunctionProto const &a, broma::FunctionProto const &b)
{
    return a == b;
};

inline bool TypeEquals(broma::Type const &a, broma::Type const &b)
{
    return a == b;
}

inline bool ClassEqualsTo(broma::Class const &a, broma::Class const &b)
{
    return a.name == b.name;
}
inline bool ClassEqualsToName(broma::Class const &a, std::string const &b)
{
    return a.name == b;
}

inline broma::MemberFunctionProto *FieldGetFn(broma::Field *field)
{
    return field->get_fn();
}

broma::Class *RootgetClassFromStr(broma::Root *root, std::string const &name)
{
    return root->operator[](name);
}


/* it all comes from python refusing to use the keyword "None" as 
 * an enum The Broma Devs did not take kindly to my pull request 
 * to fix  this None keyword to "NONE" so we have to translate this one 
 * out ourselves as a workaround to the problem */

enum class PyPlatform {
    NONE = 0,
    Mac = 1,
	Windows = 2,
	Android = 4,
	iOS = 8,
	Android32 = 16 | 4,
	Android64 = 32 | 4, 
	MacIntel = 64 | 1,
	MacArm = 128 | 1,
};

/* @brief fixes Unacceptable/innapropreate names allowing for python to maintain compatability */
PyPlatform fix_platformname(broma::Platform platform){

    #define TRANSLATE_THIS_ENUM(NAME) case broma::Platform::NAME: return PyPlatform::NAME
    switch (platform)
    {
    // Translate the problem Variable that python despises...
    case broma::Platform::None:
        return PyPlatform::NONE;
    TRANSLATE_THIS_ENUM(Mac);
    TRANSLATE_THIS_ENUM(Windows);
    TRANSLATE_THIS_ENUM(Android);
    TRANSLATE_THIS_ENUM(iOS);
    TRANSLATE_THIS_ENUM(Android32);
    TRANSLATE_THIS_ENUM(Android64);
    TRANSLATE_THIS_ENUM(MacIntel);
    TRANSLATE_THIS_ENUM(MacArm);
    default:
        return PyPlatform::NONE;
    }
    /* We don't need this enum after this point... */
    #undef TRANSLATE_THIS_ENUM
}


#endif // __HELPER_HPP__