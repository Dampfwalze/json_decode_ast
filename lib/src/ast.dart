sealed class ASTNode {
  const ASTNode();
}

class ASTObject extends ASTNode {
  final Map<ASTString, ASTNode> properties;

  const ASTObject(this.properties);

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

class ASTArray extends ASTNode {
  final List<ASTNode> elements;

  const ASTArray(this.elements);

  @override
  String toString() => 'ASTArray($elements)';
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

class ASTNull extends ASTNode {
  const ASTNull();

  @override
  bool operator ==(Object other) => other is ASTNull;

  @override
  int get hashCode => null.hashCode;

  @override
  String toString() => 'ASTNull()';
}
