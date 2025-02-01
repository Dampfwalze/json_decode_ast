import 'dart:convert';
import 'dart:math';

import 'package:json_ast_parser/json_ast_parser.dart';
import 'package:json_ast_parser/src/parse.dart';
import 'package:test/test.dart';

void main() {
  group('Parse values', () {
    group('String', () {
      test('Empty String', () {
        expect(parseString('""', 0), equals((ASTString(''), 2)));
      });

      test('String with value', () {
        expect(parseString('"hello"', 0), equals((ASTString('hello'), 7)));
        expect(parseString('"world"', 0), equals((ASTString('world'), 7)));
      });

      test('String with whitespace', () {
        expect(parseString('" hello "', 0), equals((ASTString(' hello '), 9)));
        expect(parseString('" world "', 0), equals((ASTString(' world '), 9)));
        expect(parseString('"   "', 0), equals((ASTString('   '), 5)));
      });

      test('Escapes', () {
        expect(parseString(r'"\n"', 0).$1, equals(ASTString('\n')));
        expect(parseString(r'"\t"', 0).$1, equals(ASTString('\t')));
        expect(parseString(r'"\r"', 0).$1, equals(ASTString('\r')));
        expect(parseString(r'"\b"', 0).$1, equals(ASTString('\b')));
        expect(parseString(r'"\f"', 0).$1, equals(ASTString('\f')));
        expect(parseString(r'"\\"', 0).$1, equals(ASTString('\\')));
        expect(parseString(r'"\/"', 0).$1, equals(ASTString('/')));
        expect(parseString(r'"\u0000"', 0).$1, equals(ASTString('\u0000')));
        expect(parseString(r'"\u0001"', 0).$1, equals(ASTString('\u0001')));
        expect(parseString(r'"\u0002"', 0).$1, equals(ASTString('\u0002')));
        expect(parseString(r'"\u0003"', 0).$1, equals(ASTString('\u0003')));
        expect(parseString(r'"\u0004"', 0).$1, equals(ASTString('\u0004')));
        expect(parseString(r'"\u0005"', 0).$1, equals(ASTString('\u0005')));
        expect(parseString(r'"\u0006"', 0).$1, equals(ASTString('\u0006')));
        expect(parseString(r'"\u0007"', 0).$1, equals(ASTString('\u0007')));
        expect(parseString(r'"\u0008"', 0).$1, equals(ASTString('\u0008')));
        expect(parseString(r'"\u0009"', 0).$1, equals(ASTString('\u0009')));
        expect(parseString(r'"\u000A"', 0).$1, equals(ASTString('\u000A')));
        expect(parseString(r'"\u000B"', 0).$1, equals(ASTString('\u000B')));
        expect(parseString(r'"\u000C"', 0).$1, equals(ASTString('\u000C')));
        expect(parseString(r'"\u000D"', 0).$1, equals(ASTString('\u000D')));
        expect(parseString(r'"\u000E"', 0).$1, equals(ASTString('\u000E')));
        expect(parseString(r'"\u000F"', 0).$1, equals(ASTString('\u000F')));
        expect(parseString(r'"\u0010"', 0).$1, equals(ASTString('\u0010')));
      });

      test('String with Escapes', () {
        expect(
          parseString(r'"hello\nworld"', 0),
          equals((ASTString('hello\nworld'), 14)),
        );
        expect(
          parseString(r'"hello\tworld"', 0),
          equals((ASTString('hello\tworld'), 14)),
        );
        expect(
          parseString(r'"hello\rworld"', 0),
          equals((ASTString('hello\rworld'), 14)),
        );
        expect(
          parseString(r'"hello\bworld"', 0),
          equals((ASTString('hello\bworld'), 14)),
        );
        expect(
          parseString(r'"hello\fworld"', 0),
          equals((ASTString('hello\fworld'), 14)),
        );
        expect(
          parseString(r'"hello\\world"', 0),
          equals((ASTString('hello\\world'), 14)),
        );
        expect(
          parseString(r'"hello\/world"', 0),
          equals((ASTString('hello/world'), 14)),
        );
        expect(
          parseString(r'"hello\u0000world"', 0),
          equals((ASTString('hello\u0000world'), 18)),
        );
      });
    });

    group('Number', () {
      test('Single digit', () {
        for (var i = 0; i < 10; i++) {
          final (v, _) = parseNumber('$i', 0);
          expect(v, equals(ASTNumber(i)));
          expect(v.value, isA<int>());
        }
      });

      test('Multiple digits', () {
        final (v, i) = parseNumber('1234567890', 0);
        expect(v, equals(ASTNumber(1234567890)));
        expect(v.value, isA<int>());
        expect(i, equals(10));
      });

      test('Negative number', () {
        final (v, i) = parseNumber('-1234567890', 0);
        expect(v, equals(ASTNumber(-1234567890)));
        expect(v.value, isA<int>());
        expect(i, equals(11));
      });

      test('Decimal number', () {
        final (v, _) = parseNumber('123.456', 0);
        expect(v, equals(ASTNumber(123.456)));
        expect(v.value, isA<double>());
      });

      test('Negative decimal number', () {
        final (v, _) = parseNumber('-123.456', 0);
        expect(v, equals(ASTNumber(-123.456)));
        expect(v.value, isA<double>());
      });

      test('Exponential number', () {
        {
          final (v, _) = parseNumber('123e4', 0);
          expect(v, equals(ASTNumber(123e4)));
          expect(v.value, isA<double>());
        }
        {
          final (v, _) = parseNumber('123E4', 0);
          expect(v, equals(ASTNumber(123e4)));
          expect(v.value, isA<double>());
        }
      });
    });

    group('Array', () {
      test('Empty', () {
        expect(parseArray('[]', 0).$1, orderedEquals([]));
        expect(parseArray('[  ]', 0).$1, orderedEquals([]));
        expect(parseArray('[\n]', 0).$1, orderedEquals([]));
        expect(() => parseArray('[,]', 0), throwsFormatException);
      });

      test('Single element', () {
        expect(parseArray('[0]', 0).$1, orderedEquals([ASTNumber(0)]));
        expect(parseArray('[0,]', 0).$1, orderedEquals([ASTNumber(0)]));
        expect(parseArray('["", ]', 0).$1, orderedEquals([ASTString("")]));
        expect(
          parseArray('[  true\n]', 0).$1,
          orderedEquals([ASTBoolean(true)]),
        );
        expect(
          parseArray('[false\n,]', 0).$1,
          orderedEquals([ASTBoolean(false)]),
        );
        expect(parseArray('[  null\n, ]', 0).$1, orderedEquals([ASTNull()]));
      });

      test('Multiple elements', () {
        expect(
          parseArray('[0, 1, 2]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          parseArray('[0, 1, 2,]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          parseArray('[0, 1, 2, ]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
        expect(
          parseArray('[0, 1, 2,  ]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1), ASTNumber(2)]),
        );
      });
    });

    group('Object', () {
      test('Empty', () {
        expect(parseObject('{}', 0).$1, equals({}));
        expect(parseObject('{  }', 0).$1, equals({}));
        expect(parseObject('{\n}', 0).$1, equals({}));
        expect(() => parseObject('{,}', 0), throwsFormatException);
      });

      test('Single property', () {
        expect(
          parseObject('{"key":0}', 0).$1,
          equals({ASTString('key'): ASTNumber(0)}),
        );
        expect(
          parseObject('{ "key" :0,}', 0).$1,
          equals({ASTString('key'): ASTNumber(0)}),
        );
        expect(
          parseObject('{  "key"   :   0  , }', 0).$1,
          equals({ASTString('key'): ASTNumber(0)}),
        );
      });

      test('Multiple properties', () {
        expect(
          parseObject('{"key":0,"key2":1}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject('{ "key" :0, "key2":1,}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject('{  "key"   :   0  , "key2":1, }', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
      });

      test('Recursive', () {
        {
          final (object, _) = parseObject('{"key":{}}', 0);
          if (object case {
            const ASTString("key"): var p,
          } when p is ASTObject && p.isEmpty) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
        {
          final (object, _) = parseObject('{ "key":[  ] }  ', 0);
          if (object case {const ASTString("key"): []}) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
        {
          final (object, _) = parseObject(
            '{  "key "   :  [{ "Hello" : "World" }],  }',
            0,
          );
          if (object case {
            const ASTString("key "): [
              {const ASTString("Hello"): const ASTString("World")},
            ],
          }) {
          } else {
            fail('Unexpected ASTObject: $object');
          }
        }
      });
    });

    group('Line comments', () {
      test('Single line', () {
        expect(parseValue('0 // Comment', 0).$1, equals(ASTNumber(0)));
        expect(
          parseValue('//asd  \n0 // Comment\n', 0).$1,
          equals(ASTNumber(0)),
        );
        expect(
          parseValue('// Hello\n"world" //Comment\n0', 0).$1,
          equals(ASTString('world')),
        );
        expect(
          parseValue('// Hello "world" //Comment\n0', 0).$1,
          equals(ASTNumber(0)),
        );
      });

      test('In array', () {
        expect(
          parseArray('[0, // Comment\n1]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          parseArray('[0, // Hello, World\n1,]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          parseArray('[0, // [This, should, not, matter]\n1,]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
      });

      test('In object', () {
        expect(
          parseObject('{"key":0, // Comment\n"key2":1}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject('{ "key" :0, // Hello, World\n"key2":1,}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject(
            '{  "key"   :   0  , // ["This", "should", "not", "matter"]\n "key2":1, }',
            0,
          ).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject(
            '{  "key"   :   0  ,// {"this": "should", "not": "matter"}\n "key2":1, }',
            0,
          ).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
      });
    });

    group('Block comments', () {
      test('Single line', () {
        expect(parseValue('0 /* Comment */', 0).$1, equals(ASTNumber(0)));
        expect(
          parseValue('/*asd*/0/* Comment*/\n', 0).$1,
          equals(ASTNumber(0)),
        );
        expect(
          parseValue('/* Hello */"world" /*Comment*/\n0', 0).$1,
          equals(ASTString('world')),
        );
        expect(
          parseValue('/* Hello "world" */ /*Comment*/\n0', 0).$1,
          equals(ASTNumber(0)),
        );
      });

      test('In array', () {
        expect(
          parseArray('[0, /* Comment */1]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          parseArray('[0,/* Hello, World */\n1,]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
        expect(
          parseArray('[0, /* [This, should, not, matter] */1,]', 0).$1,
          orderedEquals([ASTNumber(0), ASTNumber(1)]),
        );
      });

      test('In object', () {
        expect(
          parseObject('{"key":0, /* Comment */\n"key2":1}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject('{ "key" :0,/* Hello, World */"key2":1,}', 0).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject(
            '{  "key"   :   0  , /* ["This", "should", "not", "matter"] */\n "key2":1, }',
            0,
          ).$1,
          equals({
            ASTString('key'): ASTNumber(0),
            ASTString('key2'): ASTNumber(1),
          }),
        );
        expect(
          parseObject(
            '{  "key"   :   0  ,/* {"this": "should", "not": "matter"} */"key2":1, }',
            0,
          ).$1,
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
      if (jsonDecodeAST('{}') case var p when p is ASTObject && p.isEmpty) {
      } else {
        fail('Unexpected ASTObject');
      }

      if (jsonDecodeAST('[]') case []) {
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
