//
//  ChatDetailViewController.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-8.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatDetailViewController.h"

typedef NS_ENUM(NSInteger, KeyboardShowState) {
    KeyboardShowStateNone=0,
    KeyboardShowStateFace,
    KeyboardShowStateMore,
    KeyboardShowStateRegular,
    KeyboardShowStateRecord,
};

const static CGFloat toolbarHeight = 44;
const static CGFloat toolbarWidth = 320; // from storyboard
const static CGFloat faceKeyboardViewHeight = 196;

const static CGFloat minTextViewHeight = 36;
const static CGFloat maxTextViewHeight = 3 * minTextViewHeight;

@interface ChatDetailViewController () <UITextViewDelegate, /*UITextFieldDelegate,*/ ChatFaceKeyboardViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _keybaordState;
//    CGRect *keyboardBound;
    NSNumber *_duration;
    NSNumber *_curve;
    CGFloat _preMessageTextViewHeight;
}

// 通过 (UIButton *)recordButtonItem.customView; 获取Button
@property (strong, nonatomic) UIBarButtonItem *recordButtonItem;
@property (strong, nonatomic) UIBarButtonItem *keyboardButtonItem;
@property (strong, nonatomic) UIBarButtonItem *emojiButtonItem;
@property (strong, nonatomic) UIBarButtonItem *moreButtonItem;

@property (strong, nonatomic) UIBarButtonItem *speakButtonItem;
@property (strong, nonatomic) UIBarButtonItem *messageFieldButtonItem;
@property (strong, nonatomic) UIBarButtonItem *messageViewButtonItem;

@property (strong, nonatomic) ChatFaceKeyboardView *faceKeyboardView;

@end

