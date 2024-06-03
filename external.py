"""This is where anything outside of pybroma is imported from"""

try:
    from Cython.CodeWriter import LinesResult
except ModuleNotFoundError:
    # I do not feel bad for borrowing this one...
    class LinesResult(object):
        def __init__(self):
            self.lines = []
            self.s = u""

        def put(self, s):
            self.s += s

        def newline(self):
            self.lines.append(self.s)
            self.s = u""

        def putline(self, s):
            self.put(s)
            self.newline()