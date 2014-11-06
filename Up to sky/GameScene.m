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


@implementation GameScene
{
    SKNode *_ball;
    SKNode *_req;
    NSMutableArray *_walls;
    SKLabelNode *_scoreLabel;
    NSInteger _score;
    NSInteger _scoreMult;
    SKShapeNode *_bar;
    NSMutableArray *_bars;
    NSMutableArray *_blackholes;
    SKSpriteNode *_backgroundNode;
    
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
    
    _scoreLabel = [[SKLabelNode alloc] init];
    _scoreLabel.text = @"0";
    _scoreLabel.fontColor = [UIColor whiteColor];
    _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _score = 0;
    _scoreMult = 1;
    
    [self addChild:_scoreLabel];
    
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.speed = 1;
    
    _ball = [SKShapeNode shapeNodeWithCircleOfRadius:20];
    ((SKShapeNode *)_ball).fillColor = [UIColor whiteColor];
    _ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    _ball.physicsBody.dynamic = YES;
    _ball.physicsBody.allowsRotation = YES;
    _ball.physicsBody.mass = 0.05;
    
    _ball.physicsBody.categoryBitMask = ballCategory;
    _ball.physicsBody.collisionBitMask = wallCategory;
    _ball.physicsBody.contactTestBitMask = wallCategory;
    
    [self addChild:_ball];
    
    [self addChild:[BonusNode bonusOfRandomTypeCanCollideWtihBall:_ball inScane:self]];
    [self addChild:[BonusNode bonusOfRandomTypeCanCollideWtihBall:_ball inScane:self]];
    
    //Gravity changing repeat
    SKAction *wait = [SKAction waitForDuration:3];
    SKAction *performSelector = [SKAction performSelector:@selector(nextGravity) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
    
    //Score timer
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(updateScore) onTarget:self],
                                                                       [SKAction waitForDuration:1]]]]];
    
    //bar timer
    _bars = [[NSMutableArray alloc] init];
    
    //blackholes
    _blackholes = [[NSMutableArray alloc] init];
    
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
        wallNode.lineWidth = 1;
        wallNode.fillColor = [UIColor whiteColor];
    
        [self addChild:wallNode];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    //NSLog(@"%lf %lf", touchLocation.x, touchLocation.y);
    CGPoint objLocation = _ball.position;
    
    CGVector direction = [self makeVectorFromPoint:objLocation toPoint:touchLocation];
    CGVector impulseNorm = [self normolizeVector:direction];
    CGVector impulse = [self scalarMultVector:impulseNorm byNumber:30];
    
    [[_ball physicsBody] applyImpulse:impulse];
    
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
    
    //SKShapeNode *wall = _walls[(gi+3) % 4];
    
}

-(void)updateScore
{
    _scoreLabel.text = [NSString stringWithFormat:@"%ld (x%ld)", _score, _scoreMult];
    _score+=_scoreMult;
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

-(void)addBlackhole
{
    CGPoint position = CGPointMake(self.frame.size.width / 4.0 + arc4random_uniform(self.frame.size.width / 2.0), self.frame.size.height / 4.0 + arc4random_uniform(self.frame.size.height / 2.0));
    
    SKFieldNode *gravityNode = [SKFieldNode radialGravityField];
    gravityNode.enabled = true;
    gravityNode.position = position;
    gravityNode.strength = 5.0f;
    gravityNode.falloff = 0.0f;
    
    
    SKSpriteNode *gravityHole = [SKSpriteNode spriteNodeWithImageNamed:@"black_hole.png"];
    gravityHole.size = CGSizeMake(32, 32);
    gravityHole.position = position;
    
    [gravityHole runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:-M_2_PI duration:1]] withKey:@"bhRotate"];
    
    [_blackholes addObject:@{@"gravity" : gravityNode, @"sprite" : gravityHole}];
    
    [self addChild:gravityHole];
    [self addChild:gravityNode];
}

-(void)popBlackhole
{
    if (_blackholes == 0)
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
    
    if (_scoreMult == 5)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction waitForDuration:2],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self]
                                                                           ]]] withKey:@"bar1act"];
        [self blinkBackgroundWithColor:[UIColor whiteColor] times:1];
    }
    if (_scoreMult == 8)
    {
        [self removeActionForKey:@"bar1act"];
        [self popBar];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction waitForDuration:1],
                                                                           [SKAction performSelector:@selector(addBar) onTarget:self],
                                                                           [SKAction waitForDuration:1],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self],
                                                                           [SKAction waitForDuration:1],
                                                                           [SKAction performSelector:@selector(popBar) onTarget:self],
                                                                           ]]]
                withKey:@"bar2act"];
        [self blinkBackgroundWithColor:[UIColor whiteColor] times:2];
    }
    if (_scoreMult == 12)
    {
        [self removeActionForKey:@"bar2act"];
        [self popBar];
        [self popBar];
        
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(addBlackhole) onTarget:self],
                                                                           [SKAction waitForDuration:3],
                                                                           [SKAction performSelector:@selector(popBlackhole) onTarget:self]
                                                                           ]]] withKey:@"bhAct1"];
        
        [self blinkBackgroundWithColor:[UIColor whiteColor] times:3];
    }
}

-(void)blinkBackgroundWithColor:(UIColor *)color times:(NSInteger)times
{
    SKAction *blink = [SKAction sequence:@[[SKAction colorizeWithColor:color colorBlendFactor:1 duration:0.1], [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.2]]];
    [_backgroundNode runAction:[SKAction repeatAction:blink count:times]];
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
            GameOverScene *gameOver = [[GameOverScene alloc] initWithSize:self.size score:_score];
            [self.view presentScene:gameOver transition:[SKTransition fadeWithDuration:0.5]];
            
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
        [self incScoreMult];
        [_ball runAction:bonus.action];
        
        SKAction *removeBonus = [SKAction sequence:@[[SKAction scaleTo:0 duration:.2], [SKAction waitForDuration:0.5], [SKAction removeFromParent]]];
        [bonus runAction:removeBonus completion:^{
            BonusNode *newBonus = [BonusNode bonusOfRandomTypeCanCollideWtihBall:_ball inScane:self];
            newBonus.xScale = 0;
            newBonus.yScale = 0;
            [self addChild:newBonus];
            [newBonus runAction:[SKAction scaleTo:1 duration:0.3]];
            
        }];
        
        
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
