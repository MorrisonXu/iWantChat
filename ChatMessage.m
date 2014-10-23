//
//  ChatMessage.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-8.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

- (void) setChatMessageWithPortrait:(NSString *)portrait AndContent:(NSString *)content
{
    self.portrait = portrait;
    self.content = content;
}

@end
