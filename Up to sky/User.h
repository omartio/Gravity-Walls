//
//  User.h
//  Don't touch the wall
//
//  Created by Mikhail Lukyanov on 24.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface User : NSObject <ADBannerViewDelegate, GKGameCenterControllerDelegate>

+(instancetype)sharedUser;

- (void)hideAd;
- (void)showAd;
- (void)reportScore:(NSInteger)newScore;
- (void)showLeaderboard;


@property (nonatomic, strong)UIViewController *rootVC;

// A flag indicating whether the Game Center features can be used after a user has been authenticated.
@property (nonatomic) BOOL gameCenterEnabled;

// This property stores the default leaderboard's identifier.
@property (nonatomic, strong) NSString *leaderboardIdentifier;

@end
