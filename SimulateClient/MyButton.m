//
//  MyButton.m
//  SimulateClient
//
//  Created by leiiwang on 15/12/30.
//  Copyright © 2015年 wangleo. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchBegin:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchEnd:self];
    
}


- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    [self.delegate touchEnd:self];
}


@end
