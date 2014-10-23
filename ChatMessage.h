//
//  ChatMessage.h
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-8.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    messageFrom=0,
    messageTo
} ChatMessageType;

@interface ChatMessage : NSObject

@property (nonatomic) ChatMessageType messageType;
@property (nonatomic) NSString *portrait;
@property (nonatomic) NSString *content;

- (void) setChatMessageWithPortrait:(NSString *)portrait AndContent:(NSString *)content;

@end
