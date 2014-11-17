//
//  GameScene.h
//  Up to sky
//

//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BonusNode.h"

@protocol GameOverSceneDelegate <NSObject>
- (void)hideAd;
- (void)showAd;
- (void)reportScore:(NSInteger)newScore;
- (void)showLeaderboard;
@end


@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, weak) id <GameOverSceneDelegate> goDelegate;

@end
