//
//  BonusNode.h
//  Up to sky
//
//  Created by Михаил Лукьянов on 02.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const int bonusHitCategory = 4;

@interface BonusNode : SKShapeNode

@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger moves;
@property (nonatomic, strong) SKAction *action;

+(instancetype)bonusOfType:(NSInteger)type canCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene;
+(instancetype)bonusOfRandomTypeCanCollideWtihBall:(SKNode *)ball inScane:(SKScene *)scene;


@end