@implementation ChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 用于处理出现/隐藏键盘时各个空间的重排
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 运行subview使用负坐标
    self.view.clipsToBounds = YES;
    
    [self configToolbarItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configure Toolbar Items
- (void) configToolbarItems
{
    // UIBarButtonItem要以strong作为property，否则setIamge就会有问题，不会起作用
    // Record BI
    UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [recordButton setImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"chatBar_recordSelected"] forState:UIControlStateHighlighted];
    [recordButton addTarget:self action:@selector(recordMsgBIClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.recordButtonItem = [[UIBarButtonItem alloc] initWithCustomView:recordButton];
    
    // Keyboard BI
    UIButton *keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [keyboardButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateNormal];
    [keyboardButton setImage:[UIImage imageNamed:@"chatBar_keyboardSelected"] forState:UIControlStateHighlighted];
    [keyboardButton addTarget:self action:@selector(keyboardMsgBIClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardButtonItem = [[UIBarButtonItem alloc] initWithCustomView:keyboardButton];
    
    // Emoji BI
    UIButton *emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [emojiButton setImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"chatBar_faceSelected"] forState:UIControlStateHighlighted];
    [emojiButton addTarget:self action:@selector(emojiMsgBIClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.emojiButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emojiButton];
    
    // More BI
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [moreButton setImage:[UIImage imageNamed:@"chatBar_more"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"chatBar_moreSelected"] forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(moreMsgBIClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    // Text View
//    CGFloat messageFieldWidth = toolbarWidth - 44 * 3;
//    UITextField *messageField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, messageFieldWidth, 44*0.8)];
//    [messageField setBorderStyle:UITextBorderStyleRoundedRect];
//    messageField.returnKeyType=UIReturnKeySend;
//    //messageField.font=[UIFont fontWithName:@"HelveticaNeue" size:18];
//    messageField.placeholder = @"请输入消息...";
//    messageField.delegate = self;
//    self.messageFieldButtonItem = [[UIBarButtonItem alloc] initWithCustomView:messageField];
    
    CGFloat messageViewWidth = toolbarWidth - 44 * 3;
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, messageViewWidth, minTextViewHeight)];
    messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    messageView.delegate = self;
    messageView.backgroundColor = [UIColor clearColor];
    messageView.font = [UIFont fontWithName:@"Helvetica" size:18];
    //messageView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    //messageView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    //messageView.textContainerInset = UIEdgeInsetsZero;
    messageView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    messageView.layer.borderWidth = 0.65f;
    messageView.layer.cornerRadius = 6.0f;
    
    _preMessageTextViewHeight = [self getTextViewContentHeight:messageView];
    self.messageViewButtonItem = [[UIBarButtonItem alloc] initWithCustomView:messageView];
    
    
    // Record Message BI
    //UIButton *speakButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, messageFieldWidth, 44*0.8)];
    UIButton *speakButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    speakButton.frame = CGRectMake(0, 0, messageViewWidth, 44*0.8);
    
    [speakButton.layer setMasksToBounds:YES];
    [speakButton.layer setBorderWidth:1.0];
    [speakButton.layer setCornerRadius:10.0];
//    [speakButton.layer setBorderColor:(CGColorRef)];
//    [speakButton setBackgroundColor:[UIColor lightGrayColor]];
    
    [speakButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [speakButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [speakButton setTitle:@"松开发送" forState:UIControlStateHighlighted];
    [speakButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [speakButton addTarget:self action:@selector(speakButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(speakButtonLongPressed:)];
    longPressed.minimumPressDuration = 1.0;
    [speakButton addGestureRecognizer:longPressed];
    
    self.speakButtonItem = [[UIBarButtonItem alloc] initWithCustomView:speakButton];
    
    // Face Keyboard
    self.faceKeyboardView = [[ChatFaceKeyboardView alloc]initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), faceKeyboardViewHeight)];
    self.faceKeyboardView.delegate = self;
    [self.faceKeyboardView.faceKeyboardBottomView.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.faceKeyboardView];
    
    // Remove the Margins between
    // iOS6 - 12px
    // iOS7 - margins are 16px on iPhone and 20px on iPad!
    // 因为用UIButton来initWithCustomView时会存在16px的margins
    UIBarButtonItem *marginRemover = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    marginRemover.width = -16;
    UIBarButtonItem *textFieldMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    // 图片大小30*30，Rect是44*44，(44-30)/2，-16+7=-9
    textFieldMargin.width = -9;
    
    // items中第一个按钮点击+移动才会改变背景图片，为什么？
    NSArray *toolbarItems = [NSArray arrayWithObjects:marginRemover, self.recordButtonItem, textFieldMargin, self.messageViewButtonItem, textFieldMargin, self.emojiButtonItem, marginRemover, self.moreButtonItem, marginRemover, nil];
    self.chatBottomToolbar.items = toolbarItems;
}

#pragma mark - Button Item Callback
- (void) recordMsgBIClicked: (id) sender
{
    NSLog(@"recordClicked", nil);
    
    [self multiKeyboardShowOrHide:KeyboardShowStateNone];
    
    NSMutableArray *toolbarItems = [self.chatBottomToolbar.items mutableCopy];
    
    // 实现键盘和语音按钮的切换
    [toolbarItems replaceObjectAtIndex:1 withObject:self.keyboardButtonItem];
    // 实现会话框的切换
    [toolbarItems replaceObjectAtIndex:3 withObject:self.speakButtonItem];
    
    self.chatBottomToolbar.items = toolbarItems;
}

- (void) keyboardMsgBIClicked: (id) sender
{
    NSLog(@"keyboardClicked", nil);
    
    NSMutableArray *toolbarItems = [self.chatBottomToolbar.items mutableCopy];
    
    // 实现键盘和语音按钮的切换
    [toolbarItems replaceObjectAtIndex:1 withObject:self.recordButtonItem];
    // 实现会话框的切换
//    [toolbarItems replaceObjectAtIndex:3 withObject:self.messageFieldButtonItem];
    [toolbarItems replaceObjectAtIndex:3 withObject:self.messageViewButtonItem];
    
    self.chatBottomToolbar.items = toolbarItems;
    
    // 获取TextField焦点以调出回键盘
//    UITextField *messageField = (UITextField *)self.messageFieldButtonItem.customView;
//    [messageField becomeFirstResponder];
    UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
    [messageView becomeFirstResponder];
}

- (void) emojiMsgBIClicked: (id) sender
{
    if(_keybaordState == KeyboardShowStateFace) {
        [self multiKeyboardShowOrHide:KeyboardShowStateNone];
        return;
    }
    // 不先收回普通键盘会导致布局的重叠，可能是应为动画重叠的原因
    NSTimeInterval delay = (_keybaordState == KeyboardShowStateRegular) ? [_duration doubleValue] : 0;
    
    // 隐藏键盘
//    UITextField *messageField = (UITextField *)self.messageFieldButtonItem.customView;
//    [messageField resignFirstResponder];
    UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
    [messageView resignFirstResponder];
    
    NSLog(@"emojiClicked", nil);
    
    // 切换到表情视图键盘
    _keybaordState = KeyboardShowStateFace;
    [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(showFaceKeyboard:) userInfo:nil repeats:NO];
    //[self multiKeyboardShowOrHide:KeyboardShowStateFace];
}

- (void) showFaceKeyboard:(id)sender
{
    NSLog(@"showFaceKeyboard", nil);
    [self multiKeyboardShowOrHide:KeyboardShowStateFace];
}

- (void) moreMsgBIClicked: (id) sender
{
    NSLog(@"moreClicked", nil);
}

- (void) speakButtonClicked: (id) sender
{
    NSLog(@"speakButtonClicked", nil);
}

- (void) speakButtonLongPressed: (UILongPressGestureRecognizer *) gestureRecognizer
{
    NSLog(@"speakButtonLongPressed", nil);
}

- (void) sendButtonClicked: (id) sender
{
    NSLog(@"view: sendButtonClicked", nil);
}

- (void) sendText:(NSString *)text
{
    
}

#pragma mark - Mulitiple Keyboard Manners - Show / Hide
- (void) multiKeyboardShowOrHide:(NSInteger)KeyboardShowState
{
    CGFloat regularWidth = self.view.frame.size.width;
    CGFloat regularHeight = self.view.frame.size.height;
    
    CGFloat keyboardViewFrameY = regularHeight;
    
    CGRect keyboardViewFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    CGRect toolbarViewFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    CGRect chatDetailTableViewFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    switch (KeyboardShowState) {
        case KeyboardShowStateFace:
            keyboardViewFrameY -= faceKeyboardViewHeight;
            
            keyboardViewFrame = CGRectMake(0.0f, keyboardViewFrameY, regularWidth, faceKeyboardViewHeight);
            toolbarViewFrame = CGRectMake(0.0f, keyboardViewFrameY - toolbarHeight, regularWidth, toolbarHeight);
            chatDetailTableViewFrame = CGRectMake(0.0f, -toolbarHeight - faceKeyboardViewHeight, regularWidth, self.chatDetailTableView.frame.size.height);
            break;
            
        case KeyboardShowStateMore:
            
            break;
            
        case KeyboardShowStateNone:
            keyboardViewFrame = CGRectMake(0.0f, keyboardViewFrameY, regularWidth, faceKeyboardViewHeight);
            toolbarViewFrame = CGRectMake(0.0f, keyboardViewFrameY - toolbarHeight, regularWidth, toolbarHeight);
            chatDetailTableViewFrame = CGRectMake(0.0f, 0.0f, regularWidth, self.chatDetailTableView.frame.size.height);
            break;
            
        case KeyboardShowStateRegular:
            
            break;
            
        default:
            break;
    }
    
    NSLog(@"Height: %f; Y: %f", regularHeight, self.view.frame.origin.y);
    NSLog(@"1: %f; %f; %f", chatDetailTableViewFrame.origin.y, toolbarViewFrame.origin.y, keyboardViewFrame.origin.y);
    [UIView animateWithDuration:0.4f
                     animations:^{
                         // self.view.frame = viewFrame;
                         // 因为viewDidLoad->configToolbarItems中已经将frame设置为self.view.frame.height
                         // 所以当self.view.frame.origin.y变为-faceKeyboardViewFrameY后
                         // 相当于self.faceKeyboardView.frame.origin.y减了faceKeyboardViewFrameY
                         // 上述做法的问题：因为所有事件在view中捕获，如果整个抬升会导致faceKeyboardView无法响应事件

                         // 聊天的TableView上升
                         self.chatDetailTableView.frame = chatDetailTableViewFrame;
                         // toolbar上升
                         self.chatBottomToolbar.frame = toolbarViewFrame;
                         // 键盘界面上升
                         self.faceKeyboardView.frame = keyboardViewFrame;
                         
                         NSLog(@"2: %f; %f; %f", self.chatDetailTableView.frame.origin.y, self.chatBottomToolbar.frame.origin.y, self.faceKeyboardView.frame.origin.y);
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"3: %f; %f; %f", self.chatDetailTableView.frame.origin.y, self.chatBottomToolbar.frame.origin.y, self.faceKeyboardView.frame.origin.y);
                     }];
    
    /*
//    CGFloat faceKeyboardViewFrameY = self.view.frame.size.height - faceKeyboardViewHeight;
//    
//    //CGRect viewFrame = CGRectMake(0.0f, -faceKeyboardViewHeight, self.view.frame.size.width, self.view.frame.size.height);
//    CGRect faceKeyboardViewFrame = CGRectMake(0.0f, faceKeyboardViewFrameY, CGRectGetWidth(self.view.frame), faceKeyboardViewHeight);
//    CGRect toolbarViewFrame = CGRectMake(0.0f, faceKeyboardViewFrameY - self.chatBottomToolbar.frame.size.height, self.chatBottomToolbar.frame.size.width, self.chatBottomToolbar.frame.size.height);
//    CGRect chatDetailTableViewFrame = CGRectMake(0.0f, -self.chatBottomToolbar.frame.size.height - faceKeyboardViewHeight, self.chatBottomToolbar.frame.size.width, self.chatDetailTableView.frame.size.height);
//    
//    [UIView animateWithDuration:0.4f
//                     animations:^{
//                         // self.view.frame = viewFrame;
//                         // 因为viewDidLoad->configToolbarItems中已经将frame设置为self.view.frame.height
//                         // 所以当self.view.frame.origin.y变为-faceKeyboardViewFrameY后
//                         // 相当于self.faceKeyboardView.frame.origin.y减了faceKeyboardViewFrameY
//                         // 上述做法的问题：因为所有事件在view中捕获，如果整个抬升会导致faceKeyboardView无法响应事件
//                         
//                         // 聊天的TableView上升
//                         self.chatDetailTableView.frame = chatDetailTableViewFrame;
//                         // toolbar上升
//                         self.chatBottomToolbar.frame = toolbarViewFrame;
//                         // 键盘界面上升
//                         self.faceKeyboardView.frame = faceKeyboardViewFrame;
//                     }
//                     completion:^(BOOL finished) {
//                     }];
     */
}

//#pragma mark - UITextFieldDelegate
//// 点击发送完成输入
//- (BOOL) textFieldShouldReturn:(UITextField *) textField
//{
////    UITextField *messageField = (UITextField *)self.messageFieldButtonItem.customView;
////    // 取消TextField的焦点以缩回键盘
////    [messageField resignFirstResponder];
//    UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
//    // 取消TextField的焦点以缩回键盘
//    [messageView resignFirstResponder];
//    
//    // 这里将message写到table view中
//    
//    return YES;
//}
//
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    return YES;
//}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        if([self respondsToSelector:@selector(sendText:)]) {
            [self sendText:textView.text];
            UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
            messageView.text = @"";
            [self changeTextViewToHeight:[self getTextViewContentHeight:messageView]];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self changeTextViewToHeight:[self getTextViewContentHeight:textView]];
}

- (void)changeTextViewToHeight:(CGFloat)height
{
    height = (height < minTextViewHeight) ? minTextViewHeight : height;
    height = (height > maxTextViewHeight) ? maxTextViewHeight : height;
    
    if (height == _preMessageTextViewHeight) {
        return;
    } else {
        // 因为textView和toolbar的高度并不一致，所以用增量比较好
        CGFloat heightToChange = height - _preMessageTextViewHeight;
        CGRect toolbarFrameRect = self.chatBottomToolbar.frame;
        toolbarFrameRect.origin.y -= heightToChange;
        toolbarFrameRect.size.height += heightToChange;
        self.chatBottomToolbar.frame = toolbarFrameRect;
        
//        UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
//        CGRect textViewFrameRect = messageView.frame;
//        textViewFrameRect.size.height += heightToChange;
//        messageView.frame = textViewFrameRect;
        
        CGRect tableViewFrameRect = self.chatDetailTableView.frame;
        tableViewFrameRect.origin.y -= heightToChange;
        self.chatDetailTableView.frame = tableViewFrameRect;
        //scroll table to the bottom
        
        _preMessageTextViewHeight = height;
    }
}

- (CGFloat)getTextViewContentHeight:(UITextView *)textView
{
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}

#pragma mark - Keyboard Will/Hide Show Callback
// 键盘弹出时，将整个页面上抬
- (void) keyboardWillShow: (NSNotification *) notification
{
    NSLog(@"keyboardWillShow", nil);
    _keybaordState = KeyboardShowStateRegular;
    [self multiKeyboardShowOrHide:KeyboardShowStateNone];
    
    // 获取键盘边界Rect
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue: &keyboardBounds];
    
    // 获取键盘弹出动画效果
    _duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    _curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 计算偏移量
    NSInteger offset = self.view.frame.size.height - keyboardBounds.origin.y;
    
    CGRect listFrame = CGRectMake(0, -offset, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"offset is %ld", (long)offset);
    
    // 处理移动事件，将各视图设置最终要达到的状态，并执行键盘弹出动画
    [UIView beginAnimations: @"moveUpViewWithKeyboard" context: NULL];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [_duration doubleValue]];
    [UIView setAnimationCurve:[_curve intValue]];
    [UIView setAnimationDelegate:self];
    
    self.view.frame = listFrame;
    [UIView commitAnimations];
}

// 键盘隐藏时，将整个页面下移
- (void) keyboardWillHide: (NSNotification *) notification
{
    _keybaordState = KeyboardShowStateNone;
    NSLog(@"keyboardWillHide", nil);
    
    // 获取键盘收回动画效果
    _duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    _curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 计算新位置Rect
    CGRect listFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    // 处理移动事件，将各视图设置最终要达到的状态，并执行键盘弹出动画
    [UIView beginAnimations: @"moveDownViewWithKeyboard" context: NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [_duration doubleValue]];
    [UIView setAnimationCurve: [_curve intValue]];
    [UIView setAnimationDelegate: self];
    
    self.view.frame = listFrame;
    [UIView commitAnimations];
}

#pragma mark - ChatFaceKeyboardViewDelegate
- (void)SendTheFaceString:(NSString *)faceString isDelete:(BOOL)del
{
//    NSLog(@"ChatDetailViewController: %@", faceString);
//    UITextField *messageField = (UITextField *)self.messageFieldButtonItem.customView;
//    messageField.text = [messageField.text stringByAppendingString:faceString];
    UITextView *messageView = (UITextView *)self.messageViewButtonItem.customView;
    messageView.text = [messageView.text stringByAppendingString:faceString];
    
    // TODO
//    [self inputTextViewDidChange:messageField];
}

#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"ChatDetailListCell";
//    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    if (cell==nil) {
//        cell=[[ChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.chatPortrait.image = [UIImage imageNamed:@"to.jpg"];
//    cell.chatName.text = @"派大星";
//    cell.chatPreview.text = @"Hello！";
//    return cell;
    return nil;
}



#pragma mark - FOR TEST
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"%f; %f; %f", self.chatDetailTableView.frame.origin.y, self.chatBottomToolbar.frame.origin.y, self.faceKeyboardView.frame.origin.y);
//    
//    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
//    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
//    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
//    int x = point.x;
//    int y = point.y;
//    NSLog(@"touch (x, y) is (%d, %d)", x, y);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
