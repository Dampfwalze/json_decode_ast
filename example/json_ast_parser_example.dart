import 'package:json_ast_parser/json_ast_parser.dart';

void main() {
  final json = '''
{
  "name": "John Doe",
  "age": 30,
  "isStudent": false,
  "scores": [100, 200, 300],
  "address": {
    "street": "Main Street",
    "city": "Springfield"
  }
}
''';

  final ASTNodeWithLocation ast = JsonAstDecoder.withLocation(
    allowInputAfter: true,
  ).convert(json);

  print(ast);

  print(ast.toNode());
}
