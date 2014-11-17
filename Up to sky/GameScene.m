//
//  GameScene.m
//  Up to sky
//
//  Created by Mikhail Lukyanov on 27.10.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

const int xg[4] = {0, -1, 0, 1};
const int yg[4] = {-1, 0, 1, 0};
int gi = 0;

static const int ballCategory = 1;
static const int wallCategory = 2;
//static const int bonusHitCategory = 4;

CGVector currentGravity;

BOOL circleLevel = false;

@implementation GameScene
{
    SKShapeNode *_ball;
    SKNode *_req;
    NSMutableArray *_walls;
    NSMutableArray *_bonuses;
    NSInteger _movesTake;
    SKLabelNode *_scoreLabel;
    NSInteger _score;
    NSInteger _scoreMult;
    SKShapeNode *_bar;
    NSMutableArray *_bars;
    NSMutableArray *_blackholes;
    SKSpriteNode *_backgroundNode;
    
    SKShapeNode *_circle;
    
    NSInteger _moves;
    SKLabelNode *_movesLabel;
    
    BOOL first_touch;
    
    NSMutableArray *_levels;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        gi = 0;
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

    //self.backgroundColor = [UIColor grayColor];
    
    //background
    _backgroundNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.size];
    _backgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _backgroundNode.zPosition = -1;
    [self addChild:_backgroundNode];
    
    [self addWalls];
    
    //Score label
    _scoreLabel = [[SKLabelNode alloc] init];
    _scoreLabel.text = @"0";
    _scoreLabel.fontColor = [UIColor whiteColor];
    _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _scoreLabel.fontSize = 20;
    _score = 0;
    _scoreMult = 1;
    
    [self addChild:_scoreLabel];
    
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.speed = 1;
    
    //Ball node
    _ball = [SKShapeNode shapeNodeWithCircleOfRadius:20];
    _ball.name = @"ball";
    _ball.fillColor = [UIColor whiteColor];
    _ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _ball.strokeColor = [UIColor blackColor];
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    _ball.physicsBody.dynamic = YES;
    _ball.physicsBody.allowsRotation = YES;
    _ball.physicsBody.mass = 0.05;
    
    _ball.physicsBody.categoryBitMask = ballCategory;
    _ball.physicsBody.collisionBitMask = wallCategory;
    _ball.physicsBody.contactTestBitMask = wallCategory;
    
        //ball moves counter
    _moves = 10;
    _movesTake = 0;
    
    _movesLabel = [[SKLabelNode alloc] init];
    _movesLabel.text = [NSString stringWithFormat:@"%ld", _moves];
    _movesLabel.fontColor = [UIColor blackColor];
    _movesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _movesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _movesLabel.fontSize = 20;
    _movesLabel.fontName = @"Helvetica-Bold";
    [_ball addChild:_movesLabel];
    
    [self addChild:_ball];
    
    //bar timer
    _bars       = [[NSMutableArray alloc] init];
    
    //blackholes
    _blackholes = [[NSMutableArray alloc] init];
    
    //Levels
    _levels     = [[NSMutableArray alloc] init];
    
    //First Touch (Start)
    first_touch = NO;
    SKLabelNode *startLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"START", nil)];
    startLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height/3);
    startLabel.name = @"start";
    [self addChild:startLabel];
    
    self.physicsWorld.speed = 0;
}

