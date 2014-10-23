//
//  expressionKeyboardView.h
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-15.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import <UIKit/UIKit.h>

// 表情键盘上方的表情展示区

@protocol ChatFaceViewDelegate <NSObject>

@optional
- (void) didSelectFace:(NSString *) face andIsSelectDelete:(BOOL) del;

@end

@interface ChatFaceView : UIView

@property (weak, nonatomic) id<ChatFaceViewDelegate> delegate;

- (id)initWithFrame:(CGRect) frame forIndexPath:(NSInteger) index;

@end
