sealed class ASTNode {
  const ASTNode();
}

abstract interface class ASTNodeWithLocation implements ASTNode {
  int get start;
  int get end;
}

abstract mixin class ASTObject implements ASTNode {
  Map<ASTString, ASTNode> get properties;

  factory ASTObject(Map<ASTString, ASTNode> properties) = _ASTObject;

  @override
  bool operator ==(Object other) => switch (other) {
    ASTObject(properties: final p) => p == properties,
    Map p => p == properties,
    _ => false,
  };

  @override
  int get hashCode => properties.hashCode;

  @override
  String toString() => 'ASTObject($properties)';
}

class _ASTObject with ASTObject {
  @override
  final Map<ASTString, ASTNode> properties;

  const _ASTObject(this.properties);
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
  String toString() => 'ASTObject($properties, $start, $end)';
}

abstract mixin class ASTArray implements ASTNode {
  List<ASTNode> get elements;

  factory ASTArray(List<ASTNode> elements) = _ASTArray;

  @override
  String toString() => 'ASTArray($elements)';
}

class _ASTArray with ASTArray {
  @override
  final List<ASTNode> elements;

  const _ASTArray(this.elements);
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
  String toString() => 'ASTArray($elements, $start, $end)';
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
