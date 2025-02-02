import 'dart:convert';
import 'dart:math';

import 'package:json_ast_parser/json_ast_parser.dart';
import 'package:json_ast_parser/src/parse.dart';
import 'package:test/test.dart';

void main() {
  group('Parse values', () {
    final p = JsonAstDecoderImpl();

    group('String', () {
      test('Empty String', () {
        expect(p.parseString('""', 0), equals((ASTString(''), 2)));
      });

      test('String with value', () {
        expect(p.parseString('"hello"', 0), equals((ASTString('hello'), 7)));
        expect(p.parseString('"world"', 0), equals((ASTString('world'), 7)));
      });

      test('String with whitespace', () {
        expect(
          p.parseString('" hello "', 0),
          equals((ASTString(' hello '), 9)),
        );
        expect(
          p.parseString('" world "', 0),
          equals((ASTString(' world '), 9)),
        );
        expect(p.parseString('"   "', 0), equals((ASTString('   '), 5)));
      });

      test('Escapes', () {
        expect(p.parseString(r'"\n"', 0).$1, equals(ASTString('\n')));
        expect(p.parseString(r'"\t"', 0).$1, equals(ASTString('\t')));
        expect(p.parseString(r'"\r"', 0).$1, equals(ASTString('\r')));
        expect(p.parseString(r'"\b"', 0).$1, equals(ASTString('\b')));
        expect(p.parseString(r'"\f"', 0).$1, equals(ASTString('\f')));
        expect(p.parseString(r'"\\"', 0).$1, equals(ASTString('\\')));
        expect(p.parseString(r'"\/"', 0).$1, equals(ASTString('/')));
        expect(p.parseString(r'"\u0000"', 0).$1, equals(ASTString('\u0000')));
        expect(p.parseString(r'"\u0001"', 0).$1, equals(ASTString('\u0001')));
        expect(p.parseString(r'"\u0002"', 0).$1, equals(ASTString('\u0002')));
        expect(p.parseString(r'"\u0003"', 0).$1, equals(ASTString('\u0003')));
        expect(p.parseString(r'"\u0004"', 0).$1, equals(ASTString('\u0004')));
        expect(p.parseString(r'"\u0005"', 0).$1, equals(ASTString('\u0005')));
        expect(p.parseString(r'"\u0006"', 0).$1, equals(ASTString('\u0006')));
        expect(p.parseString(r'"\u0007"', 0).$1, equals(ASTString('\u0007')));
        expect(p.parseString(r'"\u0008"', 0).$1, equals(ASTString('\u0008')));
        expect(p.parseString(r'"\u0009"', 0).$1, equals(ASTString('\u0009')));
        expect(p.parseString(r'"\u000A"', 0).$1, equals(ASTString('\u000A')));
        expect(p.parseString(r'"\u000B"', 0).$1, equals(ASTString('\u000B')));
        expect(p.parseString(r'"\u000C"', 0).$1, equals(ASTString('\u000C')));
        expect(p.parseString(r'"\u000D"', 0).$1, equals(ASTString('\u000D')));
        expect(p.parseString(r'"\u000E"', 0).$1, equals(ASTString('\u000E')));
        expect(p.parseString(r'"\u000F"', 0).$1, equals(ASTString('\u000F')));
        expect(p.parseString(r'"\u0010"', 0).$1, equals(ASTString('\u0010')));
      });

      test('String with Escapes', () {
        expect(
          p.parseString(r'"hello\nworld"', 0),
          equals((ASTString('hello\nworld'), 14)),
        );
        expect(
          p.parseString(r'"hello\tworld"', 0),
          equals((ASTString('hello\tworld'), 14)),
        );
        expect(
          p.parseString(r'"hello\rworld"', 0),
          equals((ASTString('hello\rworld'), 14)),
        );
        expect(
          p.parseString(r'"hello\bworld"', 0),
          equals((ASTString('hello\bworld'), 14)),
        );
        expect(
          p.parseString(r'"hello\fworld"', 0),
          equals((ASTString('hello\fworld'), 14)),
        );
        expect(
          p.parseString(r'"hello\\world"', 0),
          equals((ASTString('hello\\world'), 14)),
        );
        expect(
          p.parseString(r'"hello\/world"', 0),
          equals((ASTString('hello/world'), 14)),
        );
        expect(
          p.parseString(r'"hello\u0000world"', 0),
          equals((ASTString('hello\u0000world'), 18)),
        );
      });
    });

    group('Number', () {
      test('Single digit', () {
        for (var i = 0; i < 10; i++) {
          final (v, _) = p.parseNumber('$i', 0);
          expect(v, equals(ASTNumber(i)));
          expect(v.value, isA<int>());
        }
      });

      test('Multiple digits', () {
        final (v, i) = p.parseNumber('1234567890', 0);
        expect(v, equals(ASTNumber(1234567890)));
        expect(v.value, isA<int>());
        expect(i, equals(10));
      });

      test('Negative number', () {
        final (v, i) = p.parseNumber('-1234567890', 0);
        expect(v, equals(ASTNumber(-1234567890)));
        expect(v.value, isA<int>());
        expect(i, equals(11));
      });

      test('Decimal number', () {
        final (v, _) = p.parseNumber('123.456', 0);
        expect(v, equals(ASTNumber(123.456)));
        expect(v.value, isA<double>());
      });

      test('Negative decimal number', () {
        final (v, _) = p.parseNumber('-123.456', 0);
        expect(v, equals(ASTNumber(-123.456)));
        expect(v.value, isA<double>());
      });

      test('Exponential number', () {
        {
          final (v, _) = p.parseNumber('123e4', 0);
          expect(v, equals(ASTNumber(123e4)));
          expect(v.value, isA<double>());
        }
        {
          final (v, _) = p.parseNumber('123E4', 0);
          expect(v, equals(ASTNumber(123e4)));
          expect(v.value, isA<double>());
        }
      });
    });

    group('Array', () {
      test('Empty', () {
        expect(p.parseArray('[]', 0).$1.elements, orderedEquals([]));
        expect(p.parseArray('[  ]', 0).$1.elements, orderedEquals([]));
        expect(p.parseArray('[\n]', 0).$1.elements, orderedEquals([]));
        expect(() => p.parseArray('[,]', 0), throwsFormatException);
      });

      test('Single element', () {
        expect(
          p.parseArray('[0]', 0).$1.elements,
          orderedEquals([ASTNumber(0)]),
        );
        expect(
          p.parseArray('[0,]', 0).$1.elements,
          orderedEquals([ASTNumber(0)]),
        );
        expect(
          p.parseArray('["", ]', 0).$1.elements,
          orderedEquals([ASTString("")]),
        );
        expect(
          p.parseArray('[  true\n]', 0).$1.elements,
          orderedEquals([ASTBoolean(true)]),
        );
        expect(
          p.parseArray('[false\n,]', 0).$1.elements,
          orderedEquals([ASTBoolean(false)]),
        );
        expect(
          p.parseArray('[  null\n, ]', 0).$1.elements,
          orderedEquals([ASTNull()]),
        );
      });

      test('Multiple elements', () {
        expect(
          p.parseArray('[0, 1, 2]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          p.parseArray('[0, 1, 2,]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          p.parseArray('[0, 1, 2, ]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          p.parseArray('[0, 1, 2,  ]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
      });
    });

    group('Object', () {
      test('Empty', () {
        expect(p.parseObject('{}', 0).$1.properties, equals({}));
        expect(p.parseObject('{  }', 0).$1.properties, equals({}));
        expect(p.parseObject('{\n}', 0).$1.properties, equals({}));
        expect(() => p.parseObject('{,}', 0), throwsFormatException);
      });

      test('Single property', () {
        expect(
          p.parseObject('{"key":0}', 0).$1.properties,
          equals({ASTString('key'): ASTNumber(0)}),
        );
        expect(
          p.parseObject('{ "key" :0,}', 0).$1.properties,
          equals({ASTString('key'): ASTNumber(0)}),
        );
        expect(
          p.parseObject('{  "key"   :   0  , }', 0).$1.properties,
          equals({ASTString('key'): ASTNumber(0)}),
        );
      });

      test('Multiple properties', () {
        expect(
          p.parseObject('{"key":0,"key2":1}', 0).$1.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p.parseObject('{ "key" :0, "key2":1,}', 0).$1.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p.parseObject('{  "key"   :   0  , "key2":1, }', 0).$1.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
      });

      test('Recursive', () {
        {
          final (object, _) = p.parseObject('{"key":{}}', 0);
          if (object case ASTObject(
            properties: {const ASTString("key"): ASTObject(properties: var p)},
          ) when p.isEmpty) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
        {
          final (object, _) = p.parseObject('{ "key":[  ] }  ', 0);
          if (object case ASTObject(
            properties: {const ASTString("key"): ASTArray(elements: [])},
          )) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
        {
          final (object, _) = p.parseObject(
            '{  "key "   :  [{ "Hello" : "World" }],  }',
            0,
          );
          if (object case ASTObject(
            properties: {
              const ASTString("key "): ASTArray(
                elements: [
                  ASTObject(
                    properties: {
                      const ASTString("Hello"): const ASTString("World"),
                    },
                  ),
                ],
              ),
            },
          )) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
      });
    });

    group('Line comments', () {
      test('Comments not allowed', () {
        final p = JsonAstDecoder(allowComments: false);
        expect(() => p.convert('0 // Comment'), throwsFormatException);
        expect(
          () => p.convert('//asd  \n0 // Comment\n'),
          throwsFormatException,
        );
      });

      test('Single line', () {
        expect(p.parseValue('0 // Comment', 0).$1, equals(ASTNumber(0)));
        expect(
          p.parseValue('//asd  \n0 // Comment\n', 0).$1,
          equals(ASTNumber(0)),
        );
        expect(
          p.parseValue('// Hello\n"world" //Comment\n0', 0).$1,
          equals(ASTString('world')),
        );
        expect(
          p.parseValue('// Hello "world" //Comment\n0', 0).$1,
          equals(ASTNumber(0)),
        );
      });

      test('In array', () {
        expect(
          p.parseArray('[0, // Comment\n1]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          p.parseArray('[0, // Hello, World\n1,]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          p
              .parseArray('[0, // [This, should, not, matter]\n1,]', 0)
              .$1
              .elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
      });

      test('In object', () {
        expect(
          p.parseObject('{"key":0, // Comment\n"key2":1}', 0).$1.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject('{ "key" :0, // Hello, World\n"key2":1,}', 0)
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject(
                '{  "key"   :   0  , // ["This", "should", "not", "matter"]\n "key2":1, }',
                0,
              )
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject(
                '{  "key"   :   0  ,// {"this": "should", "not": "matter"}\n "key2":1, }',
                0,
              )
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
      });
    });

    group('Block comments', () {
      test('Comments not allowed', () {
        final p = JsonAstDecoder(allowComments: false);
        expect(() => p.convert('0 /* Comment */'), throwsFormatException);
        expect(
          () => p.convert('/*asd*/0/* Comment*/\n'),
          throwsFormatException,
        );
      });

      test('Single line', () {
        expect(p.parseValue('0 /* Comment */', 0).$1, equals(ASTNumber(0)));
        expect(
          p.parseValue('/*asd*/0/* Comment*/\n', 0).$1,
          equals(ASTNumber(0)),
        );
        expect(
          p.parseValue('/* Hello */"world" /*Comment*/\n0', 0).$1,
          equals(ASTString('world')),
        );
        expect(
          p.parseValue('/* Hello "world" */ /*Comment*/\n0', 0).$1,
          equals(ASTNumber(0)),
        );
      });

      test('In array', () {
        expect(
          p.parseArray('[0, /* Comment */1]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          p.parseArray('[0,/* Hello, World */\n1,]', 0).$1.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          p
              .parseArray('[0, /* [This, should, not, matter] */1,]', 0)
              .$1
              .elements,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
      });

      test('In object', () {
        expect(
          p.parseObject('{"key":0, /* Comment */\n"key2":1}', 0).$1.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject('{ "key" :0,/* Hello, World */"key2":1,}', 0)
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject(
                '{  "key"   :   0  , /* ["This", "should", "not", "matter"] */\n "key2":1, }',
                0,
              )
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          p
              .parseObject(
                '{  "key"   :   0  ,/* {"this": "should", "not": "matter"} */"key2":1, }',
                0,
              )
              .$1
              .properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
      });
    });
  });

  group('Decode JSON', () {
    test('Single values', () {
      if (jsonDecodeAST('{}') case ASTObject(
        properties: var p,
      ) when p.isEmpty) {
      } else {
        fail('Unexpected ASTObject');
      }

      if (jsonDecodeAST('[]') case ASTArray(elements: [])) {
      } else {
        fail('Unexpected ASTArray');
      }

      expect(jsonDecodeAST(' {  }  '), isA<ASTObject>());
      expect(jsonDecodeAST(' [  ]  '), isA<ASTArray>());
      expect(jsonDecodeAST('0'), equals(ASTNumber(0)));
      expect(jsonDecodeAST('  0.0  '), equals(ASTNumber(0.0)));
      expect(jsonDecodeAST('  "hello"  '), equals(ASTString('hello')));
      expect(jsonDecodeAST('  true'), equals(ASTBoolean(true)));
      expect(jsonDecodeAST('false\n'), equals(ASTBoolean(false)));
      expect(jsonDecodeAST('null'), equals(ASTNull()));
    });

    test('Big JSON', () {
      final random = Random(83792465);
      final json = randomJson(random);
      final jsonString = jsonEncode(json);

      jsonDecodeAST(jsonString);
    });
  });

  group('Decode with location', () {
    test('String', () {
      {
        final ast = jsonDecodeASTWithLocation('"hello"');
        expect(ast, isA<ASTStringWithLocation>());
        ast as ASTStringWithLocation;
        expect(ast.value, equals('hello'));
        expect(ast.start, equals(0));
        expect(ast.end, equals(7));
      }
      {
        final ast = jsonDecodeASTWithLocation('  "hello\tworld"');
        expect(ast, isA<ASTStringWithLocation>());
        ast as ASTStringWithLocation;
        expect(ast.value, equals('hello\tworld'));
        expect(ast.start, equals(2));
        expect(ast.end, equals(15));
      }
    });

    test('Number', () {
      {
        final ast = jsonDecodeASTWithLocation('123');
        expect(ast, isA<ASTNumberWithLocation>());
        ast as ASTNumberWithLocation;
        expect(ast.value, equals(123));
        expect(ast.start, equals(0));
        expect(ast.end, equals(3));
      }
      {
        final ast = jsonDecodeASTWithLocation('  123.456  ');
        expect(ast, isA<ASTNumberWithLocation>());
        ast as ASTNumberWithLocation;
        expect(ast.value, equals(123.456));
        expect(ast.start, equals(2));
        expect(ast.end, equals(9));
      }
      {
        final ast = jsonDecodeASTWithLocation('  -123.456  ');
        expect(ast, isA<ASTNumberWithLocation>());
        ast as ASTNumberWithLocation;
        expect(ast.value, equals(-123.456));
        expect(ast.start, equals(2));
        expect(ast.end, equals(10));
      }
      {
        final ast = jsonDecodeASTWithLocation('  123e4  ');
        expect(ast, isA<ASTNumberWithLocation>());
        ast as ASTNumberWithLocation;
        expect(ast.value, equals(123e4));
        expect(ast.start, equals(2));
        expect(ast.end, equals(7));
      }
    });

    test('Bool', () {
      {
        final ast = jsonDecodeASTWithLocation('true');
        expect(ast, isA<ASTBooleanWithLocation>());
        ast as ASTBooleanWithLocation;
        expect(ast.value, equals(true));
        expect(ast.start, equals(0));
        expect(ast.end, equals(4));
      }
      {
        final ast = jsonDecodeASTWithLocation('  false  ');
        expect(ast, isA<ASTBooleanWithLocation>());
        ast as ASTBooleanWithLocation;
        expect(ast.value, equals(false));
        expect(ast.start, equals(2));
        expect(ast.end, equals(7));
      }
    });

    test('Null', () {
      {
        final ast = jsonDecodeASTWithLocation('null');
        expect(ast, isA<ASTNullWithLocation>());
        ast as ASTNullWithLocation;
        expect(ast.start, equals(0));
        expect(ast.end, equals(4));
      }
      {
        final ast = jsonDecodeASTWithLocation('  null  ');
        expect(ast, isA<ASTNullWithLocation>());
        ast as ASTNullWithLocation;
        expect(ast.start, equals(2));
        expect(ast.end, equals(6));
      }
    });

    test('List', () {
      {
        final ast = jsonDecodeASTWithLocation('[0, 1, 2]');
        expect(ast, isA<ASTArrayWithLocation>());
        ast as ASTArrayWithLocation;
        expect(
          ast.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(ast.start, equals(0));
        expect(ast.end, equals(9));
      }
      {
        final ast = jsonDecodeASTWithLocation('  [0, 1, 2]  ');
        expect(ast, isA<ASTArrayWithLocation>());
        ast as ASTArrayWithLocation;
        expect(
          ast.elements,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(ast.start, equals(2));
        expect(ast.end, equals(11));
      }
    });

    test('Object', () {
      {
        final ast = jsonDecodeASTWithLocation('{"key":0,"key2":1}');
        expect(ast, isA<ASTObjectWithLocation>());
        ast as ASTObjectWithLocation;
        expect(
          ast.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(ast.start, equals(0));
        expect(ast.end, equals(18));
      }
      {
        final ast = jsonDecodeASTWithLocation(
          '  {  "key"  :   0   ,   "key2"  :  1  ,  }  ',
        );
        expect(ast, isA<ASTObjectWithLocation>());
        ast as ASTObjectWithLocation;
        expect(
          ast.properties,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(ast.start, equals(2));
        expect(ast.end, equals(42));
      }
    });
  });

  group('Benchmark', () {
    test('Big JSON', () {
      final random = Random(83792465);

      final times = <(Duration, Duration, Duration)>[];

      for (final jsonString in Iterable.generate(30, (_) {
        while (true) {
          final json = jsonEncode(randomJson(random, 10));
          if (json.length > 500) {
            return json;
          }
        }
      })) {
        final stopwatch = Stopwatch()..start();
        jsonDecode(jsonString);
        final stdDuration = stopwatch.elapsed;
        stopwatch.reset();
        jsonDecodeAST(jsonString);
        final astDuration = stopwatch.elapsed;
        stopwatch.reset();
        jsonDecodeASTWithLocation(jsonString);
        final astLocationDuration = stopwatch.elapsed;

        print(
          'std: $stdDuration, ast: $astDuration, loc: $astLocationDuration, '
          'ratio: ${(astDuration.inMicroseconds / stdDuration.inMicroseconds * 100).toStringAsFixed(2)} %, '
          'loc ratio: ${(astLocationDuration.inMicroseconds / stdDuration.inMicroseconds * 100).toStringAsFixed(2)} %',
        );

        times.add((stdDuration, astDuration, astLocationDuration));
      }

      final average = times.reduce(
        (a, b) => (a.$1 + b.$1, a.$2 + b.$2, a.$3 + b.$3),
      );

      print(
        '\nstd average: ${average.$1}, ast average: ${average.$2}, loc average: ${average.$3}, '
        'ratio: ${(average.$2.inMicroseconds / average.$1.inMicroseconds * 100).toStringAsFixed(2)} %, '
        'loc ratio: ${(average.$3.inMicroseconds / average.$1.inMicroseconds * 100).toStringAsFixed(2)} %, '
        'with/without location: ${(average.$3.inMicroseconds / average.$2.inMicroseconds * 100).toStringAsFixed(2)} %',
      );
    });
  });
}

dynamic randomJson(Random random, [int maxDepth = 10]) => switch (random
    .nextInt(maxDepth + 2)) {
  final v when v <= maxDepth => switch (random.nextBool()) {
    true => {
      if (random.nextInt(5 + maxDepth) case var count)
        for (var i = 0; i < count - 1; i++)
          randomString(random): randomJson(random, maxDepth - 1),
    },
    false => [
      if (random.nextInt(5 + maxDepth) case var count)
        for (var i = 0; i < count; i++) randomJson(random, maxDepth - 1),
    ],
  },
  _ => randomJsonElement(random),
};

dynamic randomJsonElement(Random random) => switch (random.nextInt(11)) {
  var r when r <= 4 => randomString(random),
  5 => random.nextInt(1000),
  6 || 7 => random.nextDouble(),
  8 || 9 => random.nextBool(),
  10 => null,
  _ => throw UnimplementedError(),
};

String randomString(Random random) {
  final length = random.nextInt(10);
  return String.fromCharCodes(
    List.generate(length, (_) => random.nextInt(26) + 97),
  );
}