-(void)addWalls
{
    _walls = [[NSMutableArray alloc] init];
    SKShapeNode *wall;
    
    //Bottom
    wall = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(self.frame.size.width, 10)];
    wall.position = CGPointMake(CGRectGetMidX(self.frame), 5);
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.frame.size];
    wall.physicsBody.dynamic = NO;
    wall.fillColor = [UIColor blueColor];
    wall.name = @"Bottom";
    
    [_walls addObject:wall];

    //Left
    wall = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, self.frame.size.height)];
    wall.position = CGPointMake(5, CGRectGetMidY(self.frame));
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.frame.size];
    wall.physicsBody.dynamic = NO;
    wall.fillColor = [UIColor greenColor];
    wall.name = @"Left";
    [_walls addObject:wall];
    
    //Top
    wall = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(self.frame.size.width, 10)];
    wall.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 5);
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.frame.size];
    wall.physicsBody.dynamic = NO;
    wall.fillColor = [UIColor yellowColor];
    wall.name = @"Top";
    [_walls addObject:wall];
    
    //Right
    wall = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, self.frame.size.height)];
    wall.position = CGPointMake(self.frame.size.width - 5, CGRectGetMidY(self.frame));
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.frame.size];
    wall.physicsBody.dynamic = NO;
    wall.fillColor = [UIColor redColor];
    wall.name = @"Right";
    [_walls addObject:wall];
    
    for (SKShapeNode *wallNode in _walls) {
        wallNode.physicsBody.categoryBitMask = wallCategory;
        wallNode.physicsBody.collisionBitMask = ballCategory;
        wallNode.physicsBody.contactTestBitMask = ballCategory;
        wallNode.lineWidth = 0;
        wallNode.fillColor = [UIColor whiteColor];
    
        [self addChild:wallNode];
    }
    
}

-(void)startGame
{
    //Gravity changing repeat
    SKAction *wait = [SKAction waitForDuration:3];
    SKAction *performSelector = [SKAction performSelector:@selector(nextGravity) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];

    //Bobus
    _bonuses = [[NSMutableArray alloc] init];
    [self addBonus];
    [self addBonus];
    
    //Score timer
    //[self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(updateScore) onTarget:self],
    //                                                                  [SKAction waitForDuration:1]]]]];

    self.physicsWorld.speed = 1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (!first_touch)
    {
        first_touch = YES;
        [[self childNodeWithName:@"start"] removeFromParent];
        [self startGame];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    //NSLog(@"%lf %lf", touchLocation.x, touchLocation.y);
    CGPoint objLocation = _ball.position;
    
    CGVector direction = [self makeVectorFromPoint:objLocation toPoint:touchLocation];
    CGVector impulseNorm = [self normolizeVector:direction];
    CGVector impulse = [self scalarMultVector:impulseNorm byNumber:30];
    
    
    if (_moves > 0)
    {
        [[_ball physicsBody] applyImpulse:impulse];
        [self addMoves:-1];
        [self updateScore];
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    float dx = MIN(_ball.position.x, self.frame.size.width - _ball.position.x);
    float dy = MIN(_ball.position.y, self.frame.size.height - _ball.position.y);
    
    float ts;
    if (dx < dy)
    {
        ts = dx / self.frame.size.width / 2;
    }
    else
    {
        ts = dy / self.frame.size.height / 2;
    }
    self.physicsWorld.gravity = [self scalarMultVector:currentGravity byNumber:ts];
    
    if (circleLevel)
        [self checkCircle];
    
}

-(void)addBonus
{
    BonusNode *newBonus = [BonusNode bonusOfRandomTypeCanCollideWtihBall:_ball inScane:self];
    [_bonuses addObject:newBonus];
    
    newBonus.xScale = 0;
    newBonus.yScale = 0;
    [self addChild:newBonus];
    [newBonus runAction:[SKAction scaleTo:1 duration:0.3]];
}

-(void)removeBonus:(BonusNode *)bonus
{
    bonus.physicsBody.collisionBitMask = 0;
    bonus.physicsBody.categoryBitMask = 0;
    
    [_bonuses removeObjectIdenticalTo:bonus];
    SKAction *removeBonus = [SKAction sequence:@[[SKAction scaleTo:0 duration:.2], [SKAction removeFromParent]]];
    [bonus runAction:removeBonus];
}

-(void)bonusDidTake:(BonusNode *)bonus
{
    [self removeBonus:bonus];
    
    switch (bonus.type) {
        case 0:
        {
            [self movesDidTake];
            [self addMoves:bonus.moves];
            [self runAction:[SKAction waitForDuration:1] completion:^{
                [self addBonus];
            }];
            break;
        }
        case 1:
            [self incScoreMult];
        default:
            break;
    }
}

-(void)movesDidTake
{
    _movesTake++;
    NSInteger period = 10;
    if (_movesTake % period == 0)
    {
        [self stopLevel:(_movesTake / period - 2)];
        [self runLevel:(_movesTake / period - 1)];
        [self addChild:[BonusNode bonusOfType:5 canCollideWtihBall:_ball inScane:self]];
    }
}

-(void)updateScore
{
    _score++;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld (x%ld)", _score, _scoreMult];
    //_score+=_scoreMult;
}

-(void)nextGravity
{
    
    
    self.physicsWorld.gravity = CGVectorMake(xg[gi]*5, yg[gi]*5);
    currentGravity = self.physicsWorld.gravity;
    
    for (SKSpriteNode *wall in _walls) {
        wall.alpha = 0.3;
    }
    
    SKSpriteNode *wall = _walls[gi];
    wall.alpha = 1;
    
    if ([[wall.physicsBody allContactedBodies] indexOfObject:_ball.physicsBody] != NSNotFound)
        [self gameOver];
        
    
    gi = (gi+1) % 4;
}

#pragma mark Levels

-(void)addBar
{
    if (arc4random_uniform(2) == 0) // horizontal
    {
        _bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(arc4random_uniform(self.frame.size.width - 200) + 100, 10)];
        if (arc4random_uniform(2) == 0)
            _bar.position = CGPointMake(CGRectGetMidX(_bar.frame), arc4random_uniform(self.frame.size.height -200) + 100);
        else
            _bar.position = CGPointMake(self.size.width - CGRectGetMidX(_bar.frame) , arc4random_uniform(self.frame.size.height -200) + 100);
        //_bar.xScale = 0;
    }
    else // vertical
    {
        _bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, arc4random_uniform(self.frame.size.height - 200)+100)];
        if (arc4random_uniform(2) == 0)
            _bar.position = CGPointMake(arc4random_uniform(self.frame.size.width -200) + 100, CGRectGetMidY(_bar.frame));
        else
            _bar.position = CGPointMake(arc4random_uniform(self.frame.size.width -200) + 100, self.size.height - CGRectGetMidY(_bar.frame));
        //_bar.yScale = 0;
    }
    
    _bar.fillColor = [UIColor whiteColor];
    _bar.lineWidth = 0;
    _bar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bar.frame.size];
    _bar.physicsBody.dynamic = NO;
    
    _bar.xScale = 0;
    _bar.yScale = 0;
    [self addChild:_bar];
    [_bars addObject:_bar];
    
    [_bar runAction:[SKAction scaleTo:1 duration:0.2]];
}

