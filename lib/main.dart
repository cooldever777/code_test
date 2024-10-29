import 'package:flutter/material.dart';

// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Dock(
                  items: const [
                    Icons.person,
                    Icons.message,
                    Icons.call,
                    Icons.camera,
                    Icons.photo,
                  ],
                  builder: (icon) {
                    if (icon == null) return const SizedBox(width: 64, height: 64);
                    return Container(
                      height: 48,
                      width: 48,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<IconData?> items;
  final Widget Function(IconData?) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late final List<IconData?> _items = [...widget.items];
  final GlobalKey _dockKey = GlobalKey();
  int _draggedIndex = -1;
  int _tempIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dockKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return Draggable<IconData>(
              key: ValueKey(_items[index].hashCode),
              data: _items[index],
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index;
                  _tempIndex = index;
                  _items.insert(_tempIndex, null);
                });
              },
              onDraggableCanceled: (_, __) {
                setState(() {
                  _items.remove(null);
                  _draggedIndex = -1;
                  _tempIndex = -1;
                });
              },
              onDragEnd: (_) {
                setState(() {
                  _items.remove(null);
                  if (_tempIndex >= 0 && _draggedIndex >= 0 && _draggedIndex != _tempIndex) {
                    final oldItem = _items[_draggedIndex];
                    _items.removeAt(_draggedIndex);
                    _items.insert(
                        _tempIndex < _draggedIndex ? _tempIndex : _tempIndex - 1, oldItem);
                  }
                  _draggedIndex = -1;
                  _tempIndex = -1;
                });
              },
              onDragUpdate: (details) {
                final renderBox = _dockKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  setState(() {
                    Offset position = renderBox.localToGlobal(Offset.zero);
                    Size size = renderBox.size;
                    double dx = details.localPosition.dx - position.dx;
                    double dy = details.localPosition.dy - position.dy;
                    bool insideDock = dx > 0 && dx < size.width && dy > 0 && dy < size.height;
                    int newIndex = (dx / size.width * widget.items.length).toInt();
                    newIndex = newIndex < _draggedIndex ? newIndex : newIndex + 1;
                    if (insideDock && newIndex != _draggedIndex && _draggedIndex >= 0) {
                      if (_tempIndex == newIndex) {
                        return;
                      }
                      _tempIndex = newIndex;
                      _items.remove(null);
                      _items.insert(_tempIndex, null);
                    } else {
                      _tempIndex = -1;
                      _items.remove(null);
                    }
                  });
                }
              },
              feedback: widget.builder(_items[index]),
              childWhenDragging: const SizedBox.shrink(),
              child: widget.builder(_items[index]),
            );
          }),
        ),
      ),
    );
  }
}
