from lark import Lark, Transformer
import os

class ast_builder(Transformer):
    def start(self, structs):
        return structs
    
    def struct(self, items):
        name = items[0]
        fields = items[1:]
        return {"name": name, "fields": fields}

    def field(self, items):
        return {"type": items[0], "name": items[1]}

class parser:
    def __init__(self, code):
        self.code = code
        # Get the grammar file path relative to this module
        grammar_path = os.path.join(os.path.dirname(__file__), "grammar.lark")
        self.parser = Lark.open(grammar_path, parser="lalr")
        tree = self.parser.parse(self.code)
        ast = ast_builder().transform(tree)
        self.ast = ast
        
    def get_ast(self):
        return self.ast