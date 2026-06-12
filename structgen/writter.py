import jinja2
import os

class Writter:
    def __init__(self, ast, out):
        self.ast = ast
        self.out = out
        self.template = jinja2.Template(open("structgen/template.h", "r").read())
        
        self.result = self.template.render(structs=self.ast)
    
    def save(self):
        # Create output directory if it doesn't exist
        output_dir = os.path.dirname(self.out)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
        with open(self.out, "w") as f:
            f.write(self.result)