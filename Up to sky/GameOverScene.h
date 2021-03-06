//
//  GameOverScene.h
//  Up to sky
//
//  Created by Mikhail Lukyanov on 03.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import "User.h"

@interface GameOverScene : SKScene

-(instancetype)initWithSize:(CGSize)size score:(NSInteger)score gameoverImg:(UIImage *)img;

@end
