//
//  ChatMessageBubbleFactory.m
//  iWantChat
//
//  Created by 徐佳俊 on 14/10/23.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatMessageBubbleFactory.h"

@implementation ChatMessageBubbleFactory

+ (UIImage *)bubbleImageForType:(ChatMessageType)type
{
    NSString *messageImageName;
    messageImageName = @"chatBubble_";
    
    switch (type) {
        case ChatMessageTypeReceive:
            messageImageName = [messageImageName stringByAppendingString:@"Receiving_Solid"];
            break;
            
        case ChatMessageTypeSend:
            messageImageName = [messageImageName stringByAppendingString:@"Sending_Solid"];
            break;
            
        default:
            break;
    }
    
    UIImage *messageBubbleImage = [UIImage imageNamed:messageImageName];
    // 根据内容大小调整bubble形状
    UIEdgeInsets messageBubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle];
    [messageBubbleImage resizableImageWithCapInsets:messageBubbleImageEdgeInsets];
    return messageBubbleImage;
}

+ (UIEdgeInsets)bubbleImageEdgeInsetsWithStyle {
    UIEdgeInsets edgeInsets;
    
    edgeInsets = UIEdgeInsetsMake(30, 20, 10, 20);
    return edgeInsets;
}

@end
