import 'dart:math' as math;
import '../models/bubble.dart';
import '../models/bubble_level.dart';
import 'bubble_grid_helper.dart';

enum PuzzleMaskType {
  horizontalBands,
  verticalStripes,
  checkerboard,
  diamondCore,
  vortexSpiral,
  honeycombShield,
  twinTowers,
  pyramidInverted,
  crownFortress,
  hourGlass,
  snakeRibbon,
  rainbowArch,
}

class BubbleLevelGenerator {
  static const List<String> _normalNames = [
    'Color Splash',
    'Diamond Peak',
    'Emerald Isle',
    'Spiral Vortex',
    'Sapphire Gate',
    'Checker Crest',
    'Crimson Tide',
    'Twin Pinnacles',
    'Golden Horizon',
    'Prism Citadel',
    'Amethyst Dream',
    'Hourglass Sands',
    'Tangerine Sunset',
    'Shield of Valor',
    'Neon Cascade',
    'Inverted Crown',
    'Cosmic Ribbon',
    'Honeycomb Hive',
    'Solar Flare',
    'Crystal Prism',
    'Aurora Borealis',
    'Velvet Nebula',
    'Opal Galaxy',
    'Starlight Canopy',
  ];

  static const List<String> _miniBossNames = [
    'Guardian of Vines',
    'Cerberus Peak',
    'Hydra Nexus',
    'Iron Vanguard',
    'Frost Titan',
    'Thunder Gate',
    'Shadow Golem',
    'Inferno Sentry',
  ];

  static const List<String> _godBossNames = [
    'God of Tempest',
    'Apex Celestial',
    'Lord of Obsidian',
    'Chronos Overlord',
    'Leviathan Core',
    'Abyssal Emperor',
    'Nova Sovereign',
    'Eternal Ragnarok',
  ];

  static BubbleLevel generateZenLevel() {
    final random = math.Random();
    const columns = 10;
    const maxRows = 16;
    const rowCount = 8;
    final allColors = List<BubbleColor>.from(BubbleColor.values);
    final grid = <GridPosition, BubbleColor>{};

    for (int r = 0; r < rowCount; r++) {
      final cols = BubbleGridHelper.getColsInRow(r, columns);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        final neighbors = BubbleGridHelper.getNeighbors(pos: pos, baseColumns: columns, maxRows: 16)
            .where((n) => grid.containsKey(n))
            .toList();
        if (neighbors.isNotEmpty && random.nextDouble() < 0.65) {
          final chosen = neighbors[random.nextInt(neighbors.length)];
          grid[pos] = grid[chosen]!;
        } else {
          grid[pos] = allColors[random.nextInt(allColors.length)];
        }
      }
    }

    _ensureConnectivity(grid, columns);
    _ensureSolvableClusters(grid, columns, allColors, random);
    _ensureConnectivity(grid, columns);

