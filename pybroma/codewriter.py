"""Inspried by Cython's code writer this visitor can be used for writing custom broma code and modifying it"""

from pybroma.PyBroma import FunctionProto, MemberField, MemberFunctionProto
from .PyBroma import Class, Function # type: ignore
from .visitor import BromaTreeVisitor
from .external import LinesResult
from .PyBroma import * # type: ignore
from .platforms import Platform, list_platforms
from warnings import warn


class NotImplementedWarning(Warning):
    pass 


# Inspired by Cython's Code Writer
class BromaWriter(BromaTreeVisitor):
    """Inspired By Cython's Code-writer but For writing Broma Files..."""
    
    indent_string = u"    "
    
    def __init__(self, result=None) -> None:
        self.result = LinesResult() if not result else result
        self.numindents = 0
        super().__init__()
    
    # I don't feel bad for borrowing from cython's code-space. It's really good code. 
    def write(self, tree:Root):
        self.start(tree)
        return self.result

    def indent(self):
        self.numindents += 1

    def dedent(self):
        self.numindents -= 1

    def put(self, s):
        self.result.put(s)

    def putline(self, s):
        self.result.putline(self.indent_string * self.numindents + s)

    def endline(self, s=u""):
        self.result.putline(s)

    def putNoIndent(self, s=""):
        self.result.putline(s)

    def startline(self, s=""):
        self.put(self.indent_string * self.numindents + s)

    def line(self, s):
        self.startline(s)
        self.endline()

    def empty_line(self):
        self.line("")

    def write_type(self, node:Type):
        if node.is_struct:
            self.put("struct ")
        self.put(node.name)

    def write_arg_as_str(self, name:str, type:Type):
        code = ""
        if type.is_struct:
            code += "struct "
        return code + (type.name + " " + name)
        
    def write_docs(self, docs:str):
        for n in docs.strip().splitlines():
            if n.strip():
                self.line("/// " + n)
        
    def write_args(self, args:dict[str, Type]):
        self.put(", ".join([self.write_arg_as_str(name, type) for name, type in args.items()]))

    def visit_FunctionProto(self, node: FunctionProto):
        if node.docs:
            self.write_docs(node.docs)
        if node.is_virtual:
            self.put("virtual ")
        if node.is_static:
            self.put("static ")
        if node.is_const:
            self.put("const ")
        self.write_type(node.ret)
        self.put(" " + node.name)
        self.put("(")
        if node.args:
            self.write_args(node.args)
        self.put(")")
        return super().visit_FunctionProto(node)

    def visit_InlineField(self, node:InlineField):
        first , second = node.inner.split("\n", 1)
        second, _ = second.split("\n", -1)
        self.line(first)
        self.indent()
        for s in second.splitlines():
            # Get rid of those pesky tabs...
            self.putNoIndent(s.replace("\t","    "))
        self.dedent()
        self.line("}")
        

    def visit_MemberFunctionProto(self, node: MemberFunctionProto):
        self.startline()
        if node.is_virtual:
            self.put("virtual ")
        if node.is_static:
            self.put("static ")
        if node.is_const:
            self.put("const ")

        if node.is_callback:
            warn("\"is_callback\" has not been implemented yet I don't know what to do here yet - Calloc", NotImplementedWarning)

        self.write_type(node.ret)
        self.put(" " + node.name)
        self.put("(")
        if node.args:
            self.write_args(node.args)
        self.put(")")

        return super().visit_MemberFunctionProto(node)

    def visit_PlatformNumber(self, node:PlatformNumber):
        # skip if there is nothing to be binded with...
        if platforms := node.platforms_as_dict():
            self.put(" = ") 
            self.put(", ".join(["%s = %s" % (k, v) for k, v in platforms.items()]))
    

    def visit_FunctionBindField(self, node:FunctionBindField):
        if node.prototype.attrs.docs:
            self.empty_line()
            self.write_docs(node.prototype.attrs.docs)
        self.visit_MemberFunctionProto(node.prototype)
        self.visit_PlatformNumber(node.binds)
        self.endline(";")

        # Add an emptyline afterwards only for documented functions...
        if node.prototype.attrs.docs:
            self.empty_line()

                

    def visit_MemberField(self, node: MemberField):
        self.startline()
        self.write_type(node.type)
        self.put(" ")
        self.put(node.name)
        self.endline(";")

    def visit_Attributes(self, node:Attributes):

        self.put("[[link(")
        self.put(",".join(list_platforms(Platform(node.links))))
        self.endline(")]]")

    def visit_Class(self, node: Class):
        if node.attrs.docs:
            self.write_docs(node.attrs.docs)
        self.put("class ")
        self.put(node.name)
        if node.superclasses:
            self.put(": public ")
            self.put(",".join(node.superclasses))
        self.endline(" {")
        self.indent()
        ret = super().visit_Class(node)
        self.dedent()
        self.putline("}")
        self.line("")
        return ret
    
    def visit_Function(self, node: Function):
        ret = super().visit_Function(node) 
        return ret 


    def write_result(self):
        return "\n".join(self.result.lines)

