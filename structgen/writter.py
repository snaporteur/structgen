import jinja2
import os

class Writter:
    def __init__(self, ast, out):
        self.ast = ast
        self.out = out
        # Get the template file path relative to this module
        template_path = os.path.join(os.path.dirname(__file__), "template.h")
        with open(template_path, "r") as f:
            self.template = jinja2.Template(f.read())
        
        self.result = self.template.render(structs=self.ast)
    
    def save(self):
        # Create output directory if it doesn't exist
        output_dir = os.path.dirname(self.out)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
        with open(self.out, "w") as f:
            f.write(self.result)