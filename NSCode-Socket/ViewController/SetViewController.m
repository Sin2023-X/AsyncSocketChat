//
//  SetViewController.m
//  NSCode-Socket
//
//  Created by admin on 15/11/19.
//  Copyright © 2015年 zhengxinxin. All rights reserved.
//

#import "SetViewController.h"

@interface SetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameT;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)changeName:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![self.nameT.text isEqualToString:@""]) {
        [defaults setValue:self.nameT.text forKey:@"username"];
    }
    self.nameT.text = nil;
    UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:@"修改成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alt show];
    [self.nameT resignFirstResponder];
}

- (IBAction)backToLeftView:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
