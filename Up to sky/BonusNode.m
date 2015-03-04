//
//  BonusNode.m
//  Up to sky
//
//  Created by Михаил Лукьянов on 02.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "BonusNode.h"

float radius = 15;
const int bonus_count = 5;

@implementation BonusNode

-(instancetype)initBonusCanCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene
{
    //radius = scene.frame.size.width / 21.0;
    
    self = [BonusNode shapeNodeWithCircleOfRadius:radius];// [[self alloc] initWithRadius:30.0];
    
    self.fillColor = [UIColor blackColor];
    
    CGPoint position = CGPointMake(arc4random_uniform(scene.frame.size.width - radius*4) + radius*2, arc4random_uniform(scene.frame.size.height - radius*3) + radius*2);
    while (![self checkPosition:position])
    {
        position = CGPointMake(arc4random_uniform(scene.frame.size.width - radius*4) + radius*2, arc4random_uniform(scene.frame.size.height - radius*3) + radius*2);
    }
    
    self.position = position;
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    self.physicsBody.dynamic = NO;
    self.physicsBody.categoryBitMask = bonusHitCategory;
    self.physicsBody.collisionBitMask = ball.physicsBody.categoryBitMask;
    self.physicsBody.contactTestBitMask = ball.physicsBody.categoryBitMask;
    
    
    self.moves = 0;
    
    _label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    _label.fontColor = [UIColor whiteColor];
    _label.fontSize = 18;
    _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    [self addChild:_label];
    
    return self;
}
           
-(BOOL)checkPosition:(CGPoint)position
{
    for (BonusNode *bonus in [BonusNode prevBonuses]) {
        if ((powf(position.x - bonus.position.x, 2) + powf(position.y - bonus.position.y, 2)) < powf(radius * 2, 2))
            return NO;
    }
    return YES;
}

+(instancetype)bonusOfType:(NSInteger)type canCollideWtihBall:(SKShapeNode *)ball inScane:(SKScene *)scene
{
    BonusNode *bonus = [[self alloc] initBonusCanCollideWtihBall:ball inScane:scene];
    
    if (type == 1)
    {
        bonus.label.text = @"✖︎2";
    }
    if (type == 2)
    {
        bonus.label.text = @"⚡︎";
        bonus.action = [SKAction sequence:@[[SKAction runBlock:^{ball.physicsBody.restitution *= 5.0; ball.fillColor = [UIColor redColor];}],
                                            [SKAction waitForDuration:7 withRange:2],
                                            [SKAction runBlock:^{ball.physicsBody.restitution /= 5.0; ball.fillColor = [UIColor whiteColor];}]]];
        
        [bonus runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{bonus.fillColor = [UIColor redColor];}],
                                                                     [SKAction waitForDuration:0.25],
                                                                     [SKAction runBlock:^{bonus.fillColor = [UIColor blackColor];}],
                                                                     [SKAction waitForDuration:0.25]]]
                                          count:6]
              completion:^{
                  [bonus removeFromParent];
              }
         ];
    }
    
    bonus.type = type;
    
    return bonus;
}

+(instancetype)bonusOfRandomMovesInRange:(NSInteger)maxMoves CanCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene
{
    int moves = arc4random_uniform(maxMoves);

    BonusNode *bonus = [[self alloc] initBonusCanCollideWtihBall:ball inScane:scene];
    
    bonus.moves = moves + 1;
    bonus.label.text = [NSString stringWithFormat:@"%ld", bonus.moves];
    bonus.type = 0;
    
    return bonus;
}

+(NSMutableArray *)prevBonuses
{
    static NSMutableArray *prev = nil;
    if (prev == nil)
    {
        prev = [[NSMutableArray alloc] init];
    }
    
    return prev;
}



@end
