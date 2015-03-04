//
//  User.m
//  Don't touch the wall
//
//  Created by Mikhail Lukyanov on 24.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "User.h"

@implementation User
{
    BOOL _bannerIsVisible;
    BOOL _bannedLoaded;
    ADBannerView *_adBanner;
    GameScene *_curGameScene;
}

+(instancetype)sharedUser
{
    static User *user = nil;
    if (user == nil)
    {
        user = [[self alloc] initPrivate];
    }
    
    return user;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    //iAD
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, _rootVC.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
    
    //Game center
    _gameCenterEnabled = NO;
    _leaderboardIdentifier = @"";
    
    [self authenticateLocalPlayer];
    
    return self;
}


-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [_rootVC presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore:(NSInteger)newScore
{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
    score.value = newScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if ([ud integerForKey:@"best"] < newScore)
    {
        [ud setInteger:newScore forKey:@"best"];
        [ud synchronize];
    }
}

-(void)showLeaderboard
{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
    
    [_rootVC presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAd
{
    if (!_bannerIsVisible && _bannedLoaded)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [_rootVC.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        _adBanner.frame =  CGRectMake(0, _rootVC.view.frame.size.height - _adBanner.frame.size.height, _adBanner.frame.size.width, _adBanner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

-(void)hideAd
{
    if (_bannerIsVisible && _bannedLoaded)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        _adBanner.frame = CGRectMake(0, _rootVC.view.frame.size.height + _adBanner.frame.size.height, _adBanner.frame.size.width, _adBanner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    _bannedLoaded = YES;
    NSLog(@"AD loaded");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    _bannedLoaded = NO;
}


@end
