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
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}
- (void)viewWillAppear:(BOOL)animated {
    self.nameT.userInteractionEnabled = NO;
    self.changeBtn.selected = NO;
    self.nameT.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    NSLog(@"username = %@",self.nameT.text);
    
}
- (IBAction)changeName:(id)sender {
    if (self.changeBtn.selected == NO) {
        self.changeBtn.selected = YES;
        self.nameT.userInteractionEnabled = YES;
        [self.nameT becomeFirstResponder];
        self.nameT.clearButtonMode = UITextFieldViewModeWhileEditing;
    }else {
        self.changeBtn.selected = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        if (![self.nameT.text isEqualToString:@""]) {
            [defaults setValue:self.nameT.text forKey:@"username"];
            alt.message = @"修改成功！";
            [self.nameT resignFirstResponder];
            self.nameT.userInteractionEnabled = NO;
        }else {
            alt.message = @"用户名不能为空！";
        }
        [alt show];
    }
    
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
