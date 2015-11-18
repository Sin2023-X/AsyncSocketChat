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
#define HEAD 0
#define BODY 1
@interface ViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *myIPLabel;
@property (weak, nonatomic) IBOutlet UILabel *toIPLabel;
@property (weak, nonatomic) IBOutlet UITextField *hostT;
@property (weak, nonatomic) IBOutlet UITextField *portT;
@property (weak, nonatomic) IBOutlet UITextField *sendT;
@property (weak, nonatomic) IBOutlet UIButton *hostBtn;
@property (weak, nonatomic) IBOutlet UIButton *portBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
@property (strong,nonatomic)AsyncSocket *socket;
@property (nonatomic)BOOL isRunning;
@property (nonatomic)BOOL isServer;
@property (nonatomic,strong)NSMutableArray *socketArray;
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
- (Message *)unarchiverWithData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    Message *msg = [unarchiver decodeObjectForKey:@"msg"];
    [unarchiver finishDecoding];
    return msg;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isRunning = NO;
    self.isServer = NO;
}
//socket连接host、port
- (void)connectocket {
    NSError *error = nil;
    [self.socket connectToHost:self.hostT.text onPort:[self.portT.text integerValue] error:&error];
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
    self.myIPLabel.text = [NSString stringWithFormat:@"localIP:%@",sock.localHost];
    self.toIPLabel.text = [NSString stringWithFormat:@"connectedIP:%@",sock.connectedHost];
    if (!self.isServer) {
        self.hostBtn.selected = YES;
    }
    [sock readDataWithTimeout:-1 tag:0];
    
}
//

//读取数据，回调方法
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"read success");
    if (tag == HEAD) {
        NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSUInteger len = [msg integerValue];
        NSLog(@"msg = %@,len = %ld",msg,(long)len);
        [self logMessage:msg color:[UIColor redColor]];
        [sock readDataToLength:len withTimeout:-1 tag:BODY];
    }else if (tag == BODY) {
        NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"read msg = %@",msg);
        [self logMessage:msg color:[UIColor blackColor]];
        [sock readDataWithTimeout:-1 tag:HEAD];
    }
}
//将要断开连接
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"disconnect error = %@----%d",err,self.socket.isConnected);
}
//已经断开连接
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"已经断开！%ld",self.socket.userData);
    self.hostBtn.selected = NO;
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
//开启端口
- (IBAction)start:(UIButton *)sender {
    self.isServer = YES;
    if (!self.isRunning) {
        int port = [self.portT.text intValue];
        if (port < 0 || port > 65535) {
            port = 0;
        }
        NSError *error = nil;
        if (![self.socket acceptOnPort:port error:&error]) {
            NSLog(@"accept error = %@",error);
            return;
        }
        NSLog(@"socket = %@",self.socket);
        self.portBtn.selected = YES;
        self.hostBtn.userInteractionEnabled = NO;
        self.hostT.userInteractionEnabled = NO;
        self.portT.userInteractionEnabled = NO;
        self.isRunning = YES;
    }else {
        self.portBtn.selected = NO;
        self.hostBtn.userInteractionEnabled = YES;
        self.hostT.userInteractionEnabled = YES;
        self.portT.userInteractionEnabled = YES;
        [[self.socketArray firstObject] disconnect];
        [self.socket disconnect];
        self.isRunning = NO;
    }
}
//连接端口
- (IBAction)connect:(id)sender {
    if (self.hostBtn.selected == NO) {
        [self connectocket];
        self.hostBtn.selected = YES;
        NSLog(@"no");
    }else {
        NSLog(@"yes");
        [self.socket disconnect];
        self.hostBtn.selected = NO;
        self.socket.userData = 1;
    }
}
//发送消息
- (IBAction)send:(id)sender {
    if ([self.sendT.text isEqualToString:@""]) {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入内容" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [alt show];
    }else {
        NSString *message = [NSString stringWithFormat:@"%@",self.sendT.text];
        self.sendT.text = nil;
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger len = [data length];
        NSData *headData = [[NSString stringWithFormat:@"%ld",(unsigned long)len] dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"msg len = %ld",(unsigned long)message.length);
        [self logMessage:[NSString stringWithFormat:@"%ld",(unsigned long)len] color:[UIColor redColor]];
        [self logMessage:message color:[UIColor blueColor]];
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
        [self.msgTextView setContentOffset:CGPointMake(0.f,self.msgTextView.contentSize.height-self.msgTextView.frame.size.height)];
        [self.msgTextView scrollRangeToVisible:NSMakeRange(self.msgTextView.text.length, 1)];
    }
}

- (void)logMessage:(NSString *)msg color:(UIColor *)color{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n",msg];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:0];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];
    NSAttributedString *as = [[NSAttributedString alloc]initWithString:paragraph attributes:attributes];
    [[self.msgTextView textStorage]appendAttributedString:as];
    [self scrollToBottom];
}
@end
