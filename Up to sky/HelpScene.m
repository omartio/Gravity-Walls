//
//  HelpScene.m
//  Don't touch the wall
//
//  Created by Mikhail Lukyanov on 23.11.14.
//  Copyright (c) 2014 Mikhail Lukyanov. All rights reserved.
//

#import "HelpScene.h"
#import "GameScene.h"

@implementation HelpScene
{
    SKSpriteNode *_dissmisButtnon;
}
-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        CGPoint textPosition = CGPointMake(size.width / 2.0, size.height / 3.0 * 2.0);
        for (int i = 0; i < 4; i++)
        {
            NSString *helpStr = [NSString stringWithFormat:@"HELP%d", i+1];
            SKLabelNode *helpLabel = [SKLabelNode labelNodeWithText:NSLocalizedString(helpStr, nil)];
            helpLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            helpLabel.position = textPosition;
            helpLabel.fontSize = 15;
            helpLabel.fontName = @"HelveticaNeue";
            textPosition.y -= 30;
            
            [self addChild:helpLabel];
            
        }
        
        _dissmisButtnon = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(150, 50)];
        _dissmisButtnon.position = CGPointMake(size.width / 2.0, size.height / 5.0);
        SKLabelNode *dissmisLabel = [SKLabelNode labelNodeWithText:@"OK"];
        dissmisLabel.fontColor = [UIColor blackColor];
        dissmisLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        dissmisLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [_dissmisButtnon addChild:dissmisLabel];
        [self addChild:_dissmisButtnon];
        
    }
    
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    if ([_dissmisButtnon containsPoint:location])
    {
        GameScene *newGameScene = [GameScene sceneWithSize:self.size];
        [self.view presentScene:newGameScene transition:[SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5]];
    }
}


@end