-(void)popBar
{
    if (_bars.count ==0)
        return;
    
    SKShapeNode *popBar = _bars[0];
    [_bars removeObjectAtIndex:0];
    
    [popBar runAction:
     [SKAction sequence:@[
                          [SKAction scaleTo:0 duration:0.2],
                          [SKAction removeFromParent]]
      ]
     ];
}

-(void)addBlackholeWithStength:(float)strength
{
    CGPoint position = CGPointMake(self.frame.size.width / 4.0 + arc4random_uniform(self.frame.size.width / 2.0), self.frame.size.height / 4.0 + arc4random_uniform(self.frame.size.height / 2.0));
    
    SKFieldNode *gravityNode = [SKFieldNode radialGravityField];
    gravityNode.enabled = true;
    gravityNode.position = position;
    gravityNode.strength = strength;
    gravityNode.falloff = 0.0f;
    
    
    SKSpriteNode *gravityHole = [SKSpriteNode spriteNodeWithImageNamed:@"black_hole.png"];
    gravityHole.size = CGSizeMake(32, 32);
    gravityHole.position = position;
    
    [gravityHole runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:(strength > 0 ? -M_2_PI : M_2_PI*5.0) duration:1]] withKey:@"bhRotate"];
    
    [_blackholes addObject:@{@"gravity" : gravityNode, @"sprite" : gravityHole}];
    
    [self addChild:gravityHole];
    [self addChild:gravityNode];
}

