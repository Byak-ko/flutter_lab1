import 'package:flutter/material.dart';

class CheckboxNode extends ChangeNotifier {
  CheckboxNode(
    this.label, {
    List<CheckboxNode> children = const [],
    this._checked = false,
  }) : children = List.unmodifiable(children) {
    for (final child in this.children) {
      child._parent = this;
    }
  }

  final String label;
  final List<CheckboxNode> children;
  CheckboxNode? _parent;
  bool _checked;

  bool get isLeaf => children.isEmpty;

  bool? get value {
    if (isLeaf) return _checked;
    bool? result;
    for (final child in children) {
      final v = child.value;
      if (v == null) return null;
      result ??= v;
      if (result != v) return null;
    }
    return result;
  }

  void setValue(bool checked) {
    _setDown(checked);
    _notifyUp();
  }

  void toggle() => setValue(value != true);

  Iterable<CheckboxNode> get leaves sync* {
    if (isLeaf) {
      yield this;
    } else {
      for (final child in children) {
        yield* child.leaves;
      }
    }
  }

  Iterable<CheckboxNode> get checkedLeaves =>
      leaves.where((leaf) => leaf._checked);

  void _setDown(bool checked) {
    if (isLeaf) {
      _checked = checked;
    } else {
      for (final child in children) {
        child._setDown(checked);
      }
    }
  }

  void _notifyUp() {
    CheckboxNode? node = this;
    while (node != null) {
      node.notifyListeners();
      node = node._parent;
    }
  }
}

class TriStateCheckboxTree extends StatelessWidget {
  const TriStateCheckboxTree({super.key, required this.root, this.indent = 32});

  final CheckboxNode root;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: root,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildRows(root, 0).toList(),
      ),
    );
  }

  Iterable<Widget> _buildRows(CheckboxNode node, int depth) sync* {
    yield Padding(
      padding: EdgeInsetsDirectional.only(start: indent * depth),
      child: CheckboxListTile(
        key: ValueKey(node),
        controlAffinity: ListTileControlAffinity.leading,
        tristate: !node.isLeaf,
        value: node.value,
        onChanged: (_) => node.toggle(),
        title: Text(
          node.label,
          style: node.isLeaf
              ? null
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        dense: node.isLeaf,
      ),
    );
    for (final child in node.children) {
      yield* _buildRows(child, depth + 1);
    }
  }
}
