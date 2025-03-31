import 'package:collection/collection.dart';

import 'ast.dart';

extension ASTNodeWithLocationExtension on ASTNodeWithLocation {
  int get length => end - start;

  bool contains(int index) => start <= index && index < end;

  bool containsRange(int start, int end) =>
      this.start <= start && end <= this.end;

  bool containsNode(ASTNodeWithLocation node) =>
      containsRange(node.start, node.end);

  ASTNodeWithLocation? getNodeByOffset(int offset) {
    if (!contains(offset)) return null;
    return switch (this) {
      ASTArrayWithLocation array => array.elements
              .map((e) => e.getNodeByOffset(offset))
              .firstWhereOrNull((e) => e != null) ??
          this,
      ASTObjectWithLocation object => object.properties.keys
              .map((e) => e.getNodeByOffset(offset))
              .firstWhereOrNull((e) => e != null) ??
          object.properties.values
              .map((e) => e.getNodeByOffset(offset))
              .firstWhereOrNull((e) => e != null) ??
          this,
      _ => this,
    };
  }

  String? getPathByOffset(int offset) {
    if (!contains(offset)) return null;

    switch (this) {
      case ASTArrayWithLocation array:
        final index = array.elements.indexWhere((e) => e.contains(offset));

        if (index == -1) return '';

        return '[$index]${array.elements[index].getPathByOffset(offset)}';
      case ASTObjectWithLocation object:
        final key = object.properties.keys //
            .firstWhereOrNull((e) => e.contains(offset));

        if (key != null) {
          return '["$key"]';
        }

        final value = object.properties.values //
            .firstWhereOrNull((e) => e.contains(offset));

        if (value == null) return '';

        return '["$value"]${value.getPathByOffset(offset)}';
      default:
        return '';
    }
  }
}