-(void)popBlackhole
{
    if (_blackholes.count == 0)
        return;
    
    SKFieldNode *gravityNode = _blackholes[0][@"gravity"];
    SKSpriteNode *gravityHole = _blackholes[0][@"sprite"];
    
    [_blackholes removeObjectAtIndex:0];
    
    [gravityNode removeFromParent];
    [gravityHole runAction:[SKAction sequence:@[[SKAction scaleTo:0 duration:0.2], [SKAction removeFromParent]]]];
}

-(void)incScoreMult
{
    _scoreMult++;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld (x%ld)", _score, _scoreMult];
}

-(void)runLevel:(NSInteger)level
{
    if (level == 0)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction waitForDuration:2],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self]
                                                                           ]]]
                withKey:@"bar1act"];
        [self blinkBackgroundWithColor:[UIColor whiteColor] times:1];
    }
    if (level == 1)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction waitForDuration:2],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self],
                                                                           ]]]
                withKey:@"bar2act"];
        [self blinkBackgroundWithColor:[UIColor whiteColor] times:2];
    }
    if (level == 2)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction runBlock:^{[self addBlackholeWithStength:5];}],
                                                                           [SKAction waitForDuration:6],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self]
                                                                           ]]]
                withKey:@"bhAct1"];
        
        [self blinkBackgroundWithColor:[UIColor redColor] times:1];
    }
    if (level == 3)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction runBlock:^{[self addBlackholeWithStength:5];}],
                                                                           [SKAction runBlock:^{[self addBlackholeWithStength:5];}],
                                                                           [SKAction waitForDuration:2],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self]
                                                                           ]]]
                withKey:@"bhAct2"];
        
        [self blinkBackgroundWithColor:[UIColor redColor] times:2];
        
    }
    if (level == 4)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction runBlock:^{[self addBlackholeWithStength:-2];}],
                                                                           [SKAction waitForDuration:6],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self]
                                                                           ]]]
                withKey:@"bhReverseAct1"];
        [self blinkBackgroundWithColor:[UIColor blueColor] times:1];
    }
    if (level == 5)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction runBlock:^{[self addBlackholeWithStength:-2];}],
                                                                           [SKAction runBlock:^{[self addBlackholeWithStength:-2];}],
                                                                           [SKAction waitForDuration:3],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self]
                                                                           ]]]
                withKey:@"bhReverseAct2"];
        [self blinkBackgroundWithColor:[UIColor blueColor] times:2];
    }
    if (level == 6)
    {
        _circle = [SKShapeNode shapeNodeWithCircleOfRadius:self.frame.size.width / 3.0];
        _circle.fillColor = [UIColor clearColor];
        _circle.lineWidth = 5;
        _circle.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _circle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _circle.name = @"circle";
        
        [self addChild:_circle];
        circleLevel = YES;
    }
    if (level == 7)
    {
        [self runLevel:6];
    }
    
    if (level >= 8)
    {
        NSNumber *lvl1;
        NSNumber *lvl2;
        
        int level_type1 = arc4random_uniform(4);
        int level_type2 = arc4random_uniform(4);
        if (level_type1 == level_type2)
        {
            level_type2 = (level_type2 + 1) % 4;
        }
        
        lvl1 = [NSNumber numberWithInt:level_type1 + arc4random_uniform(2)];
        lvl2 = [NSNumber numberWithInt:level_type2 + arc4random_uniform(2)];
        
        [_levels addObjectsFromArray:@[lvl1, lvl2]];
        
        [self runLevel:lvl1.integerValue];
        [self runLevel:lvl2.integerValue];
    }
}

