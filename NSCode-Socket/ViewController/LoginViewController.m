//
//  LoginViewController.m
//  NSCode-Socket
//
//  Created by admin on 15/11/18.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "LoginViewController.h"
#import "AsyncSocket.h"
#import "ViewController.h"
#import "AppDelegate.h"
@interface LoginViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *IPT;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong,nonatomic)AsyncSocket *socket;
@end

@implementation LoginViewController
- (AsyncSocket *)socket {
    if (!_socket) {
        self.socket = [AsyncSocket shareAsyncSocket];
        _socket.delegate = self;
    }
    return _socket;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //将端口号写入plist文件
    NSString *plistPath = [self returnPlistPath];
    NSDictionary *dic = @{@"port":@"3000"};
    [dic writeToFile:plistPath atomically:YES];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.IPT resignFirstResponder];
}
//创建plist文件
- (NSString *)returnPlistPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *plistPath = [documentsPath stringByAppendingString:@"/user.plist"];
    return plistPath;
}
- (IBAction)loginAction:(id)sender {
    if (![self.socket isConnected]) {
        [self.socket disconnect];
    }
    //从plist文件中读取端口号
    NSString *plistPath = [self returnPlistPath];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSUInteger port = [dic[@"port"] integerValue];
    NSError *error = nil;
    [self.socket connectToHost:self.IPT.text onPort:port error:&error];
    if (error) {
        NSLog(@"login error = %@",error);
    }
    
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"connect success!");
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults]setValue:[self.socket localHost] forKey:@"username"];
    delegate.strIP = self.IPT.text;
    [self presentViewController:delegate.YRC animated:YES completion:nil];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"disconnect!");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
