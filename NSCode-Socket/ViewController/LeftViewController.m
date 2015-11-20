//
//  LeftViewController.m
//  NSCode-Socket
//
//  Created by admin on 15/11/19.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "LeftViewController.h"
#import "SetViewController.h"
@interface LeftViewController ()
@property (weak, nonatomic) IBOutlet UIButton *setBtn;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)turnToSetView:(id)sender {
    SetViewController *setVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"set"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:setVC];
    [self presentViewController:nav animated:YES completion:nil];
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
