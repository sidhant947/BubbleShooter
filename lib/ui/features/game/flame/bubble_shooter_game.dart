import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:bubbleshooter/domain/models/app_skin.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'package:bubbleshooter/domain/models/bubble_level.dart';
import 'package:bubbleshooter/domain/use_cases/bubble_grid_helper.dart';
import 'package:bubbleshooter/domain/use_cases/bubble_level_generator.dart';
import 'package:bubbleshooter/ui/core/widgets/balloon_renderer.dart';

class BubbleShooterSnapshot {
  const BubbleShooterSnapshot({
    required this.grid,
    required this.currentBubble,
    required this.nextBubble,
    required this.shotsRemaining,
    required this.foulCount,
    required this.ceilingRowOffset,
    this.zenMovesCount = 0,
    this.zenShiftParity = 0,
  });

  final Map<GridPosition, BubbleColor> grid;
  final BubbleColor currentBubble;
  final BubbleColor nextBubble;
  final int shotsRemaining;
  final int foulCount;
  final int ceilingRowOffset;
  final int zenMovesCount;
  final int zenShiftParity;
}

class PopEffect {
  PopEffect({
    required this.position,
    required this.color,
    this.progress = 0.0,
  });

  final Vector2 position;
  final BubbleColor color;
  double progress;
}

class FallingBalloon {
  FallingBalloon({
    required this.position,
    required this.velocity,
    required this.color,
  });

  Vector2 position;
  Vector2 velocity;
  final BubbleColor color;
}

class BubbleShooterFlameGame extends FlameGame with DragCallbacks, TapCallbacks {
  BubbleShooterFlameGame({
    required this.levelNumber,
    required this.skin,
    this.isZenMode = false,
    required this.onShotsChanged,
    required this.onLevelCleared,
    required this.onGameOver,
    required this.onHapticShoot,
    required this.onHapticPop,
    required this.onHapticBounce,
  });

  final int levelNumber;
  final bool isZenMode;
  AppSkin skin;
  final void Function(int shotsRemaining) onShotsChanged;
  final VoidCallback onLevelCleared;
  final void Function(String reason) onGameOver;
  final VoidCallback onHapticShoot;
  final VoidCallback onHapticPop;
  final VoidCallback onHapticBounce;

  late BubbleLevel level;
  final Map<GridPosition, BubbleColor> grid = {};
  late BubbleColor currentBubble;
  late BubbleColor nextBubble;

  int shotsRemaining = 35;
  int foulCount = 0;
  int zenMovesCount = 0;
  int zenShiftParity = 0;
  int ceilingRowOffset = 0;
  int get maxFoulsBeforeDrop {
    final cycle = (levelNumber - 1) % 5;
    return (5 - (cycle ~/ 2)).clamp(3, 6);
  }

  bool isGameOver = false;
  bool isGameWon = false;
  bool isShooting = false;
  bool isAiming = false;
  bool _isDragging = false;

  Vector2 aimDirection = Vector2(0, -1);
  Vector2? flyingPos;
  Vector2? flyingVel;
  BubbleColor? flyingColor;

  final List<PopEffect> popEffects = [];
  final List<FallingBalloon> fallingBalloons = [];
  final List<BubbleShooterSnapshot> undoStack = [];

  final math.Random random = math.Random();

  double get bubbleRadius => size.x / (BubbleGridHelper.defaultColumns * 2);
  double get rowHeight => BubbleGridHelper.getRowHeight(bubbleRadius);
  Vector2 get shooterPosition => Vector2(size.x / 2, size.y - bubbleRadius * 3.4);
  Vector2 get nextPreviewPosition => Vector2(size.x / 2 - bubbleRadius * 3.4, size.y - bubbleRadius * 2.3);
  Vector2 get shotsIndicatorPosition => Vector2(size.x / 2 + bubbleRadius * 3.4, size.y - bubbleRadius * 2.3);
  double get dangerLineY => bubbleRadius + 13 * rowHeight;

  Rect get cancelRect => Rect.fromCenter(
        center: Offset(shooterPosition.x, (dangerLineY + shooterPosition.y) / 2),
        width: bubbleRadius * 5.0,
        height: bubbleRadius * 2.2,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    startLevel(levelNumber);
  }

