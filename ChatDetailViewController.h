//
//  ChatDetailViewController.h
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-8.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatFaceKeyboardView.h"

@interface ChatDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *chatBottomToolbar;
@property (weak, nonatomic) IBOutlet UITableView *chatDetailTableView;

@end