    return BubbleLevel(
      levelNumber: 0,
      name: 'ZEN INFINITE',
      columns: columns,
      maxRows: maxRows,
      bubbles: grid,
      shots: 999999,
      availableColors: allColors,
      levelType: LevelType.zen,
      difficultyRating: 3.5,
    );
  }

  static BubbleLevel generateLevel(int levelNumber) {
    final seed = levelNumber * 7919 + 42;
    final random = math.Random(seed);

    final isGodBoss = levelNumber % 10 == 0;
    final isMiniBoss = !isGodBoss && levelNumber % 5 == 0;
    final levelType = isGodBoss
        ? LevelType.godBoss
        : (isMiniBoss ? LevelType.miniBoss : LevelType.normal);

    final cycle = (levelNumber - 1) % 10;
    final tier = (levelNumber - 1) ~/ 10;
    final curveFactor = math.sin((cycle / 9.0) * (math.pi / 2.0));
    final double difficulty = (1.0 + (tier * 0.35) + (curveFactor * 0.7))
        * (isGodBoss ? 1.45 : (isMiniBoss ? 1.25 : 1.0));

    final baseColors = 3;
    final extraColors = (tier * 0.3 + (isGodBoss ? 1.5 : (isMiniBoss ? 1.0 : curveFactor * 0.75))).floor();
    final colorCount = (baseColors + extraColors).clamp(3, BubbleColor.values.length);

    final allColors = List<BubbleColor>.from(BubbleColor.values)..shuffle(random);
    final selectedColors = allColors.sublist(0, colorCount);

    final int rowCount;
    if (isGodBoss) {
      rowCount = (9 + (tier ~/ 2)).clamp(9, 12);
    } else if (isMiniBoss) {
      rowCount = (8 + (tier ~/ 2)).clamp(8, 11);
    } else {
      rowCount = (5 + ((cycle + tier) ~/ 2)).clamp(5, 10);
    }

    const columns = 10;
    const maxRows = 16;
    final grid = <GridPosition, BubbleColor>{};

    if (isGodBoss) {
      _generateGodBossPattern(grid, rowCount, columns, selectedColors, random, tier);
    } else if (isMiniBoss) {
      _generateMiniBossPattern(grid, rowCount, columns, selectedColors, random, tier);
    } else {
      final maskIndex = (levelNumber - 1 + tier) % PuzzleMaskType.values.length;
      final mask = PuzzleMaskType.values[maskIndex];
      _generateMaskedPattern(grid, rowCount, columns, selectedColors, random, mask);
    }

    _ensureConnectivity(grid, columns);
    _ensureSolvableClusters(grid, columns, selectedColors, random);
    _ensureConnectivity(grid, columns);

    final totalBubbles = grid.length;
    final estimatedClusters = (totalBubbles / 3.0).ceil();
    final double efficiencyRatio;
    if (isGodBoss) {
      efficiencyRatio = (1.35 - (tier * 0.01)).clamp(1.20, 1.45);
    } else if (isMiniBoss) {
      efficiencyRatio = (1.45 - (tier * 0.01)).clamp(1.30, 1.55);
    } else {
      efficiencyRatio = (1.75 - (curveFactor * 0.2) - (tier * 0.015)).clamp(1.40, 1.90);
    }

    final shots = (estimatedClusters * efficiencyRatio).ceil().clamp(16, 35);

    final String name;
    if (isGodBoss) {
      final idx = ((levelNumber ~/ 10) - 1) % _godBossNames.length;
      name = 'GOD BOSS: ${_godBossNames[idx]}';
    } else if (isMiniBoss) {
      final idx = ((levelNumber ~/ 5) - 1) % _miniBossNames.length;
      name = 'MINI BOSS: ${_miniBossNames[idx]}';
    } else {
      final nameIndex = (levelNumber - 1) % _normalNames.length;
      name = _normalNames[nameIndex];
    }

    return BubbleLevel(
      levelNumber: levelNumber,
      name: name,
      columns: columns,
      maxRows: maxRows,
      bubbles: grid,
      shots: shots,
      availableColors: selectedColors,
      levelType: levelType,
      difficultyRating: difficulty,
    );
  }

  static void _ensureSolvableClusters(
    Map<GridPosition, BubbleColor> grid,
    int columns,
    List<BubbleColor> availableColors,
    math.Random random,
  ) {
    // Merge isolated singletons into neighbor color groups
    final keys = grid.keys.toList();
    for (final pos in keys) {
      final color = grid[pos];
      if (color == null) continue;

      final cluster = BubbleGridHelper.findConnectedSameColor(
        start: pos,
        grid: grid,
        baseColumns: columns,
        maxRows: 16,
        rowOffset: 0,
      );

      if (cluster.length < 2) {
        final neighbors = BubbleGridHelper.getNeighbors(
          pos: pos,
          baseColumns: columns,
          maxRows: 16,
          rowOffset: 0,
        ).where((n) => grid.containsKey(n) && n != pos).toList();

        if (neighbors.isNotEmpty) {
          final targetNeighbor = neighbors[random.nextInt(neighbors.length)];
          final neighborColor = grid[targetNeighbor];
          if (neighborColor != null) {
            grid[pos] = neighborColor;
          }
        }
      }
    }
  }

  static void _generateMaskedPattern(
    Map<GridPosition, BubbleColor> grid,
    int rowCount,
    int columns,
    List<BubbleColor> colors,
    math.Random random,
    PuzzleMaskType mask,
  ) {
    for (int r = 0; r < rowCount; r++) {
      final cols = BubbleGridHelper.getColsInRow(r, columns);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        final bool shouldPlace = _evaluateMaskPlacement(mask, r, c, rowCount, cols);
        if (!shouldPlace) continue;

        final color = _evaluateColorDistribution(mask, r, c, rowCount, cols, colors, random, grid);
        grid[pos] = color;
      }
    }
  }

  static bool _evaluateMaskPlacement(
    PuzzleMaskType mask,
    int r,
    int c,
    int totalRows,
    int totalCols,
  ) {
    if (r == 0) return true;

    final centerCol = totalCols / 2.0;
    final distFromCenter = (c - centerCol).abs();

    switch (mask) {
      case PuzzleMaskType.horizontalBands:
      case PuzzleMaskType.verticalStripes:
      case PuzzleMaskType.checkerboard:
      case PuzzleMaskType.rainbowArch:
        return true;

      case PuzzleMaskType.diamondCore:
        final progress = (r - (totalRows / 2)).abs();
        final maxColDist = (totalCols / 2) - progress * 0.9;
        return distFromCenter <= maxColDist;

      case PuzzleMaskType.vortexSpiral:
        if (r % 2 == 1 && (c == 0 || c == totalCols - 1)) return false;
        return true;

      case PuzzleMaskType.honeycombShield:
        if (r >= totalRows - 2) {
          return distFromCenter <= (totalCols / 3.0);
        }
        return true;

      case PuzzleMaskType.twinTowers:
        final inLeftTower = c <= (totalCols * 0.4);
        final inRightTower = c >= (totalCols * 0.6);
        if (r <= 2) return true;
        return inLeftTower || inRightTower;

      case PuzzleMaskType.pyramidInverted:
        final allowedDist = (totalCols / 2.0) - (r * 0.45);
        return distFromCenter <= allowedDist;

      case PuzzleMaskType.crownFortress:
        if (r == 1) {
          return c % 3 != 1;
        }
        return true;

      case PuzzleMaskType.hourGlass:
        final waistRow = totalRows ~/ 2;
        final rowDist = (r - waistRow).abs();
        final allowedWidth = 1.5 + rowDist * 1.0;
        return distFromCenter <= allowedWidth;

      case PuzzleMaskType.snakeRibbon:
        final wave = (math.sin(r * 0.8) * (totalCols * 0.35));
        final targetCenter = centerCol + wave;
        return (c - targetCenter).abs() <= 2.2;
    }
  }

  static BubbleColor _evaluateColorDistribution(
    PuzzleMaskType mask,
    int r,
    int c,
    int totalRows,
    int totalCols,
    List<BubbleColor> colors,
    math.Random random,
    Map<GridPosition, BubbleColor> grid,
  ) {
    switch (mask) {
      case PuzzleMaskType.horizontalBands:
        final bandIndex = (r ~/ 2) % colors.length;
        return colors[bandIndex];

      case PuzzleMaskType.verticalStripes:
        final stripeIndex = (c ~/ 2) % colors.length;
        return colors[stripeIndex];

      case PuzzleMaskType.checkerboard:
        final check = ((r ~/ 2) + (c ~/ 2)) % colors.length;
        return colors[check];

      case PuzzleMaskType.rainbowArch:
        final ring = (math.sqrt(r * r * 1.2 + math.pow(c - totalCols / 2, 2)) ~/ 1.5).toInt();
        return colors[ring % colors.length];

      case PuzzleMaskType.diamondCore:
        final dist = ((r - totalRows ~/ 2).abs() + (c - totalCols ~/ 2).abs()) ~/ 2;
        return colors[dist % colors.length];

      case PuzzleMaskType.vortexSpiral:
      case PuzzleMaskType.honeycombShield:
      case PuzzleMaskType.twinTowers:
      case PuzzleMaskType.pyramidInverted:
      case PuzzleMaskType.crownFortress:
      case PuzzleMaskType.hourGlass:
      case PuzzleMaskType.snakeRibbon:
        final neighbors = BubbleGridHelper.getNeighbors(pos: GridPosition(r, c), baseColumns: totalCols, maxRows: 16)
            .where((n) => grid.containsKey(n))
            .toList();
        if (neighbors.isNotEmpty && random.nextDouble() < 0.75) {
          final chosen = neighbors[random.nextInt(neighbors.length)];
          return grid[chosen]!;
        }
        return colors[random.nextInt(colors.length)];
    }
  }

  static void _generateMiniBossPattern(
    Map<GridPosition, BubbleColor> grid,
    int rowCount,
    int columns,
    List<BubbleColor> colors,
    math.Random random,
    int tier,
  ) {
    final core = colors[0];
    final shield = colors[1];
    final hazard = colors.length > 2 ? colors[2] : colors[0];
    final fill = colors.last;

    for (int r = 0; r < rowCount; r++) {
      final cols = BubbleGridHelper.getColsInRow(r, columns);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        if (r <= 1) {
          grid[pos] = (c % 2 == 0) ? shield : hazard;
        } else if (r >= 2 && r <= rowCount - 2) {
          final isCenter = (c - cols / 2).abs() <= 1.2;
          if (isCenter) {
            grid[pos] = core;
          } else if ((r + c) % 2 == 0) {
            grid[pos] = shield;
          } else {
            grid[pos] = fill;
          }
        } else {
          grid[pos] = (c % 3 == 0) ? hazard : fill;
        }
      }
    }
  }

  static void _generateGodBossPattern(
    Map<GridPosition, BubbleColor> grid,
    int rowCount,
    int columns,
    List<BubbleColor> colors,
    math.Random random,
    int tier,
  ) {
    final core = colors[0];
    final outerShield = colors[1];
    final innerShield = colors.length > 2 ? colors[2] : colors[0];
    final fortressHazard = colors.length > 3 ? colors[3] : colors.last;

    for (int r = 0; r < rowCount; r++) {
      final cols = BubbleGridHelper.getColsInRow(r, columns);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        if (r == 0 || r == 1) {
          grid[pos] = (c % 2 == 0) ? outerShield : innerShield;
        } else if (r >= 2 && r <= 5) {
          final centerDist = (c - cols / 2.0).abs();
          if (centerDist <= 1.0) {
            grid[pos] = core;
          } else if (centerDist <= 2.2) {
            grid[pos] = innerShield;
          } else {
            grid[pos] = outerShield;
          }
        } else if (r >= 6 && r <= 8) {
          if (c % 3 == 0) {
            grid[pos] = fortressHazard;
          } else if ((r + c) % 2 == 0) {
            grid[pos] = innerShield;
          } else {
            grid[pos] = outerShield;
          }
        } else {
          grid[pos] = colors[random.nextInt(colors.length)];
        }
      }
    }
  }

  static void _ensureConnectivity(Map<GridPosition, BubbleColor> grid, int columns) {
    final floating = BubbleGridHelper.findFloatingBubbles(
      grid: grid,
      baseColumns: columns,
      maxRows: 16,
      rowOffset: 0,
    );
    for (final pos in floating) {
      grid.remove(pos);
    }
  }
}

