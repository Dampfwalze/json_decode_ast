import 'dart:convert';

import 'package:meta/meta.dart';

import 'ast.dart';

ASTNode jsonDecodeAST(
  String json, {
  bool allowInputAfter = true,
  bool provideLocation = false,
  bool allowComments = true,
}) => JsonAstDecoder(
  allowInputAfter: allowInputAfter,
  provideLocation: provideLocation,
  allowComments: allowComments,
).convert(json);

ASTNodeWithLocation jsonDecodeASTWithLocation(
  String json, {
  bool allowInputAfter = false,
  bool allowComments = true,
}) => JsonAstDecoder.withLocation(
  allowInputAfter: allowInputAfter,
  allowComments: allowComments,
).convert(json);

abstract interface class JsonAstDecoder implements Converter<String, ASTNode> {
  const factory JsonAstDecoder({
    bool allowInputAfter,
    bool provideLocation,
    bool allowComments,
  }) = JsonAstDecoderImpl;

  static JsonAstDecoderWithLocation withLocation({
    bool allowInputAfter = true,
    bool allowComments = true,
  }) => _JsonAstDecoderWithLocationImpl(
    provideLocation: true,
    allowInputAfter: allowInputAfter,
    allowComments: allowComments,
  );

  ASTNode call(String input);
}

mixin JsonAstDecoderWithLocation on JsonAstDecoder {
  @override
  ASTNodeWithLocation convert(String input) =>
      super.convert(input) as ASTNodeWithLocation;
}

class _JsonAstDecoderWithLocationImpl = JsonAstDecoderImpl
    with JsonAstDecoderWithLocation;

@visibleForTesting
class JsonAstDecoderImpl extends Converter<String, ASTNode>
    implements JsonAstDecoder {
  final bool allowInputAfter;
  final bool provideLocation;
  final bool allowComments;

  const JsonAstDecoderImpl({
    this.allowInputAfter = true,
    this.provideLocation = false,
    this.allowComments = true,
  });

  @override
  ASTNode convert(String input) {
    final (value, index) = parseValue(input, 0);

    if (!allowInputAfter && index < input.length) {
      throw FormatException(
        'Unexpected extra characters at the end of the input',
      );
    }

    return value;
  }

  @override
  ASTNodeWithLocation call(String input) =>
      convert(input) as ASTNodeWithLocation;

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
          provideLocation
              ? ASTBooleanWithLocation(true, start)
              : ASTBoolean(true),
          start + 4,
        ),
        'false' => (
          provideLocation
              ? ASTBooleanWithLocation(false, start)
              : ASTBoolean(false),
          start + 5,
        ),
        'null' => (
          provideLocation ? ASTNullWithLocation(start) : ASTNull(),
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
          if (!allowComments) {
            throw FormatException('Comments are not allowed, at index $index');
          }
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
              throw FormatException('Unexpected end of input');
            default:
              throw FormatException(
                'Unexpected character at index $index: ${json[index]}',
              );
          }
        default:
          break main;
      }
    }
    return index;
  }

  static final _wordRegex = RegExp(r'\W');

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

    if (provideLocation) {
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

    if (provideLocation) {
      return (
        ASTArrayWithLocation(elements.cast(), start, index + 1),
        index + 1,
      );
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

    if (provideLocation) {
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

    if (provideLocation) {
      return (
        ASTNumberWithLocation(
          num.parse(json.substring(start, end)),
          start,
          end,
        ),
        end,
      );
    } else {
      return (ASTNumber(num.parse(json.substring(start, end))), end);
    }
  }
}

extension on String {
  String? at(int index) => index < length ? this[index] : null;
}
