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
    SKSpriteNode *_leaderboardButton;
    NSInteger _score;
    UIImage *_gameOverImg;

}
-(instancetype)initWithSize:(CGSize)size score:(NSInteger)score gameoverImg:(UIImage *)img
{
    if (self = [super initWithSize:size])
    {
        _score = score;
        _gameOverImg = img;
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithText: NSLocalizedString(@"SCORE", nil)];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 100);
        [self addChild:scoreLabel];
        
        SKLabelNode *pointLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%ld", score]];
        pointLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 50);
        [self addChild:pointLabel];
        
        _retryButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(200, 50)];
        _retryButton.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 100);
        [self addChild:_retryButton];
        
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"RETRY", nil)];
        retryLabel.fontColor = [UIColor blackColor];
        retryLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        retryLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [_retryButton addChild:retryLabel];
        
        
        _shareButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(140, 50)];
        _shareButton.position = CGPointMake(size.width / 2.0 - 30, size.height / 2.0 - 200);
        [self addChild:_shareButton];
        
        SKLabelNode *shareLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(@"SHARE", nil)];
        shareLabel.fontColor = [UIColor blackColor];
        shareLabel.fontSize = 25;
        shareLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        shareLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [_shareButton addChild:shareLabel];
        
        _leaderboardButton = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(50, 50)];
        _leaderboardButton.position = CGPointMake(size.width / 2.0 + 75, size.height / 2.0 - 200);
        [self addChild:_leaderboardButton];
        
        SKSpriteNode *podiumNode = [SKSpriteNode spriteNodeWithImageNamed:@"podium.png"];
        podiumNode.size = CGSizeMake(40, 26);
        [_leaderboardButton addChild:podiumNode];
        
        SKLabelNode *bestLabel = [[SKLabelNode alloc] init];
        bestLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 260);
        bestLabel.fontSize = 20;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSInteger best = [ud integerForKey:@"best"];
        bestLabel.text = ((_score == best) ? @"NEW BEST" : [NSString stringWithFormat:@"Best: %ld", best]);
        [self addChild:bestLabel];
        
        
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
        newGameScene.goDelegate = self.goDelegate;
        [self.goDelegate hideAd];
        [self.view presentScene:newGameScene transition:[SKTransition fadeWithDuration:0.5]];
    }
    if ([_shareButton containsPoint:location])
    {
        [self share];
    }
    if ([_leaderboardButton containsPoint:location])
    {
        [self.goDelegate showLeaderboard];
    }
}

-(void)share
{
    NSArray *items = @[_gameOverImg, [NSString stringWithFormat:NSLocalizedString(@"SHAREDTEXT", nil), _score] , [NSURL URLWithString:@"https://itunes.apple.com/us/app/gravity-w4lls/id941154308"]];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self.view.window.rootViewController];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[vkontakteActivity]];
    activityViewController.popoverPresentationController.sourceView = self.view;
    activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.frame.size.width / 2.0 - 30, self.frame.size.height / 2.0 - 200, 50, 140);// _shareButton.frame;
    
    [self.view.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
