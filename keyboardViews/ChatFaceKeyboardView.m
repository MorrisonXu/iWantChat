//
//  ChatFaceKeyboardView.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-15.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatFaceKeyboardView.h"

#define FaceSectionBarHeight  36   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

#define Pages 3

@interface ChatFaceKeyboardView () <UIScrollViewDelegate, ChatFaceViewDelegate>

@property (strong, nonatomic) ChatFaceView *faceView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation ChatFaceKeyboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.backgroundColor = [UIColor colorWithRed:248.0f/255 green:248.0f/255 blue:255.0f/255 alpha:1.0];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-FacePageControlHeight-FaceSectionBarHeight)];
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame)*Pages,CGRectGetHeight(self.scrollView.frame))];
    
    for (int i= 0;i<Pages;i++) {
        self.faceView = [[ChatFaceView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.scrollView.bounds)) forIndexPath:i];
        [self.scrollView addSubview:self.faceView];
        self.faceView.delegate = self;
    }
    
    self.pageControl = [[UIPageControl alloc]init];
    [self.pageControl setFrame:CGRectMake(0,CGRectGetMaxY(self.scrollView.frame),CGRectGetWidth(self.bounds),FacePageControlHeight)];
    [self addSubview:self.pageControl];
    [self.pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    self.pageControl.numberOfPages = Pages;
    self.pageControl.currentPage   = 0;
    
    // 因为要控制整个键盘页面的下降所以要写在ChatDetailViewController.m中
    // 将按钮的delegate设置为ChatDetailViewController.m的self
    self.faceKeyboardBottomView = [[ChatFaceKeyboardBottomView alloc]
                                   initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.pageControl.frame), CGRectGetWidth(self.bounds), FaceSectionBarHeight)];
    [self addSubview:self.faceKeyboardBottomView];
}

#pragma mark - UIscrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll", nil);
    int page = scrollView.contentOffset.x/320;
    self.pageControl.currentPage = page;
}

#pragma mark - ChatFaceView Delegate
- (void) didSelectFace:(NSString *) face andIsSelectDelete:(BOOL) del
{
//    NSLog(@"ChatFaceKeyboarView: %@", face);
    if ([self.delegate respondsToSelector:@selector(SendTheFaceString:isDelete:) ]) {
        [self.delegate SendTheFaceString:face isDelete:del];
    }
}

@end
