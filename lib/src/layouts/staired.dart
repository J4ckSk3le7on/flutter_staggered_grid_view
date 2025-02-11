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
    double crossAxisOffset =
        startCrossAxisDirectionReversed ? maxCrossAxisExtent : 0;
    bool reversed = startCrossAxisDirectionReversed;

    while (i < tileCount) {
      final tile = pattern[i];
      final crossAxisExtent = maxCrossAxisExtent * tile.crossAxisRatio;
      final mainAxisExtent = crossAxisExtent / tile.aspectRatio;

      crossAxisOffset = reversed ? crossAxisOffset - crossAxisExtent : crossAxisOffset;

      geometries[i] = SliverGridGeometry(
        scrollOffset: mainAxisOffset,
        crossAxisOffset: crossAxisOffset,
        mainAxisExtent: mainAxisExtent,
        crossAxisExtent: crossAxisExtent,
      );

      mainAxisOffset += mainAxisExtent + mainAxisSpacing;
      crossAxisOffset = reversed
          ? crossAxisOffset - crossAxisSpacing
          : crossAxisOffset + crossAxisExtent + crossAxisSpacing;
      reversed = !reversed;
      i++;
    }

    return SliverPatternGridGeometries(tiles: geometries, bounds: geometries);
  }

  @override
  bool shouldRelayout(SliverStairedGridDelegate oldDelegate) {
    return super.shouldRelayout(oldDelegate) ||
        oldDelegate.tileBottomSpace != tileBottomSpace ||
        oldDelegate.startCrossAxisDirectionReversed != startCrossAxisDirectionReversed;
  }
}
