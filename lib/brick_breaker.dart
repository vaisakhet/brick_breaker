library;

import 'dart:async';
import 'dart:math' as math;
import 'package:block_break/shared_prefrance.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
            camera: CameraComponent.withFixedResolution(
                width: gameWidth, height: gameHeight));

  final rand = math.Random();
  int score = 0;
  int highScore = 0;
  late TextComponent scoreText;
  late TextComponent highScoreText;
  late SpriteComponent playAgainButton;
  bool isGameOver = false;
  late SharedPrefResponse _prefns;

  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    if (isGameOver == false) {
      startGame();
    }
  }

  void startGame() {
    score = 0;
    updateScore();
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Paddle>());
    world.removeAll(world.children.query<Brick>());

    world.add(Ball(
      difficultyModifier: difficultyModifier,
      radius: ballRadius,
      position: size / 2,
      velocity:
          Vector2((rand.nextDouble() - 0.5) * width, height * 0.3).normalized()
            ..scale(height / 4),
    ));

    world.add(Paddle(
      size: Vector2(paddleWidth, paddleHeight),
      cornerRadius: const Radius.circular(ballRadius / 1),
      position: Vector2(width / 2, height * 0.95),
    ));

    world.addAll([
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            brickColors[i],
          ),
    ]);
  }

  void updateScore() {
    scoreText.text = 'Score: $score';
    if (score > highScore) {
      highScore = score;

      _prefns.setHighScore(highScore);

      highScoreText.text = 'High Score: ${_prefns.getHighScore}';
    }
  }

  void gameOver() {
    isGameOver = true;
    add(playAgainButton);
  }

  @override
  void onTap() {
    if (isGameOver) {
      startGame();
    } else {
      super.onTap();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.enter:
          startGame();
      }
    }
    return KeyEventResult.handled;
  }

  @override
  // Color backgroundColor() => const Color(0xfff2e8cf);
  Color backgroundColor() =>  Colors.black;
}

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
            radius: radius,
            anchor: Anchor.center,
            paint: Paint()
              ..color = const Color(0xff1e6091)
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final Vector2 velocity;
  final double difficultyModifier;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
          delay: 0.35,
          onComplete: () {
            game.startGame();
          },
        ));
      }
    } else if (other is Paddle) {
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}

class Paddle extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker>, KeyboardHandler {
  Paddle({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]);

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);

    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      position.x =
          (position.x - (dt * 500)).clamp(width / 2, game.width - width / 1);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      position.x =
          (position.x + (dt * 500)).clamp(width / 2, game.width - width / 1);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        cornerRadius,
      ),
      _paint,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isRemoved) return;
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x)
        .clamp(width / 2, game.width - width / 2);
  }
}

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick(Vector2 position, Color color)
      : super(
          position: position,
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    game.add(BrickBreakEffect(position, paint.color));

    removeFromParent();

    game.score += 10;
    game.updateScore(); 

    if (game.world.children.query<Brick>().length == 1) {
      game.startGame();
    }
  }
}

class BrickBreakEffect extends ParticleSystemComponent {
  BrickBreakEffect(Vector2 position, Color color)
      : super(
          position: position,
          particle: Particle.generate(
            count: 20,
            lifespan: 0.5,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(20, 100),
              speed: Vector2(
                (math.Random().nextDouble() - 0.5) * 200,
                (math.Random().nextDouble() - 0.5) * 200,
              ),
              lifespan: .05,
              position: Vector2(0, 0),
              child: CircleParticle(
                radius: 2.0,
                paint: Paint()
                  ..color = color
                  ..style = PaintingStyle.stroke,
              ),
            ),
          ),
        );
}

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea() : super(children: [RectangleHitbox()]);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);


    game.scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
            color: Colors.amber, fontSize: 30, fontWeight: FontWeight.w600),
      ),
      position: Vector2(game.width / 2, 10),
      anchor: Anchor.topCenter,
    );

    game.highScoreText = TextComponent(
      
      text: 'High Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
            color: Colors.red, fontSize: 30, fontWeight: FontWeight.w600),
      ),
      position: Vector2(game.width / 2, 40),
      anchor: Anchor.topCenter,
    );

    add(game.scoreText);
    add(game.highScoreText);
  }
}

const brickColors = [
  Color(0xfff94144),
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xfff9844a),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xff4d908e),
  Color(0xff277da1),
  Color(0xff577590),
  Color(0xff277da1),
  Color(0xff577590),
];

const gameWidth = 820.0;
const gameHeight = 1600.0;
const ballRadius = gameWidth * 0.02;
const paddleWidth = gameWidth * 0.2;
const paddleHeight = ballRadius * 2;
const paddleStep = gameWidth * 0.05;
const brickGutter = gameWidth * 0.015;
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
const brickHeight = gameHeight * 0.03;
const difficultyModifier = 1.05;
