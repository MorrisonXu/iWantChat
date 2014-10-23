//
//  ChatFaceKeyboardBottomView.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-15.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatFaceKeyboardBottomView.h"

const static CGFloat buttonWidth = 60.0;
const static CGFloat buttonHeight = 36.0;

@interface ChatFaceKeyboardBottomView ()

@end

@implementation ChatFaceKeyboardBottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    self.backgroundColor = [UIColor colorWithRed:255.0f/255 green:250.0f/255 blue:240.0f/255 alpha:1];
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor blueColor];
    self.sendButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0.0f, buttonWidth, buttonHeight);
    //[self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void) sendButtonClicked: (id) sender
{
    NSLog(@"subView: sendButtonClicked", nil);
}

@end
