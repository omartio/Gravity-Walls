//
//  GameOverScene.h
//  Up to sky
//
//  Created by Mikhail Lukyanov on 03.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface GameOverScene : SKScene

@property (nonatomic, weak) id <GameOverSceneDelegate> goDelegate;
-(instancetype)initWithSize:(CGSize)size score:(NSInteger)score gameoverImg:(UIImage *)img;

@end
