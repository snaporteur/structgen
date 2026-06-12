from structgen.parser import parser
from structgen.writter import Writter
import os

class builder:
    def __init__(self, file, out, verbose):
        self.file = file
        self.out = out
        self.verbose = verbose
        
    def get_writepath(self):
        if self.out.endswith(".h"):
            return self.out
        name = os.path.splitext(os.path.basename(self.file))[0]
        return os.path.join(self.out, name + ".h")

    def build(self):
        with open(self.file, "r") as f:
            code = f.read()
  
        pars = parser(code)
        ast = pars.get_ast()
        writter = Writter(ast, out=self.get_writepath())
        writter.save()