from .PyBroma import *
# Inspired by Cython's Compiler Tree Visitors...

class BromaTreeVisitor:
    """Used to safely visit different Parts of a broma file
    and is built to allow for easy visiting of all the parts 
    you need in your code"""

    def visit_PlatformNumber(self, node):
        return 

    def visit_FunctionProto(self, node:FunctionProto):
        return 

    def visit_MemberFunctionProto(self, node:MemberFunctionProto):
        return
    
    def visit_Attributes(self, node:Attributes):
        return
    
    def visit_InlineField(self, node:InlineField):
        return 

    def visit_FunctionBindField(self, node:FunctionBindField):
        self.visit_MemberFunctionProto(node.prototype)
        self.visit_PlatformNumber(node.binds)

    def visit_MemberField(self, node:MemberField):
        pass 

    def visit_PadField(self, node:PadField):
        self.visit_FunctionProto(node)
 
    def visit_Field(self, f:Field):
        if x := f.getAsFunctionBindField():
            self.visit_FunctionBindField(x)
        elif x := f.getAsMemberField():
            self.visit_MemberField(x)
        elif x := f.getAsPadField():
            self.visit_PadField(x)
        elif x := f.getAsInlineField():
            self.visit_InlineField(x)

    def visit_Function(self, node:Function):
        self.visit_FunctionProto(node.prototype)
        self.visit_PlatformNumber(node.binds)

    def visit_Class(self, node:Class):
        if node.attrs.links:
            self.visit_Attributes(node.attrs)
        for f in node.fields:
            self.visit_Field(f)
    
    def start(self, root:Root):
        self.root = root
        for c in root.classes:
            self.visit_Class(c)
        for f in root.functions:
            self.visit_Function(f)

    def __call__(self, file:str):
        return self.start(Root(file))
