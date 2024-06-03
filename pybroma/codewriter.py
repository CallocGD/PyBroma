"""Inspried by Cython's code writer this visitor can be used for writing custom broma code and modifying it"""

from .PyBroma import Class, Function # type: ignore
from .visitor import BromaTreeVisitor
from .external import LinesResult
from .PyBroma import * # type: ignore
from .platforms import Platform


# TODO: This is still a work in progress...
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

    def startline(self, s=u""):
        self.result.put(self.indent_string * self.numindents + s)

    def put(self, s):
        self.result.put(s)

    def putline(self, s):
        self.result.putline(self.indent_string * self.numindents + s)

    def endline(self, s=u""):
        self.result.putline(s)

    def line(self, s):
        self.startline(s)
        self.endline()

    def visit_Class(self, node: Class):
        links = Platform(node.links)
        if links != Platform.NONE:
            self.startline("[[link(")
            link_list = []
            if links | Platform.Android:
                link_list.append("android")
            if links | Platform.Windows:
                link_list.append("win")
            if links | Platform.Mac:
                link_list.append("mac")
            self.put(",".join(link_list))
            self.endline(")]]")
        
        self.startline("class ")
        self.put(node.name)
        if node.superclasses:
            self.put(": public")
            self.put(",".join(node.superclasses))
        self.endline("{")
        self.indent()
        ret = super().visit_Class(node)
        self.dedent()
        self.putline("}")
        self.line("")
        return ret
    
    # def visit_Function(self, node: Function):
    #     ret = super().visit_Function(node) 
    #     return ret 

