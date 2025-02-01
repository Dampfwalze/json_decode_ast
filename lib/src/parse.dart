import 'package:json_ast_parser/src/ast.dart';

bool _provideLocation = false;

ASTNode jsonDecodeAST(
  String json, {
  bool allowInputAfter = false,
  bool provideLocation = false,
}) {
  _provideLocation = provideLocation;

  final (value, index) = parseValue(json, 0);

  if (!allowInputAfter && index < json.length) {
    throw FormatException(
      'Unexpected extra characters at the end of the input',
    );
  }

  return value;
}

ASTNodeWithLocation jsonDecodeASTWithLocation(
  String json, {
  bool allowInputAfter = false,
}) =>
    jsonDecodeAST(json, allowInputAfter: allowInputAfter, provideLocation: true)
        as ASTNodeWithLocation;

(ASTNode, int) parseValue(String json, int start) {
  start = _flushWhitespace(json, start);

  final (value, index) = switch (json.at(start)) {
    '{' => parseObject(json, start),
    '[' => parseArray(json, start),
    '"' => parseString(json, start),
    '-' ||
    '0' ||
    '1' ||
    '2' ||
    '3' ||
    '4' ||
    '5' ||
    '6' ||
    '7' ||
    '8' ||
    '9' => parseNumber(json, start),
    null => throw FormatException('Unexpected end of input'),
    _ => switch (_nextWord(json, start)) {
      'true' => (
        _provideLocation
            ? ASTBooleanWithLocation(true, start)
            : ASTBoolean(true),
        start + 4,
      ),
      'false' => (
        _provideLocation
            ? ASTBooleanWithLocation(false, start)
            : ASTBoolean(false),
        start + 5,
      ),
      'null' => (
        _provideLocation ? ASTNullWithLocation(start) : ASTNull(),
        start + 4,
      ),
      var w => throw FormatException('Unexpected word: $w'),
    },
  };

  return (value, _flushWhitespace(json, index));
}

int _flushWhitespace(String json, int index) {
  main:
  for (; index < json.length; index++) {
    switch (json[index]) {
      case ' ' || '\n' || '\r' || '\t': // White space
        continue;
      case '/': // Comment
        index++;
        switch (json.at(index)) {
          case '/': // Line comment
            for (; index < json.length; index++) {
              if (json[index] == '\n') {
                continue main;
              }
            }
            break main;
          case '*': // Block comment
            for (; index < json.length; index++) {
              if (json[index] == '*' && json.at(index + 1) == '/') {
                index++;
                continue main;
              }
            }
            break main;
          case null: // End of input
            index--;
            break main;
          default:
            index--;
            break main;
        }
      default:
        break main;
    }
  }
  return index;
}

final _wordRegex = RegExp(r'\W');

String _nextWord(String json, int start) {
  final wordEnd = json.indexOf(_wordRegex, start);
  if (wordEnd == -1) {
    return json.substring(start);
  }
  return json.substring(start, wordEnd);
}

(ASTObject, int) parseObject(String json, int start) {
  final properties = <ASTString, ASTNode>{};

  var index = _flushWhitespace(json, start + 1);
  while (index < json.length && json[index] != '}') {
    index = _flushWhitespace(json, index);
    if (json.at(index) != '"') {
      throw FormatException('Expected string at index $index');
    }
    final (key, keyEnd) = parseString(json, index);

    index = _flushWhitespace(json, keyEnd);

    if (json.at(index) != ':') {
      throw FormatException('Expected ":" at index $index');
    }

    final (value, valueEnd) = parseValue(json, index + 1);
    properties[key] = value;

    index = _flushWhitespace(json, valueEnd);

    if (json.at(index) == ',') {
      index = _flushWhitespace(json, index + 1);
    }
  }

  if (_provideLocation) {
    return (
      ASTObjectWithLocation(properties.cast(), start, index + 1),
      index + 1,
    );
  } else {
    return (ASTObject(properties), index + 1);
  }
}

(ASTArray, int) parseArray(String json, int start) {
  final elements = <ASTNode>[];

  var index = _flushWhitespace(json, start + 1);
  while (index < json.length && json[index] != ']') {
    final (element, newIndex) = parseValue(json, index);
    elements.add(element);
    index = newIndex;

    if (json.at(index) == ',') {
      index = _flushWhitespace(json, index + 1);
    }
  }

  if (_provideLocation) {
    return (ASTArrayWithLocation(elements.cast(), start, index + 1), index + 1);
  } else {
    return (ASTArray(elements), index + 1);
  }
}

(ASTString, int) parseString(String json, int start) {
  final sb = StringBuffer();

  var subStart = start + 1;
  var end = subStart;
  while (end < json.length && json[end] != r'"') {
    if (json[end] != r'\') {
      end++;
    } else {
      sb.write(json.substring(subStart, end));

      switch (json.at(end + 1)) {
        case '"' || r'\' || '/':
          sb.write(json[end + 1]);
          end += 2;
        case 'b':
          sb.write('\b');
          end += 2;
        case 'f':
          sb.write('\f');
          end += 2;
        case 'n':
          sb.write('\n');
          end += 2;
        case 'r':
          sb.write('\r');
          end += 2;
        case 't':
          sb.write('\t');
          end += 2;
        case 'u':
          if (end + 5 >= json.length) {
            throw FormatException('Unexpected end of input');
          }
          sb.write(
            String.fromCharCode(
              int.parse(json.substring(end + 2, end + 6), radix: 16),
            ),
          );
          end += 6;
        case null:
          throw FormatException('Unexpected end of input');
      }

      subStart = end;
    }
  }

  sb.write(json.substring(subStart, end));

  if (_provideLocation) {
    return (ASTStringWithLocation(sb.toString(), start, end + 1), end + 1);
  } else {
    return (ASTString(sb.toString()), end + 1);
  }
}

(ASTNumber, int) parseNumber(String json, int start) {
  var end = start;

  for (
    ;
    end < json.length &&
        switch (json.codeUnitAt(end)) {
          43 || 45 || 46 || 69 || 101 => true, // + - . E e
          var c => c >= 48 && c <= 57, // 0-9
        };
    end++
  ) {}

  if (_provideLocation) {
    return (
      ASTNumberWithLocation(num.parse(json.substring(start, end)), start, end),
      end,
    );
  } else {
    return (ASTNumber(num.parse(json.substring(start, end))), end);
  }
}

extension on String {
  String? at(int index) => index < length ? this[index] : null;
}
