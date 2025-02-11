import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/foundation/constants.dart';
import 'package:flutter_staggered_grid_view/src/layouts/sliver_patterned_grid_delegate.dart';

/// A tile of a staired pattern.
@immutable
class StairedGridTile {
  /// Creates a [StairedGridTile].
  const StairedGridTile(
    this.crossAxisRatio,
    this.aspectRatio,
  )   : assert(crossAxisRatio > 0 && crossAxisRatio <= 1),
        assert(aspectRatio > 0);

  /// The amount of extent this tile is taking in the cross axis, according to
  /// the usable cross axis extent.
  /// Must be between 0 and 1.
  final double crossAxisRatio;

  /// The ratio of the cross-axis to the main-axis extent of the tile.
  /// Must be greater than 0.
  final double aspectRatio;

  @override
  String toString() {
    return 'StairedGridTile($crossAxisRatio, $aspectRatio)';
  }
}

/// Controls the layout of tiles in a staired grid.
class SliverStairedGridDelegate
    extends SliverPatternGridDelegate<StairedGridTile> {
  /// Creates a [SliverStairedGridDelegate].
  const SliverStairedGridDelegate({
    required List<StairedGridTile> pattern,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.tileBottomSpace = 0,
    this.startCrossAxisDirectionReversed = false,
  })  : assert(tileBottomSpace >= 0),
        super.count(
          pattern: pattern,
          crossAxisCount: 1,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  /// The number of logical pixels of the space below each tile.
  final double tileBottomSpace;

  /// Indicates whether we should start to place the tile in the reverse cross
  /// axis direction.
  final bool startCrossAxisDirectionReversed;

  @override
  SliverPatternGridGeometries getGeometries(
    SliverConstraints constraints,
    int crossAxisCount,
  ) {
    final maxCrossAxisExtent = constraints.crossAxisExtent;
    final List<SliverGridGeometry> geometries = List.filled(
      pattern.length,
      kZeroGeometry,
    );
    int i = 0;
    double mainAxisOffset = 0;
    List<double> crossAxisOffsets = [0];
    
    while (i < tileCount) {
      int startIndex = i;
      double crossAxisRatioSum = 0;
      while (crossAxisRatioSum < 1 && i < tileCount) {
        crossAxisRatioSum += pattern[i].crossAxisRatio;
        i++;
      }
      if (crossAxisRatioSum > 1) {
        i--;
      }
      
      final isHorizontal = constraints.axis == Axis.horizontal;
      final usableCrossAxisExtent = maxCrossAxisExtent - ((i - startIndex - 1) * crossAxisSpacing);
      double targetMainAxisOffset = 0;
      
      List<double> tempCrossAxisOffsets = crossAxisOffsets.isNotEmpty ? List.from(crossAxisOffsets) : [0];
      crossAxisOffsets.clear();
      
      for (int j = startIndex; j < i; j++) {
        final tile = pattern[j];
        final crossAxisExtent = usableCrossAxisExtent * tile.crossAxisRatio;
        final mainAxisExtent = crossAxisExtent / tile.aspectRatio;
        
        double crossAxisOffset = tempCrossAxisOffsets.isNotEmpty ? tempCrossAxisOffsets.removeAt(0) : 0;
        
        final tileRect = SliverGridGeometry(
          scrollOffset: mainAxisOffset,
          crossAxisOffset: crossAxisOffset,
          mainAxisExtent: mainAxisExtent,
          crossAxisExtent: crossAxisExtent,
        );
        
        final endMainAxisOffset = mainAxisOffset + mainAxisExtent;
        geometries[j] = tileRect;
        
        if (endMainAxisOffset > targetMainAxisOffset) {
          targetMainAxisOffset = endMainAxisOffset;
        }
        
        double nextCrossAxisOffset = crossAxisOffset + crossAxisExtent + crossAxisSpacing;
        if (nextCrossAxisOffset + crossAxisExtent <= maxCrossAxisExtent) {
          crossAxisOffsets.add(nextCrossAxisOffset);
        } else {
          crossAxisOffsets.add(0);
        }
      }

      mainAxisOffset = targetMainAxisOffset + mainAxisSpacing;
    }

    return SliverPatternGridGeometries(tiles: geometries, bounds: geometries);
  }

  @override
  bool shouldRelayout(SliverStairedGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.startCrossAxisDirectionReversed !=
            startCrossAxisDirectionReversed;
  }
}
