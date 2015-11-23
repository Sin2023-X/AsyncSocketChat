//
//  ViewController.m
//  communicateAsyncSocket
//
//  Created by admin on 15/11/17.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"
#import "Message.h"
#import "AppDelegate.h"
#import "NSDate+FromString.h"
#import "MyAttributedStringBuilder.h"
#import "LeftViewController.h"
#import "DaiDodgeKeyboard.h"
#import "SetViewController.h"
#define HEAD 0
#define BODY 1
@interface ViewController ()<AsyncSocketDelegate,UITextFieldDelegate>
@property (nonatomic)NSUInteger length;
@property (weak, nonatomic) IBOutlet UITextField *sendT;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
@property (strong,nonatomic)AsyncSocket *socket;
@property (nonatomic)BOOL isRunning;
@property (nonatomic)BOOL isServer;
@property (nonatomic,strong)NSMutableArray *socketArray;
@property (nonatomic)CGRect frame;
@end

@implementation ViewController
- (NSMutableArray *)socketArray {
    if (!_socketArray) {
        self.socketArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _socketArray;
}
- (AsyncSocket *)socket {
    if (!_socket) {
        self.socket = [[AsyncSocket alloc]initWithDelegate:self];
        if (self.isServer) {
            [_socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        }
    }
    return _socket;
}
//将要发送的数据封装
- (NSData *)archiveObject:(Message *)msg {
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archieve = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archieve encodeObject:msg forKey:@"msg"];
    [archieve finishEncoding];
    return data;
}
//将data还原成对象
- (Message *)unarchiverWithData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    Message *msg = [unarchiver decodeObjectForKey:@"msg"];
    [unarchiver finishDecoding];
    return msg;
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self.socket isConnected]) {
        [self  connectocket];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [DaiDodgeKeyboard removeRegisterTheViewNeedDodgeKeyboard];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.socket disconnect];
    self.socket.userData = 1;
}
- (void)viewDidAppear:(BOOL)animated {
    [DaiDodgeKeyboard addRegisterTheViewNeedDodgeKeyboard:self.view];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollToBottom) name:UIKeyboardDidShowNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.superview.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.frame = self.view.frame;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.msgTextView addGestureRecognizer:tap];
    self.isRunning = NO;
    self.isServer = NO;
    self.sendT.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(setAction)];
    self.navigationController.navigationBar.translucent = NO;
}
#pragma mark TextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 64, self.frame.size.width, self.frame.size.height-64);
}
//找到view上的键盘

//回首键盘轻拍手势
- (void)hiddenKeyboard:(UITapGestureRecognizer *)tap {
    [self.sendT resignFirstResponder];
    self.view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 64, self.frame.size.width, self.frame.size.height-64);
    [self scrollToBottom];
}
//设置显示侧边栏按钮
- (void)setAction {
    [self.sendT resignFirstResponder];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.YRC showLeftViewController:YES];
}
//socket连接host、port
- (void)connectocket {
    NSError *error = nil;
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject] stringByAppendingString:@"/user.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSUInteger port = [dic[@"port"] integerValue];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.socket connectToHost:delegate.strIP onPort:port error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    [self.socketArray addObject:newSocket];
}
//连接成功，回调方法
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"connect success!---%d",self.socket.isConnected);
    [sock readDataToLength:2 withTimeout:-1 tag:HEAD];

}
//
//读取数据，回调方法
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"read success");
    if (tag == HEAD) {
        NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSUInteger len = [msg integerValue];
        NSLog(@"get msg = %@,len = %ld",msg,(long)len);
        [sock readDataToLength:len withTimeout:-1 tag:BODY];
    }else if (tag == BODY) {
        NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"read msg = %@",msg);
        [self logMessage:msg color:[UIColor blackColor]];
        [sock readDataToLength:2 withTimeout:-1 tag:HEAD];
    }
}
//将要断开连接
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"disconnect error = %@----%d",err,self.socket.isConnected);
}
//已经断开连接
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"已经断开！%ld",self.socket.userData);
    if (self.socket.userData == 0) {
        if (!self.isServer) {
            [self connectocket];
        }
    }else if (self.socket.userData == 1) {
        if (self.isServer) {
            [self.socketArray removeObject:sock];
        }else {
            return;
        }
    }
}

//发送消息
- (IBAction)send:(id)sender {
    if ([self.sendT.text isEqualToString:@""]) {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入内容" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [alt show];
    }else {
        NSString *name = [self.socket localHost];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"]) {
            name = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        }
        NSString *message = [NSString stringWithFormat:@"%@\n%@:\n%@",[NSDate convertDateFromDate:[NSDate date]],name,self.sendT.text];
        self.sendT.text = nil;
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger len = [data length];
        NSData *headData = [[NSString stringWithFormat:@"%ld",(unsigned long)len] dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger headLen = headData.length;
        NSLog(@"headLen = %lu",(unsigned long)headLen);
        if (headLen > 2) {
            UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:@"输入内容过长，请分条发送" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
            [alt show];
            
            return;
        }
        if (self.isServer) {
            AsyncSocket *socket = [self.socketArray objectAtIndex:0];
            [socket writeData:headData withTimeout:-1 tag:HEAD];
            [socket writeData:data withTimeout:-1 tag:BODY];
        }else {
            [self.socket writeData:headData withTimeout:-1 tag:HEAD ];
            [self.socket writeData:data withTimeout:-1 tag:BODY];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 界面显示
- (void)scrollToBottom {
    if (self.msgTextView.contentSize.height > self.msgTextView.frame.size.height) {
        [self.msgTextView scrollRangeToVisible:NSMakeRange(self.msgTextView.text.length, 1)];
    }
}


- (void)logMessage:(NSString *)msg color:(UIColor *)color{
    NSString *message = [NSString stringWithFormat:@"%@\n",msg];
    MyAttributedStringBuilder *builder = [[MyAttributedStringBuilder alloc]initWithString:message];
    [builder includeString:message all:YES].textColor = color;
    [builder includeString:message all:YES].Font = [UIFont systemFontOfSize:20];
    //设置时间信息显示样式
    NSString *dateStr = [message substringToIndex:19];
    [builder includeString:dateStr all:YES].font = [UIFont systemFontOfSize:15];
    [builder includeString:dateStr all:YES].textColor = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [builder includeString:dateStr all:YES].paragraphStyle = paragraphStyle;
    //设置IP显示样式
    NSRange range1 = [message rangeOfString:@"\n"];
    message = [message substringFromIndex:range1.location+1];
    NSString *str = message;
    NSRange range = [message rangeOfString:@":"];
    message = [message substringToIndex:range.location];
    NSString *name = [self.socket localHost];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"]) {
        name = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    }
    if ([message isEqualToString:name]) {
        [builder includeString:message all:YES].textColor = [UIColor blueColor];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        [builder includeString:str all:YES].paragraphStyle = paragraphStyle;
    }else {
        [builder includeString:message all:YES].textColor = [UIColor redColor];
    }
    [builder includeString:message all:YES].Font = [UIFont systemFontOfSize:15];
    NSAttributedString *as = builder.commit;
    [[self.msgTextView textStorage]appendAttributedString:as];
    [self scrollToBottom];
}

@end