  void updateSkin(AppSkin newSkin) {
    skin = newSkin;
  }

  void startLevel(int lvlNum) {
    if (isZenMode) {
      level = BubbleLevelGenerator.generateZenLevel();
    } else {
      level = BubbleLevelGenerator.generateLevel(lvlNum);
    }
    grid.clear();
    grid.addAll(level.bubbles);
    shotsRemaining = isZenMode ? 999999 : level.shots;
    foulCount = 0;
    zenMovesCount = 0;
    zenShiftParity = 0;
    ceilingRowOffset = 0;
    isGameOver = false;
    isGameWon = false;
    isShooting = false;
    isAiming = false;
    flyingPos = null;
    flyingVel = null;
    flyingColor = null;
    popEffects.clear();
    fallingBalloons.clear();
    undoStack.clear();

    currentBubble = pickNextBubbleColor();
    nextBubble = pickNextBubbleColor();

    onShotsChanged(shotsRemaining);
  }

  BubbleColor pickNextBubbleColor() {
    final remainingColors = grid.values.toSet().toList();
    if (remainingColors.isNotEmpty) {
      return remainingColors[random.nextInt(remainingColors.length)];
    }
    if (level.availableColors.isNotEmpty) {
      return level.availableColors[random.nextInt(level.availableColors.length)];
    }
    return BubbleColor.red;
  }

  void swapBubbles() {
    if (isShooting || isGameOver || isGameWon) return;
    final temp = currentBubble;
    currentBubble = nextBubble;
    nextBubble = temp;
    onHapticBounce();
  }

  bool canUndo() => undoStack.isNotEmpty && !isShooting && !isGameOver && !isGameWon;

  void undo() {
    if (!canUndo()) return;
    final snapshot = undoStack.removeLast();
    grid.clear();
    grid.addAll(snapshot.grid);
    currentBubble = snapshot.currentBubble;
    nextBubble = snapshot.nextBubble;
    shotsRemaining = snapshot.shotsRemaining;
    foulCount = snapshot.foulCount;
    zenMovesCount = snapshot.zenMovesCount;
    zenShiftParity = snapshot.zenShiftParity;
    ceilingRowOffset = snapshot.ceilingRowOffset;
    isShooting = false;
    flyingPos = null;
    flyingVel = null;
    onShotsChanged(shotsRemaining);
    onHapticBounce();
  }

  void _recordSnapshot() {
    undoStack.add(BubbleShooterSnapshot(
      grid: Map.from(grid),
      currentBubble: currentBubble,
      nextBubble: nextBubble,
      shotsRemaining: shotsRemaining,
      foulCount: foulCount,
      ceilingRowOffset: ceilingRowOffset,
      zenMovesCount: zenMovesCount,
      zenShiftParity: zenShiftParity,
    ));
    if (undoStack.length > 20) {
      undoStack.removeAt(0);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    if (isShooting || isGameOver || isGameWon) return;
    _updateAim(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isShooting || isGameOver || isGameWon) return;
    _updateAim(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isShooting || isGameOver || isGameWon) return;
    if (isAiming) {
      _shoot();
    }
    isAiming = false;
    _isDragging = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    isAiming = false;
    _isDragging = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isShooting || isGameOver || isGameWon) return;
    final tapPos = event.localPosition;
    if ((tapPos - nextPreviewPosition).length <= bubbleRadius * 1.8) {
      swapBubbles();
      return;
    }
    if (cancelRect.contains(Offset(tapPos.x, tapPos.y))) {
      isAiming = false;
      return;
    }
    _updateAim(tapPos);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (_isDragging || isShooting || isGameOver || isGameWon) return;
    if (isAiming) {
      _shoot();
    }
    isAiming = false;
  }

  void _updateAim(Vector2 targetPos) {
    if (cancelRect.contains(Offset(targetPos.x, targetPos.y))) {
      isAiming = false;
      return;
    }

    final diff = targetPos - shooterPosition;
    if (diff.y >= -8) {
      isAiming = false;
      return;
    }
    var dir = diff.normalized();
    if (dir.y > -0.12) {
      final sign = dir.x == 0 ? 1.0 : dir.x.sign;
      dir = Vector2(sign * math.sqrt(1 - 0.12 * 0.12), -0.12);
    }
    aimDirection = dir;
    isAiming = true;
  }

