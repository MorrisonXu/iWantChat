//
//  ChatMessageBubbleFactory.h
//  iWantChat
//
//  Created by 徐佳俊 on 14/10/23.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChatMessageType) {
    ChatMessageTypeReceive=0,
    ChatMessageTypeSend
};

@interface ChatMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageForType:(ChatMessageType)type;

@end
