//
//  MemerShipViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MemerShipViewController.h"

@interface MemerShipViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    
    IBOutlet UILabel *_phoneNumLabel;
    
    IBOutlet UILabel *_passwdLabel;
    
    IBOutlet UILabel *_barCodeLabel;
    
    IBOutlet UILabel *_nameLabel;
    
    IBOutlet UILabel *_sexLabel;
    
    IBOutlet UILabel *_ageLabel;
    
    IBOutlet UILabel *_etiologyLabel;
    
    IBOutlet UITextField *_phoneNumTextField;
    
    IBOutlet UITextField *_passwdTextField;
    
    IBOutlet UILabel *_tipLabel;
    
    IBOutlet UITextField *_barCodeTextField;
    
    IBOutlet UITextField *_nameTextField;
    
    IBOutlet UISegmentedControl *_sexSegCtr;
    
    IBOutlet UITextField *_ageTextField;
    IBOutlet UITextField *_etiologyTextField;
}

@end

@implementation MemerShipViewController

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

- (void)configNav {
    self.title = @"添加慢病会员";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStyleBordered target:self action:@selector(addBtnAction:)];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)layoutUI {
    // 手机号
    _phoneNumLabel.textAlignment = NSTextAlignmentRight;
    _phoneNumLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _phoneNumLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(35);
        make.centerY.mas_equalTo(_phoneNumTextField.mas_centerY);
    }];
    [_phoneNumLabel layoutIfNeeded];
    
    _phoneNumTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    _phoneNumTextField.delegate = self;
    _phoneNumTextField.tag = 200;
    _phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(44+10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.left.equalTo(_phoneNumLabel.mas_right).offset(10);
        make.height.mas_equalTo(35);
    }];
    [_phoneNumTextField layoutIfNeeded];
    
    //密码
    _passwdTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_passwdTextField setSecureTextEntry:YES];
    [_passwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phoneNumTextField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.and.height.mas_equalTo(_phoneNumTextField);
    }];
    [_passwdTextField layoutIfNeeded];
    
    _passwdLabel.textAlignment = NSTextAlignmentRight;
    _passwdLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _passwdLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_passwdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_passwdTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_phoneNumLabel);
        make.right.equalTo(_passwdTextField.mas_left).offset(-10);
    }];
    [_passwdTextField layoutIfNeeded];

    // 提示
    _tipLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _tipLabel.textColor = UIColorFromRGBA(0xFF0000, 0.8);
    _tipLabel.text = @"如不需修改密码请忽略";
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_passwdTextField.mas_bottom).offset(5);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.mas_equalTo(_phoneNumTextField);
        make.height.mas_equalTo(20);
    }];
    [_tipLabel layoutIfNeeded];
    
    // 条形码
    _barCodeTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_barCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tipLabel.mas_bottom).offset(5);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.and.height.mas_equalTo(_phoneNumTextField);
    }];
    [_barCodeTextField layoutIfNeeded];
    
    _barCodeLabel.textAlignment = NSTextAlignmentRight;
    _barCodeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _barCodeLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_barCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_barCodeTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_phoneNumLabel);
        make.right.equalTo(_barCodeTextField.mas_left).offset(-10);
    }];
    [_barCodeLabel layoutIfNeeded];

    
    // 姓名
    _nameTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_barCodeTextField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.and.height.mas_equalTo(_phoneNumTextField);
    }];
    [_nameTextField layoutIfNeeded];
    
    _nameLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _nameLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_nameTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_phoneNumLabel);
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
    

    _sexLabel.textAlignment = NSTextAlignmentRight;
    _sexLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _sexLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_sexSegCtr.mas_centerY);
        make.width.and.height.mas_equalTo(_barCodeLabel);
        make.right.equalTo(_sexSegCtr.mas_left).offset(-10);
        make.centerX.equalTo(_barCodeLabel.mas_centerX).offset(0);
    }];
    [_sexLabel layoutIfNeeded];
    
    // 年龄
    _ageTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    _ageTextField.delegate = self;
    _ageTextField.tag = 201;
    _ageTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_ageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sexSegCtr.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.and.height.mas_equalTo(_phoneNumTextField);
    }];
    [_ageTextField layoutIfNeeded];
    
    _ageLabel.textAlignment = NSTextAlignmentRight;
    _ageLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _ageLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_ageTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_phoneNumLabel);
        make.right.equalTo(_ageTextField.mas_left).offset(-10);
    }];
    [_ageLabel layoutIfNeeded];

    // 病因
    _etiologyTextField.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_etiologyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ageTextField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_phoneNumTextField);
        make.width.and.height.mas_equalTo(_phoneNumTextField);
    }];
    [_etiologyTextField layoutIfNeeded];
    
    _etiologyLabel.textAlignment = NSTextAlignmentRight;
    _etiologyLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _etiologyLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [_etiologyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_etiologyTextField.mas_centerY);
        make.width.and.height.mas_equalTo(_phoneNumLabel);
        make.right.equalTo(_etiologyTextField.mas_left).offset(-10);
    }];
    [_etiologyLabel layoutIfNeeded];

}

//键盘下落
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}


- (void)addBtnAction:(UIButton *)sender {
    if (_phoneNumTextField.text.length <= 0) {
        SHOW_ALERT(@"手机号不能为空");
        return;
    }
    
    if (_nameTextField.text.length <= 0) {
        SHOW_ALERT(@"会员姓名不能为空");
        return;
    }
    
    if (_ageTextField.text.length <= 0) {
        SHOW_ALERT(@"年龄不能为空");
        return;
    }
    
    [self requestForAddMember];
}


#pragma mark - request
- (void)requestForAddMember{
    
    NSDictionary *dic = @{
                          @"login_name":_phoneNumTextField.text,
                          @"name":_nameTextField.text,
                          @"password":_passwdTextField.text,
                          @"sex":[NSString stringWithFormat:@"%ld",(long)_sexSegCtr.selectedSegmentIndex+1],
                          @"age":_ageTextField.text,
                          @"symptoms":_etiologyTextField.text,
                          @"bar_code":_barCodeTextField.text
                          };
    
    [PPNetworkHelper POST:URL_ADD parameters:dic success:^(id responseObject) {
        NSMutableDictionary *chronicmember = [[NSMutableDictionary alloc] initWithCapacity:0];
        chronicmember = [responseObject objectForKey:@"chronicmember"];
        
        [DataCenter sharedDataCenter].lastAddMember.uid = [chronicmember objectForKey:@"member_id"];
        [DataCenter sharedDataCenter].lastAddMember.phoneNum = [chronicmember objectForKey:@"login_name"];
        
        if ([[responseObject objectForKey:@"result"] intValue] == 1 ) {
            
            SHOW_ALERT_Title(@"OK", @"添加成功");
            alert.delegate = self;
        }else{
            [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"error"]];
        }

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        NSLog(@"error %@",error);

    }];

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   
    if (textField.tag == 200 || textField.tag == 201) {
         return [Utility validateNumber:string];
    }

    return YES;
}



#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        //返回搜索页面
        [self.navigationController popViewControllerAnimated:YES];
    }
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