  void _shoot() {
    _recordSnapshot();
    flyingPos = shooterPosition.clone();
    const speed = 1950.0;
    flyingVel = aimDirection * speed;
    flyingColor = currentBubble;
    isShooting = true;

    if (!isZenMode) {
      shotsRemaining--;
      onShotsChanged(shotsRemaining);
    }
    onHapticShoot();
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = popEffects.length - 1; i >= 0; i--) {
      popEffects[i].progress += dt * 3.5;
      if (popEffects[i].progress >= 1.0) {
        popEffects.removeAt(i);
      }
    }

    for (int i = fallingBalloons.length - 1; i >= 0; i--) {
      final b = fallingBalloons[i];
      b.velocity.y += 1100 * dt;
      b.position += b.velocity * dt;
      if (b.position.y > size.y + 100) {
        fallingBalloons.removeAt(i);
      }
    }

    if (isShooting && flyingPos != null && flyingVel != null) {
      _updateFlyingBubble(dt);
    }
  }

  void _updateFlyingBubble(double dt) {
    final pos = flyingPos!;
    final vel = flyingVel!;
    final r = bubbleRadius;

    pos.x += vel.x * dt;
    pos.y += vel.y * dt;

    if (pos.x - r <= 0) {
      pos.x = r;
      vel.x = -vel.x;
      onHapticBounce();
    } else if (pos.x + r >= size.x) {
      pos.x = size.x - r;
      vel.x = -vel.x;
      onHapticBounce();
    }

    final currentCeilingY = ceilingRowOffset * rowHeight + r;
    if (pos.y - r <= currentCeilingY) {
      pos.y = currentCeilingY;
      _landBubble(impactPoint: Offset(pos.x, pos.y), hitCell: null);
      return;
    }

    GridPosition? closestHit;
    double closestDist = double.infinity;

    for (final entry in grid.entries) {
      final center = BubbleGridHelper.getCellCenter(
        row: entry.key.row,
        col: entry.key.col,
        radius: r,
        rowOffset: ceilingRowOffset,
      );
      final dist = (Offset(pos.x, pos.y) - center).distance;
      if (dist <= r * 1.85 && dist < closestDist) {
        closestDist = dist;
        closestHit = entry.key;
      }
    }

    if (closestHit != null) {
      _landBubble(
        impactPoint: Offset(pos.x, pos.y),
        hitCell: closestHit,
        flyingVelocity: Offset(vel.x, vel.y),
      );
    }
  }

  void _landBubble({
    required Offset impactPoint,
    GridPosition? hitCell,
    Offset? flyingVelocity,
  }) {
    final landingPos = BubbleGridHelper.findClosestEmptyCell(
      impactPoint: impactPoint,
      grid: grid,
      radius: bubbleRadius,
      baseColumns: BubbleGridHelper.defaultColumns,
      maxRows: 16,
      rowOffset: ceilingRowOffset,
      hitCell: hitCell,
      flyingVelocity: flyingVelocity,
    );

    grid[landingPos] = flyingColor!;
    flyingPos = null;
    flyingVel = null;
    flyingColor = null;

    final matches = BubbleGridHelper.findConnectedSameColor(
      start: landingPos,
      grid: grid,
      baseColumns: BubbleGridHelper.defaultColumns,
      maxRows: 16,
      rowOffset: ceilingRowOffset,
    );

    if (matches.length >= 3) {
      for (final m in matches) {
        final center = BubbleGridHelper.getCellCenter(
          row: m.row,
          col: m.col,
          radius: bubbleRadius,
          rowOffset: ceilingRowOffset,
        );
        popEffects.add(PopEffect(
          position: Vector2(center.dx, center.dy),
          color: grid[m]!,
        ));
        grid.remove(m);
      }

      final floating = BubbleGridHelper.findFloatingBubbles(
        grid: grid,
        baseColumns: BubbleGridHelper.defaultColumns,
        maxRows: 16,
        rowOffset: ceilingRowOffset,
      );

      for (final f in floating) {
        final center = BubbleGridHelper.getCellCenter(
          row: f.row,
          col: f.col,
          radius: bubbleRadius,
          rowOffset: ceilingRowOffset,
        );
        final color = grid.remove(f)!;
        fallingBalloons.add(FallingBalloon(
          position: Vector2(center.dx, center.dy),
          velocity: Vector2(
            (random.nextDouble() - 0.5) * 300,
            -random.nextDouble() * 200,
          ),
          color: color,
        ));
      }

      onHapticPop();
    } else {
      if (!isZenMode) {
        foulCount++;
        if (foulCount >= maxFoulsBeforeDrop) {
          foulCount = 0;
          _shiftGridDown();
        }
      }
    }

    if (isZenMode) {
      zenMovesCount++;
      if (zenMovesCount >= 5) {
        zenMovesCount = 0;
        _pushNewZenRow();
      }
    }

    _checkDangerLineAndEndStates();

    currentBubble = nextBubble;
    nextBubble = pickNextBubbleColor();
    isShooting = false;
  }

  void _pushNewZenRow() {
    final entries = Map<GridPosition, BubbleColor>.from(grid);
    grid.clear();
    for (final entry in entries.entries) {
      grid[GridPosition(entry.key.row + 2, entry.key.col)] = entry.value;
    }

    final allColors = List<BubbleColor>.from(BubbleColor.values);
    for (int r = 1; r >= 0; r--) {
      final cols = BubbleGridHelper.getColsInRow(r, BubbleGridHelper.defaultColumns, 0);
      for (int c = 0; c < cols; c++) {
        final pos = GridPosition(r, c);
        final belowColor = grid[GridPosition(r + 1, c)];
        if (belowColor != null && random.nextDouble() < 0.6) {
          grid[pos] = belowColor;
        } else {
          grid[pos] = allColors[random.nextInt(allColors.length)];
        }
      }
    }

    onHapticBounce();
  }

  void _shiftGridDown() {
    ceilingRowOffset++;
    final entries = Map<GridPosition, BubbleColor>.from(grid);
    grid.clear();
    for (final entry in entries.entries) {
      grid[GridPosition(entry.key.row + 1, entry.key.col)] = entry.value;
    }

    onHapticBounce();
  }

  void _checkDangerLineAndEndStates() {
    bool reachedDanger = false;
    for (final pos in grid.keys) {
      if (pos.row >= 13 + ceilingRowOffset) {
        reachedDanger = true;
        break;
      }
    }

    if (reachedDanger) {
      isGameOver = true;
      onGameOver('Bubbles reached the danger line!');
    } else if (grid.isEmpty) {
      if (isZenMode) {
        final freshLevel = BubbleLevelGenerator.generateZenLevel();
        grid.addAll(freshLevel.bubbles);
      } else {
        isGameWon = true;
        onLevelCleared();
      }
    } else if (!isZenMode && shotsRemaining <= 0 && !isGameOver && !isGameWon) {
      isGameOver = true;
      onGameOver('Out of shots!');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.4),
        radius: 1.2,
        colors: skin.bgGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    final currentCeilingY = ceilingRowOffset * rowHeight + 1.5;
    final ceilingPaint = Paint()
      ..color = skin.primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, currentCeilingY), Offset(size.x, currentCeilingY), ceilingPaint);

    // 1. Danger Limit Line (Game Over threshold)
    final dangerPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    double dDashX = 0;
    while (dDashX < size.x) {
      canvas.drawLine(
        Offset(dDashX, dangerLineY),
        Offset(math.min(dDashX + 8, size.x), dangerLineY),
        dangerPaint,
      );
      dDashX += 16;
    }

    // 2. Aim Cancellation Zone (Rectangle visible only while aiming)
    if (isAiming && !isShooting && !isGameOver && !isGameWon) {
      final rRect = RRect.fromRectAndRadius(cancelRect, const Radius.circular(12));
      final cancelRectPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rRect, cancelRectPaint);

      final cancelBorderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(rRect, cancelBorderPaint);

      final cancelTextSpan = TextSpan(
        text: 'CANCEL SHOOT',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: bubbleRadius * 0.42,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );
      final cancelTextPainter = TextPainter(
        text: cancelTextSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      cancelTextPainter.layout();
      cancelTextPainter.paint(
        canvas,
        Offset(
          cancelRect.center.dx - cancelTextPainter.width / 2,
          cancelRect.center.dy - cancelTextPainter.height / 2,
        ),
      );
    }

    for (final entry in grid.entries) {
      final center = BubbleGridHelper.getCellCenter(
        row: entry.key.row,
        col: entry.key.col,
        radius: bubbleRadius,
        rowOffset: ceilingRowOffset,
      );
      BalloonRenderer.renderBalloon(
        canvas: canvas,
        center: center,
        radius: bubbleRadius * 0.94,
        color: entry.value,
      );
    }

    for (final b in fallingBalloons) {
      BalloonRenderer.renderBalloon(
        canvas: canvas,
        center: Offset(b.position.x, b.position.y),
        radius: bubbleRadius * 0.94,
        color: b.color,
      );
    }

    for (final pop in popEffects) {
      _renderPopEffect(canvas, pop);
    }

    if (isAiming && !isShooting && !isGameOver && !isGameWon) {
      _renderTrajectory(canvas);
    }

    if (flyingPos != null && flyingColor != null) {
      BalloonRenderer.renderBalloon(
        canvas: canvas,
        center: Offset(flyingPos!.x, flyingPos!.y),
        radius: bubbleRadius * 0.94,
        color: flyingColor!,
      );
    }

    _renderShooter(canvas);
  }

  void _renderPopEffect(Canvas canvas, PopEffect pop) {
    final ringRadius = bubbleRadius * (0.8 + pop.progress * 1.8);
    final alpha = (1.0 - pop.progress).clamp(0.0, 1.0);

    final ringPaint = Paint()
      ..color = pop.color.lightColor.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, 3.5 * (1.0 - pop.progress));
    canvas.drawCircle(Offset(pop.position.x, pop.position.y), ringRadius, ringPaint);

    final sparkCount = 8;
    final sparkPaint = Paint()
      ..color = pop.color.color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    for (int s = 0; s < sparkCount; s++) {
      final angle = s * (2 * math.pi / sparkCount) + pop.progress * 0.8;
      final dist = ringRadius * (1.0 + (s % 2 == 0 ? 0.2 : 0.05));
      final sx = pop.position.x + math.cos(angle) * dist;
      final sy = pop.position.y + math.sin(angle) * dist;
      canvas.drawCircle(Offset(sx, sy), math.max(0.5, 3.0 * (1.0 - pop.progress)), sparkPaint);
    }
  }

  void _renderTrajectory(Canvas canvas) {
    var p = shooterPosition.clone();
    var d = aimDirection.clone();
    final r = bubbleRadius;

    final dotPaint = Paint()
      ..color = currentBubble.lightColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final bouncePaint = Paint()
      ..color = currentBubble.lightColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const maxBounces = 2;
    int bounces = 0;
    Vector2? targetLanding;
    GridPosition? predictedCell;
    Vector2? lastDir;
    final currentCeilingY = ceilingRowOffset * rowHeight;

    while (bounces <= maxBounces && targetLanding == null) {
      double tMin = double.infinity;
      bool hitWall = false;
      GridPosition? hitGrid;

      if (d.x < -0.001) {
        final tLeft = (r - p.x) / d.x;
        if (tLeft > 0.001 && tLeft < tMin) {
          tMin = tLeft;
          hitWall = true;
        }
      } else if (d.x > 0.001) {
        final tRight = (size.x - r - p.x) / d.x;
        if (tRight > 0.001 && tRight < tMin) {
          tMin = tRight;
          hitWall = true;
        }
      }

      if (d.y < -0.001) {
        final tCeiling = (currentCeilingY + r - p.y) / d.y;
        if (tCeiling > 0.001 && tCeiling < tMin) {
          tMin = tCeiling;
          hitWall = false;
          hitGrid = null;
        }
      }

      for (final entry in grid.entries) {
        final center = BubbleGridHelper.getCellCenter(
          row: entry.key.row,
          col: entry.key.col,
          radius: r,
          rowOffset: ceilingRowOffset,
        );
        final c = Vector2(center.dx, center.dy);
        final v = c - p;
        final proj = v.dot(d);
        if (proj > 0.001) {
          final perp2 = v.length2 - proj * proj;
          final radiusSum = r * 1.84;
          if (perp2 <= radiusSum * radiusSum) {
            final tBubble = proj - math.sqrt(math.max(0.0, radiusSum * radiusSum - perp2));
            if (tBubble > 0.001 && tBubble < tMin) {
              tMin = tBubble;
              hitWall = false;
              hitGrid = entry.key;
            }
          }
        }
      }

      if (tMin.isInfinite) break;

      final stepDist = 16.0;
      int dotsCount = (tMin / stepDist).floor();
      for (int i = 1; i <= dotsCount; i++) {
        final dotPos = p + d * (i * stepDist);
        final dotRadius = (i % 2 == 0) ? 2.8 : 3.6;
        canvas.drawCircle(Offset(dotPos.x, dotPos.y), dotRadius, dotPaint);
      }

      final hitPoint = p + d * tMin;
      lastDir = d.clone();

      if (hitWall) {
        canvas.drawCircle(Offset(hitPoint.x, hitPoint.y), r * 0.45, bouncePaint);
        p = hitPoint;
        d = Vector2(-d.x, d.y);
        bounces++;
      } else {
        targetLanding = hitPoint;
        predictedCell = BubbleGridHelper.findClosestEmptyCell(
          impactPoint: Offset(hitPoint.x, hitPoint.y),
          grid: grid,
          radius: r,
          hitCell: hitGrid,
          flyingVelocity: Offset(lastDir.x, lastDir.y),
          maxRows: level.maxRows,
          rowOffset: ceilingRowOffset,
        );
        break;
      }
    }

    if (predictedCell != null) {
      final cellCenter = BubbleGridHelper.getCellCenter(
        row: predictedCell.row,
        col: predictedCell.col,
        radius: r,
        rowOffset: ceilingRowOffset,
      );

      final ghostPaint = Paint()
        ..color = currentBubble.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(cellCenter, r * 0.94, ghostPaint);

      final ghostRing = Paint()
        ..color = currentBubble.lightColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(cellCenter, r * 0.94, ghostRing);

      final targetCrossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(cellCenter.dx - r * 0.3, cellCenter.dy),
        Offset(cellCenter.dx + r * 0.3, cellCenter.dy),
        targetCrossPaint,
      );
      canvas.drawLine(
        Offset(cellCenter.dx, cellCenter.dy - r * 0.3),
        Offset(cellCenter.dx, cellCenter.dy + r * 0.3),
        targetCrossPaint,
      );
    }
  }

  void _renderShooter(Canvas canvas) {
    final sx = shooterPosition.x;
    final sy = shooterPosition.y;

    // 1. Pedestal base shadow & glow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(sx, sy + 3), bubbleRadius * 1.65, shadowPaint);

    // Pedestal platform
    final pedestalPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 0.9,
        colors: [
          skin.surfaceColor,
          skin.primaryColor.withValues(alpha: 0.4),
          const Color(0xFF0F1015),
        ],
      ).createShader(Rect.fromCircle(center: Offset(sx, sy), radius: bubbleRadius * 1.65));
    canvas.drawCircle(Offset(sx, sy), bubbleRadius * 1.65, pedestalPaint);

    final pedestalBorder = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(sx, sy), bubbleRadius * 1.65, pedestalBorder);

    // Inner glowing ring
    final innerRingPaint = Paint()
      ..color = skin.primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(sx, sy), bubbleRadius * 1.25, innerRingPaint);

    // 2. Rotating Launcher Guide Turret
    canvas.save();
    canvas.translate(sx, sy);
    final angle = math.atan2(aimDirection.y, aimDirection.x) + math.pi / 2;
    canvas.rotate(angle);

    // Launcher Rails
    final railPaint = Paint()
      ..color = skin.primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final railLeft = Path()
      ..moveTo(-bubbleRadius * 1.15, -bubbleRadius * 0.2)
      ..lineTo(-bubbleRadius * 0.75, -bubbleRadius * 1.45)
      ..lineTo(-bubbleRadius * 0.55, -bubbleRadius * 1.35)
      ..lineTo(-bubbleRadius * 0.95, -bubbleRadius * 0.1)
      ..close();
    canvas.drawPath(railLeft, railPaint);

    final railRight = Path()
      ..moveTo(bubbleRadius * 1.15, -bubbleRadius * 0.2)
      ..lineTo(bubbleRadius * 0.75, -bubbleRadius * 1.45)
      ..lineTo(bubbleRadius * 0.55, -bubbleRadius * 1.35)
      ..lineTo(bubbleRadius * 0.95, -bubbleRadius * 0.1)
      ..close();
    canvas.drawPath(railRight, railPaint);

    // Center Aim Arrow Tip
    final arrowTip = Path()
      ..moveTo(0, -bubbleRadius * 1.7)
      ..lineTo(-bubbleRadius * 0.35, -bubbleRadius * 1.15)
      ..lineTo(bubbleRadius * 0.35, -bubbleRadius * 1.15)
      ..close();
    final arrowPaint = Paint()
      ..color = currentBubble.lightColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowTip, arrowPaint);

    canvas.restore();

    // 3. Loaded Balloon Launch Chamber
    final launchGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          currentBubble.lightColor.withValues(alpha: 0.35),
          currentBubble.color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(sx, sy), radius: bubbleRadius * 1.3));
    canvas.drawCircle(Offset(sx, sy), bubbleRadius * 1.3, launchGlow);

    BalloonRenderer.renderBalloon(
      canvas: canvas,
      center: Offset(sx, sy),
      radius: bubbleRadius * 0.96,
      color: currentBubble,
    );

    // 4. "NEXT" Balloon Docking Chamber (Left of shooter)
    final nx = nextPreviewPosition.x;
    final ny = nextPreviewPosition.y;

    final nextDockShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(nx, ny + 2), bubbleRadius * 1.15, nextDockShadow);

    final nextBasePaint = Paint()
      ..color = skin.surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(nx, ny), bubbleRadius * 1.15, nextBasePaint);

    final nextBorderPaint = Paint()
      ..color = skin.primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(nx, ny), bubbleRadius * 1.15, nextBorderPaint);

    BalloonRenderer.renderBalloon(
      canvas: canvas,
      center: Offset(nx, ny),
      radius: bubbleRadius * 0.75,
      color: nextBubble,
    );

    // 5. Shots Available Circle (Right of shooter)
    final rx = shotsIndicatorPosition.x;
    final ry = shotsIndicatorPosition.y;

    final shotsDockShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(rx, ry + 2), bubbleRadius * 1.15, shotsDockShadow);

    final shotsBasePaint = Paint()
      ..color = skin.surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(rx, ry), bubbleRadius * 1.15, shotsBasePaint);

    final shotsBorderPaint = Paint()
      ..color = skin.primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(rx, ry), bubbleRadius * 1.15, shotsBorderPaint);

    final textSpan = TextSpan(
      text: isZenMode ? '∞' : '$shotsRemaining',
      style: TextStyle(
        color: skin.headingColor,
        fontSize: isZenMode ? bubbleRadius * 1.1 : bubbleRadius * 0.85,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rx - textPainter.width / 2, ry - textPainter.height / 2),
    );

    // 6. Foul Warning Indicator Dots (Misses before ceiling drop)
    final foulDotsCount = maxFoulsBeforeDrop;
    final dotRadius = bubbleRadius * 0.12;
    final dotSpacing = bubbleRadius * 0.35;
    final startDotX = sx - ((foulDotsCount - 1) * dotSpacing) / 2;
    final dotY = sy + bubbleRadius * 1.95;

    for (int i = 0; i < foulDotsCount; i++) {
      final dx = startDotX + i * dotSpacing;
      final isFilled = i < (maxFoulsBeforeDrop - foulCount);
      final foulDotPaint = Paint()
        ..color = isFilled
            ? skin.accentColor.withValues(alpha: 0.9)
            : Colors.redAccent.withValues(alpha: 0.4)
        ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(dx, dotY), dotRadius, foulDotPaint);
    }
  }
}
