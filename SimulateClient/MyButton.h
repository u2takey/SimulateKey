//
//  MyButton.h
//  SimulateClient
//
//  Created by leiiwang on 15/12/30.
//  Copyright © 2015年 wangleo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyButtonDelegate;
@interface MyButton : UIView
@property(nonatomic, assign) id<MyButtonDelegate> delegate;
@property(nonatomic, assign) IBOutlet UITextField *codeFiled;
@property(nonatomic, assign) NSTimer *timer;
@property(nonatomic, assign) int firecount;
@end

@protocol MyButtonDelegate <NSObject>

-(void)touchBegin:(MyButton*)btn;
-(void)touchEnd:(MyButton*)btn;

@end
