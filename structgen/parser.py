from lark import Lark, Transformer

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
        self.parser = Lark.open("structgen/grammar.lark", parser="lalr")
        tree = self.parser.parse(self.code)
        ast = ast_builder().transform(tree)
        self.ast = ast
        
    def get_ast(self):
        return self.ast