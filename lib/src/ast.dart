import 'package:collection/collection.dart';

sealed class ASTNode {
  const ASTNode();
}

abstract interface class ASTNodeWithLocation implements ASTNode {
  int get start;
  int get end;
}

abstract mixin class ASTObject implements ASTNode, Map<ASTString, ASTNode> {
  factory ASTObject(Map<ASTString, ASTNode> properties) = _ASTObject;
}

class _ASTObject extends DelegatingMap<ASTString, ASTNode> with ASTObject {
  const _ASTObject(super.base);

  @override
  String toString() => 'ASTObject(${super.toString()})';
}

class ASTObjectWithLocation extends DelegatingMap<ASTString, ASTNode>
    with ASTObject
    implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  final int end;

  const ASTObjectWithLocation(super.base, this.start, this.end);

  @override
  String toString() => 'ASTObject($start, $end, ${super.toString()})';
}

abstract mixin class ASTArray implements ASTNode, List<ASTNode> {
  factory ASTArray(List<ASTNode> elements) = _ASTArray;
}

class _ASTArray extends DelegatingList<ASTNode> with ASTArray {
  const _ASTArray(super.base);

  @override
  String toString() => 'ASTArray(${super.toString()})';
}

class ASTArrayWithLocation extends DelegatingList<ASTNode>
    with ASTArray
    implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  final int end;

  const ASTArrayWithLocation(super.base, this.start, this.end);

  @override
  String toString() => 'ASTArray($start, $end, ${super.toString()})';
}

class ASTString extends ASTNode {
  final String value;

  const ASTString(this.value);

  @override
  bool operator ==(Object other) => switch (other) {
    ASTString(value: final v) => v == value,
    String v => v == value,
    _ => false,
  };

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  String toJson() => value;
}

class ASTStringWithLocation extends ASTString implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  final int end;

  const ASTStringWithLocation(super.value, this.start, this.end);

  @override
  String toString() => 'ASTString("$value", $start, $end)';
}

class ASTNumber extends ASTNode {
  final num value;

  const ASTNumber(this.value);

  @override
  bool operator ==(Object other) => switch (other) {
    ASTNumber(value: final v) => v == value,
    num v => v == value,
    _ => false,
  };

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ASTNumber($value)';

  num toJson() => value;
}

class ASTNumberWithLocation extends ASTNumber implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  final int end;

  const ASTNumberWithLocation(super.value, this.start, this.end);

  @override
  String toString() => 'ASTNumber($value, $start, $end)';
}

class ASTBoolean extends ASTNode {
  final bool value;

  const ASTBoolean(this.value);

  @override
  operator ==(Object other) => switch (other) {
    ASTBoolean(value: final v) => v == value,
    bool v => v == value,
    _ => false,
  };

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ASTBoolean($value)';

  bool toJson() => value;
}

class ASTBooleanWithLocation extends ASTBoolean implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  int get end => start + (value ? 4 : 5);

  const ASTBooleanWithLocation(super.value, this.start);

  @override
  String toString() => 'ASTBoolean($value, $start, $end)';
}

class ASTNull extends ASTNode {
  const ASTNull();

  @override
  bool operator ==(Object other) => other is ASTNull;

  @override
  int get hashCode => null.hashCode;

  @override
  String toString() => 'ASTNull()';

  Null toJson() => null;
}

class ASTNullWithLocation extends ASTNull implements ASTNodeWithLocation {
  @override
  final int start;
  @override
  int get end => start + 4;

  const ASTNullWithLocation(this.start);

  @override
  String toString() => 'ASTNull($start, $end)';
}
