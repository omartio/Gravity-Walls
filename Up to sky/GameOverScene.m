//
//  GameOverScene.m
//  Up to sky
//
//  Created by Mikhail Lukyanov on 03.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "VKontakteActivity.h"

@implementation GameOverScene
{
    SKSpriteNode *_retryButton;
    SKSpriteNode *_shareButton;
}
-(instancetype)initWithSize:(CGSize)size score:(NSInteger)score
{
    if (self = [super initWithSize:size])
    {
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"SCORE", nil), score]];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 200);
        
        [self addChild:scoreLabel];
        
        _retryButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(200, 50)];
        _retryButton.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 100);
        [self addChild:_retryButton];
        
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"RETRY", nil)];
        retryLabel.fontColor = [UIColor blackColor];
        retryLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        retryLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [_retryButton addChild:retryLabel];
        
        
        _shareButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(200, 50)];
        _shareButton.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 200);
        [self addChild:_shareButton];
        
        SKLabelNode *shareLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"SHARE", nil)];
        shareLabel.fontColor = [UIColor blackColor];
        shareLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        shareLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [_shareButton addChild:shareLabel];
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
    if ([_shareButton containsPoint:location])
    {
        [self share];
    }
}

-(void)share
{
    NSArray *items = @[[UIImage imageNamed:@"big.png"], @"Example" , [NSURL URLWithString:@"http://vk.com/omartio"]];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self.view.window.rootViewController];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[vkontakteActivity]];
    
    [self.view.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
