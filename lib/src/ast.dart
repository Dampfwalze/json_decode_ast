sealed class ASTNode {
  const ASTNode();

  dynamic toNode();
}

sealed class ASTNodeWithLocation implements ASTNode {
  int get start;
  int get end;
}

abstract mixin class ASTObject implements ASTNode {
  Map<ASTString, ASTNode> get properties;

  factory ASTObject(Map<ASTString, ASTNode> properties) = _ASTObject;

  @override
  Map<String, dynamic> toNode() => {
    for (final entry in properties.entries)
      entry.key.value: entry.value.toNode(),
  };
}

class _ASTObject with ASTObject {
  @override
  final Map<ASTString, ASTNode> properties;

  const _ASTObject(this.properties);

  @override
  String toString() => 'ASTObject(${properties.toString()})';
}

class ASTObjectWithLocation with ASTObject implements ASTNodeWithLocation {
  @override
  final Map<ASTStringWithLocation, ASTNodeWithLocation> properties;

  @override
  final int start;
  @override
  final int end;

  const ASTObjectWithLocation(this.properties, this.start, this.end);

  @override
  String toString() => 'ASTObject($start, $end, ${properties.toString()})';
}

abstract mixin class ASTArray implements ASTNode {
  List<ASTNode> get elements;

  factory ASTArray(List<ASTNode> elements) = _ASTArray;

  @override
  List<dynamic> toNode() => [for (final element in elements) element.toNode()];
}

class _ASTArray with ASTArray {
  @override
  final List<ASTNode> elements;

  const _ASTArray(this.elements);

  @override
  String toString() => 'ASTArray(${elements.toString()})';
}

class ASTArrayWithLocation with ASTArray implements ASTNodeWithLocation {
  @override
  final List<ASTNodeWithLocation> elements;

  @override
  final int start;
  @override
  final int end;

  const ASTArrayWithLocation(this.elements, this.start, this.end);

  @override
  String toString() => 'ASTArray($start, $end, ${elements.toString()})';
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
  String toString() => 'ASTString("$value")';

  String toJson() => value;

  @override
  String toNode() => value;
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

  @override
  num toNode() => value;
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

  @override
  bool toNode() => value;
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

  @override
  Null toNode() => null;
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
