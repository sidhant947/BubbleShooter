import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/bubble.dart';

class BubbleGridHelper {
  static const int defaultColumns = 10;

  static int getColsInRow(int row, [int baseColumns = defaultColumns, int rowOffset = 0]) {
    return (row - rowOffset) % 2 == 0 ? baseColumns : baseColumns - 1;
  }

  static double getRowHeight(double radius) {
    return radius * math.sqrt(3);
  }

  static Offset getCellCenter({
    required int row,
    required int col,
    required double radius,
    int rowOffset = 0,
  }) {
    final diameter = radius * 2;
    final rowHeight = getRowHeight(radius);
    final y = radius + row * rowHeight;
    final x = (row - rowOffset) % 2 == 0
        ? radius + col * diameter
        : diameter + col * diameter;
    return Offset(x, y);
  }

  static List<GridPosition> getNeighbors({
    required GridPosition pos,
    int baseColumns = defaultColumns,
    int maxRows = 20,
    int rowOffset = 0,
  }) {
    final r = pos.row;
    final c = pos.col;
    final neighbors = <GridPosition>[];

    final isEven = (r - rowOffset) % 2 == 0;
    final currentCols = getColsInRow(r, baseColumns, rowOffset);

    if (c > 0) neighbors.add(GridPosition(r, c - 1));
    if (c < currentCols - 1) neighbors.add(GridPosition(r, c + 1));

    if (r > rowOffset) {
      if (isEven) {
        if (c > 0) neighbors.add(GridPosition(r - 1, c - 1));
        if (c < baseColumns - 1) neighbors.add(GridPosition(r - 1, c));
      } else {
        neighbors.add(GridPosition(r - 1, c));
        neighbors.add(GridPosition(r - 1, c + 1));
      }
    }

    if (r < maxRows - 1) {
      if (isEven) {
        if (c > 0) neighbors.add(GridPosition(r + 1, c - 1));
        if (c < baseColumns - 1) neighbors.add(GridPosition(r + 1, c));
      } else {
        neighbors.add(GridPosition(r + 1, c));
        neighbors.add(GridPosition(r + 1, c + 1));
      }
    }

    return neighbors;
  }

  static Set<GridPosition> findConnectedSameColor({
    required GridPosition start,
    required Map<GridPosition, BubbleColor> grid,
    int baseColumns = defaultColumns,
    int maxRows = 20,
    int rowOffset = 0,
  }) {
    final targetColor = grid[start];
    if (targetColor == null) return {};

    final matches = <GridPosition>{start};
    final queue = <GridPosition>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final neighbors = getNeighbors(
        pos: current,
        baseColumns: baseColumns,
        maxRows: maxRows,
        rowOffset: rowOffset,
      );

      for (final neighbor in neighbors) {
        if (!matches.contains(neighbor) && grid[neighbor] == targetColor) {
          matches.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    return matches;
  }

  static List<GridPosition> findFloatingBubbles({
    required Map<GridPosition, BubbleColor> grid,
    int baseColumns = defaultColumns,
    int maxRows = 20,
    int rowOffset = 0,
  }) {
    if (grid.isEmpty) return [];

    final connectedToCeiling = <GridPosition>{};
    final queue = <GridPosition>[];

    for (final entry in grid.entries) {
      if (entry.key.row == rowOffset) {
        connectedToCeiling.add(entry.key);
        queue.add(entry.key);
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final neighbors = getNeighbors(
        pos: current,
        baseColumns: baseColumns,
        maxRows: maxRows,
        rowOffset: rowOffset,
      );

      for (final neighbor in neighbors) {
        if (grid.containsKey(neighbor) && !connectedToCeiling.contains(neighbor)) {
          connectedToCeiling.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    final floating = <GridPosition>[];
    for (final pos in grid.keys) {
      if (!connectedToCeiling.contains(pos)) {
        floating.add(pos);
      }
    }

    return floating;
  }

  static GridPosition findClosestEmptyCell({
    required Offset impactPoint,
    required Map<GridPosition, BubbleColor> grid,
    required double radius,
    int baseColumns = defaultColumns,
    int maxRows = 20,
    int rowOffset = 0,
    GridPosition? hitCell,
    Offset? flyingVelocity,
  }) {
    if (hitCell != null) {
      final neighbors = getNeighbors(
        pos: hitCell,
        baseColumns: baseColumns,
        maxRows: maxRows,
        rowOffset: rowOffset,
      );

      final emptyNeighbors = neighbors.where((n) => !grid.containsKey(n)).toList();
      if (emptyNeighbors.isNotEmpty) {
        GridPosition? bestPos;
        double minScore = double.infinity;

        final hitCenter = getCellCenter(
          row: hitCell.row,
          col: hitCell.col,
          radius: radius,
          rowOffset: rowOffset,
        );
        final hitToImpact = impactPoint - hitCenter;
        final dir = hitToImpact.distance > 0.001
            ? hitToImpact / hitToImpact.distance
            : (flyingVelocity != null && flyingVelocity.distance > 0.001
                ? flyingVelocity / flyingVelocity.distance
                : const Offset(0, 1));

        for (final neighbor in emptyNeighbors) {
          final neighborCenter = getCellCenter(
            row: neighbor.row,
            col: neighbor.col,
            radius: radius,
            rowOffset: rowOffset,
          );
          final dist = (neighborCenter - impactPoint).distance;

          final neighborVec = neighborCenter - hitCenter;
          final neighborDir = neighborVec.distance > 0.001
              ? neighborVec / neighborVec.distance
              : const Offset(0, 0);

          final alignment = dir.dx * neighborDir.dx + dir.dy * neighborDir.dy;
          final score = dist - (alignment * radius * 0.85);

          if (score < minScore) {
            minScore = score;
            bestPos = neighbor;
          }
        }

        if (bestPos != null) return bestPos;
      }
    }

    GridPosition? globalBest;
    double globalMinDist = double.infinity;

    for (int r = rowOffset; r < maxRows; r++) {
      final cols = getColsInRow(r, baseColumns, rowOffset);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        if (!grid.containsKey(pos)) {
          final center = getCellCenter(
            row: r,
            col: c,
            radius: radius,
            rowOffset: rowOffset,
          );
          final dist = (center - impactPoint).distance;
          if (dist < globalMinDist) {
            globalMinDist = dist;
            globalBest = pos;
          }
        }
      }
    }

    return globalBest ?? GridPosition(rowOffset, 0);
  }
}
