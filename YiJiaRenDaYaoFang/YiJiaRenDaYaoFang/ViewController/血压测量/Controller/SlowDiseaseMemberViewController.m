//
//  SlowDiseaseMemberViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "SlowDiseaseMemberViewController.h"
#import "MeasurePageViewController.h"

@interface SlowDiseaseMemberViewController ()<UITextFieldDelegate>
{
    IBOutlet UILabel *_tipLabel;
    
    IBOutlet UILabel *_barCodeLabel;
    
    IBOutlet UILabel *_nameLabel;
    
    IBOutlet UILabel *_sexLabel;
    
    IBOutlet UILabel *_ageLabel;
    
    IBOutlet UILabel *_etiologyLabel;
    
    IBOutlet UITextField *_barCodeTextField;
    
    IBOutlet UITextField *_nameTextField;
    
    IBOutlet UISegmentedControl *_sexSegCtr;
    
    IBOutlet UITextField *_ageTextField;
    
    IBOutlet UITextField *_etiologyTextField;
    
    IBOutlet UIButton *_confirmBtn;
}
@end

@implementation SlowDiseaseMemberViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNav];
    [self layoutUI];
    
    //添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

#pragma mark - configUI

- (void)configNav {
    self.title = @"完善会员资料";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)layoutUI {
    // 提示
    _tipLabel.tintColor = UIColorFromRGBA(0x646464, 0.8);
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(44+10);
        make.left.and.right.equalTo(self.view).offset(5);
        make.height.mas_equalTo(35);
    }];
    [_tipLabel layoutIfNeeded];
    
    // 条形码
    _barCodeTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_barCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tipLabel.mas_bottom).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.left.equalTo(_barCodeLabel.mas_right).offset(10);
        make.height.mas_equalTo(35);
    }];
    [_barCodeTextField layoutIfNeeded];
    
    _barCodeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _barCodeLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    _barCodeLabel.textAlignment = NSTextAlignmentRight;
    [_barCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(35);
        make.centerY.mas_equalTo(_barCodeTextField.mas_centerY);
    }];
    [_barCodeLabel layoutIfNeeded];
    
    // 姓名
    _nameTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_barCodeTextField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_barCodeTextField);
        make.width.and.height.mas_equalTo(_barCodeTextField);
    }];
    [_nameTextField layoutIfNeeded];
    
    _nameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _nameLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    _nameLabel.textAlignment = NSTextAlignmentRight;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_nameTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_barCodeLabel);
        make.right.equalTo(_nameTextField.mas_left).offset(-10);
    }];
    [_nameLabel layoutIfNeeded];
    
    // 性别
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
                                               NSForegroundColorAttributeName: UIColorFromRGBA(0x646464, 0.8)};
    [_sexSegCtr setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    
    [_sexSegCtr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameTextField.mas_bottom).offset(10);
        make.height.mas_equalTo(_barCodeTextField.mas_height);
        make.right.equalTo(self.view.mas_right).offset(-50);
    }];
    [_sexSegCtr layoutIfNeeded];
    
    _sexLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _sexLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    _sexLabel.textAlignment = NSTextAlignmentRight;
    [_sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_sexSegCtr.mas_centerY);
        make.width.and.height.mas_equalTo(_barCodeLabel);
        make.right.equalTo(_sexSegCtr.mas_left).offset(-10);
        make.centerX.equalTo(_barCodeLabel.mas_centerX).offset(0);
    }];
    [_sexLabel layoutIfNeeded];
    
    // 年龄
    _ageTextField.delegate = self;
    _ageTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    _ageTextField.tag = 203;
    _ageTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_ageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sexSegCtr.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_barCodeTextField);
        make.width.and.height.mas_equalTo(_barCodeTextField);
    }];
    [_ageTextField layoutIfNeeded];
    
    _ageLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _ageLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    _ageLabel.textAlignment = NSTextAlignmentRight;
    [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_ageTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_barCodeLabel);
        make.right.equalTo(_ageTextField.mas_left).offset(-10);
    }];
    [_ageLabel layoutIfNeeded];
    
    // 病因
    _etiologyTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_etiologyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ageTextField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_barCodeTextField);
        make.width.and.height.mas_equalTo(_barCodeTextField);
    }];
    [_etiologyTextField layoutIfNeeded];
    
    _etiologyLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _etiologyLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    _etiologyLabel.textAlignment = NSTextAlignmentRight;
    [_etiologyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_etiologyTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_barCodeLabel);
        make.right.equalTo(_etiologyTextField.mas_left).offset(-10);
    }];
    [_etiologyLabel layoutIfNeeded];
    
    // 添加按钮
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.equalTo(_etiologyTextField.mas_bottom).offset(40);
        make.width.equalTo(_barCodeTextField.mas_width);
        make.height.mas_equalTo(40);
    }];
    [_confirmBtn layoutIfNeeded];
}
#pragma mark - btnClickAction

//键盘下落
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

- (IBAction)confirmBtnAction:(UIButton *)sender {
    //保存会员资料后 跳转 测量界面
    if (_barCodeTextField.text.length <= 0) {
        SHOW_ALERT(@"卡号不能为空");
        return;
    }
    else if (_nameTextField.text.length <= 0) {
        SHOW_ALERT(@"会员姓名不能为空");
        return;
    }
    
    [self requestForMember];
}

#pragma mark - request
- (void)requestForMember{
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:_nameTextField.text forKey:@"name"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)_sexSegCtr.selectedSegmentIndex+1] forKey:@"sex"];
    [dic setObject:_ageTextField.text forKey:@"age"];
    [dic setObject:_etiologyTextField.text forKey:@"symptoms"];
    [dic setObject:_barCodeTextField.text forKey:@"bar_code"];
    
    [PPNetworkHelper POST:URL_ADD parameters:dic success:^(id responseObject) {
        
        if ([[responseObject objectForKey:@"result"] intValue] == 1 ) {
            [self gotoMeasurePageVC];
        }else{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"error"]]];
            
        }
        [USER_D synchronize];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }];
}

//跳转 测量页面
- (void)gotoMeasurePageVC {
    [Utility gotoNextVC:[MeasurePageViewController new] fromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 203) {
        return [Utility validateNumber:string];
    }
    return YES;
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
