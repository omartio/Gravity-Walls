//
//  GameViewController.h
//  Up to sky
//

//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>

@interface GameViewController : UIViewController <GameOverSceneDelegate, ADBannerViewDelegate, GKGameCenterControllerDelegate>

-(void)authenticateLocalPlayer;

@end
