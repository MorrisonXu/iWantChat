//
//  expressionKeyboardView.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-15.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatFaceView.h"

#define NumPerLine 7
#define Lines    3
#define FaceSize  24
/*
 ** 两边边缘间隔
 */
#define EdgeDistance 20
/*
 ** 上下边缘间隔
 */
#define EdgeInterVal 5

@implementation ChatFaceView

#pragma mark - Initializaion
- (id)initWithFrame:(CGRect) frame forIndexPath:(NSInteger) index
{
    self = [super initWithFrame:frame];
    if (self) {
        // 水平间隔
        CGFloat horizontalInterval = (CGRectGetWidth(self.bounds)-NumPerLine*FaceSize -2*EdgeDistance)/(NumPerLine-1);
        // 上下垂直间隔
        CGFloat verticalInterval = (CGRectGetHeight(self.bounds)-2*EdgeInterVal -Lines*FaceSize)/(Lines-1);
        
        NSLog(@"%f,%f",verticalInterval,CGRectGetHeight(self.bounds));
        
        for (int i = 0; i<Lines; i++)
        {
            for (int x = 0;x<NumPerLine;x++)
            {
                UIButton *expressionButton =[UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:expressionButton];
                [expressionButton setFrame:CGRectMake(x*FaceSize+EdgeDistance+x*horizontalInterval,
                                                      i*FaceSize +i*verticalInterval+EdgeInterVal,
                                                      FaceSize,
                                                      FaceSize)];
                
                if (i*7+x+1 ==21) {
                    [expressionButton setBackgroundImage:[UIImage imageNamed:@"DeleteEmoticonBtn_ios7@2x.png"]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 0;
                    
                }else{
                    NSString *imageStr = [NSString stringWithFormat:@"Expression_%ld@2x.png",index*20+i*7+x+1];
                    [expressionButton setBackgroundImage:[UIImage imageNamed:imageStr]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 20*index+i*7+x+1;
                }
                [expressionButton addTarget:self
                                     action:@selector(faceClick:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    return self;
}

#pragma mark - UI Actions
- (void)faceClick:(UIButton *)button
{
    NSString *faceName;
    BOOL isDelete;
    if (button.tag ==0){
        faceName = nil;
        isDelete = YES;
    }else{
        NSString *expressstring = [NSString stringWithFormat:@"Expression_%ld@2x.png", (long)button.tag];
        NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
        NSDictionary *plistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
        
        for (int j = 0; j<[[plistDic allKeys]count]-1; j++)
        {
            if ([[plistDic objectForKey:[[plistDic allKeys]objectAtIndex:j]]
                 isEqualToString:[NSString stringWithFormat:@"%@",expressstring]])
            {
                faceName = [[plistDic allKeys]objectAtIndex:j];
            }
        }
        isDelete = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFace:andIsSelectDelete:)]) {
        [self.delegate didSelectFace:faceName andIsSelectDelete:isDelete];
    }
    
    NSLog(@"faceClick: %@", faceName);
}

@end