-(void)stopLevel:(NSInteger)level
{
    if (level == 0)
    {
        [self removeActionForKey:@"bar1act"];
        [self popBar];
    }
    if (level == 1)
    {
        [self removeActionForKey:@"bar2act"];
        [self popBar];
        [self popBar];
    }
    if (level == 2)
    {
        [self removeActionForKey:@"bhAct1"];
        [self popBlackhole];
    }
    if (level == 3)
    {
        [self removeActionForKey:@"bhAct2"];
        [self popBlackhole];
        [self popBlackhole];
    }
    if (level == 4)
    {
        [self removeActionForKey:@"bhReverseAct1"];
        [self popBlackhole];
    }
    if (level == 5)
    {
        [self removeActionForKey:@"bhReverseAct2"];
        [self popBlackhole];
        [self popBlackhole];
    }
    if (level == 6)
    {
        circleLevel = NO;
        [_circle removeFromParent];
        _backgroundNode.color = [UIColor blackColor];
    }
    if (level == 7)
    {
        [self stopLevel:6];
    }
    
    if (level >= 8)
    {
        while (_levels.count > 0) {
            NSNumber *lvl = [_levels lastObject];
            [self stopLevel:lvl.integerValue];
            [_levels removeLastObject];
        }
    }
}

-(void)blinkBackgroundWithColor:(UIColor *)color times:(NSInteger)times
{
    SKAction *blink = [SKAction sequence:@[[SKAction colorizeWithColor:color colorBlendFactor:1 duration:0.1], [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.2]]];
    [_backgroundNode runAction:[SKAction repeatAction:blink count:times]];
}

-(void)checkCircle
{
    if (pow(_ball.position.x - CGRectGetMidX(self.frame), 2) + pow(_ball.position.y - CGRectGetMidY(self.frame), 2) > powf(self.frame.size.width / 3.0, 2))
    {
        //[_backgroundNode runAction:[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0 duration:0.5]];
        _backgroundNode.color = [UIColor whiteColor];
        _circle.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        for (BonusNode *b in _bonuses) {
            b.alpha = 0;
        }
    }
    else
    {
        //[_backgroundNode runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0 duration:0.5]];
        _backgroundNode.color = [UIColor blackColor];
        _circle.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        
        for (BonusNode *b in _bonuses) {
            b.alpha = 1;
        }
    }
}

-(void)addMoves:(NSInteger)number
{
    _moves += number;
    _movesLabel.text = [NSString stringWithFormat:@"%ld", _moves];
    if (_moves == 0)
        return;
    _ball.physicsBody.mass = 0.05 * (float)_moves / 10;
}

-(void)gameOver
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view drawViewHierarchyInRect:self.frame afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.goDelegate showAd];
    //Game center
    [self.goDelegate reportScore:_score];
    
    GameOverScene *gameOver = [[GameOverScene alloc] initWithSize:self.size score:_score gameoverImg:viewImage];
    gameOver.goDelegate = self.goDelegate;
    [self.view presentScene:gameOver transition:[SKTransition fadeWithDuration:0.5]];
}

#pragma mark Collision delegate

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    if (firstBody.categoryBitMask == wallCategory || secondBody.categoryBitMask == wallCategory)
    {
        SKNode *wall;
        if (firstBody.categoryBitMask == wallCategory)
        {
            wall = firstBody.node;
        }
        else
        {
            wall = secondBody.node;
        }
        
        if (wall.alpha == 1.0)
        {
            [self gameOver];
            
            //_score = 0;
            //[self updateScore];
        }
        
        NSLog(@"Wall (%@) contact", wall.name);
    }
    
    if (firstBody.categoryBitMask == bonusHitCategory || secondBody.categoryBitMask == bonusHitCategory)
    {
        BonusNode *bonus;
        if (firstBody.categoryBitMask == bonusHitCategory)
        {
            bonus = (BonusNode *)firstBody.node;
        }
        else
        {
            bonus = (BonusNode *)secondBody.node;
        }
        
        NSLog(@"Bonus with type:(%ld) contact", bonus.type);
        //[self incScoreMult];
        //[self addMoves:bonus.moves];
        
        [self bonusDidTake:bonus];
    }
}

#pragma mark Vector Methods

-(CGVector)makeVectorFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    return CGVectorMake(p2.x - p1.x, p2.y - p1.y);
}

-(CGVector)normolizeVector:(CGVector)vector
{
    float l = sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
    return CGVectorMake(vector.dx / l, vector.dy / l);
}

-(CGVector)scalarMultVector:(CGVector)vector byNumber:(float)n
{
    return CGVectorMake(vector.dx * n, vector.dy * n);
}

@end
