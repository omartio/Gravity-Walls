//
//  GameOverScene.m
//  Up to sky
//
//  Created by Mikhail Lukyanov on 03.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene
{
    SKSpriteNode *_retryButton;
}
-(instancetype)initWithSize:(CGSize)size score:(NSInteger)score
{
    if (self = [super initWithSize:size])
    {
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"SCORE", nil), score]];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0);
        
        [self addChild:scoreLabel];
        
        _retryButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(200, 50)];
        _retryButton.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 200);
        [self addChild:_retryButton];
        
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"RETRY", nil)];
        retryLabel.fontColor = [UIColor blackColor];
        retryLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 210);
        [self addChild:retryLabel];
        
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_retryButton containsPoint:location])
    {
        GameScene *newGameScene = [GameScene sceneWithSize:self.size];
        [self.view presentScene:newGameScene transition:[SKTransition fadeWithDuration:0.5]];
    }
}

@end
