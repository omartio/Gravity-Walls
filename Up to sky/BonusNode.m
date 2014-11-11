//
//  BonusNode.m
//  Up to sky
//
//  Created by Михаил Лукьянов on 02.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "BonusNode.h"

const float radius = 15;
const int bonus_count = 5;

@implementation BonusNode

+(instancetype)bonusOfType:(NSInteger)type canCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene
{
    BonusNode *bonus = [self shapeNodeWithCircleOfRadius:radius];// [[self alloc] initWithRadius:30.0];
    
    bonus.fillColor = [UIColor blackColor];
    bonus.position = CGPointMake(arc4random_uniform(scene.frame.size.width - radius*4) + radius*2, arc4random_uniform(scene.frame.size.height - radius*3) + radius*2);
    
    bonus.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    bonus.physicsBody.dynamic = NO;
    bonus.physicsBody.categoryBitMask = bonusHitCategory;
    bonus.physicsBody.collisionBitMask = ball.physicsBody.categoryBitMask;
    bonus.physicsBody.contactTestBitMask = ball.physicsBody.categoryBitMask;
    
    
    bonus.moves = 0;
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    label.fontColor = [UIColor whiteColor];
    label.fontSize = 18;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    if (type < 5)
    {
        bonus.moves = type +1;
        
        label.text = [NSString stringWithFormat:@"%ld", bonus.moves];
        
        bonus.type = 0;
    }
    if (type == 5)
    {
        label.text = @"✖︎2";
        bonus.type = 1;
    }
    
    [bonus addChild:label];
    
    /*
    SKSpriteNode *img;
    NSString *img_name;
    
    switch (type) {
        case 0:{
            img_name = @"weight.png";
            bonus.action = [SKAction runBlock:^{
                ball.physicsBody.mass *=1.1;
            }];
            break;
        }
        case 1:{
            img_name = @"feather.png";
            bonus.action = [SKAction runBlock:^{
                ball.physicsBody.mass /=1.1;
            }];
            break;
        }
        case 2:
            img_name = @"big.png";
            bonus.action = [SKAction scaleBy:1.1 duration:0.3];
            break;
        case 3:
            img_name = @"small.png";
            bonus.action = [SKAction scaleBy:1/1.1 duration:0.3];
            break;
        default:
            break;
    }
    
    img = [SKSpriteNode spriteNodeWithImageNamed:img_name];
    img.size = CGSizeMake(radius , radius );
     */
    //[bonus addChild:img];
    
    return bonus;
}

+(instancetype)bonusOfRandomTypeCanCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene
{
    int type = arc4random_uniform(bonus_count);
    NSLog(@"%d", type);
    return [self bonusOfType:type canCollideWtihBall:ball inScane:scene];
}

@end
