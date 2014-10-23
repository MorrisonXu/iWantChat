//
//  ChatFaceKeyboardView.h
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-15.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatFaceView.h"
#import "ChatFaceKeyboardBottomView.h"

// 整个键盘
@protocol ChatFaceKeyboardViewDelegate <NSObject>

- (void)SendTheFaceString:(NSString *)faceString isDelete:(BOOL)del;

@end

@interface ChatFaceKeyboardView : UIView

@property (weak, nonatomic) id<ChatFaceKeyboardViewDelegate> delegate;
@property (strong, nonatomic) ChatFaceKeyboardBottomView *faceKeyboardBottomView;


@end
