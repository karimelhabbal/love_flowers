import 'package:flutter/material.dart';

/// A product/category grid that grows its column count instead of stretching
/// cards on tablets and web, while keeping a readable maximum content width.
class ResponsiveGridView extends StatelessWidget {
  const ResponsiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxCardWidth = 210,
    this.itemHeight = 280,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(18),
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double maxCardWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawWidth = constraints.maxWidth;
        final contentWidth =
            rawWidth.isFinite && rawWidth > 900 ? 900.0 : rawWidth;
        return Center(
          child: SizedBox(
            width: contentWidth,
            child: GridView.builder(
              padding: padding,
              shrinkWrap: shrinkWrap,
              physics: physics,
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCardWidth,
                mainAxisExtent: itemHeight,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemBuilder: itemBuilder,
            ),
          ),
        );
      },
    );
  }
}
