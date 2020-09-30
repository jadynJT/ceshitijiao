//
//  SearchViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/6/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "SearchViewController.h"
#import "CustomSearchResultCell.h"


@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *topBgImgView;

@property (strong, nonatomic) NSMutableArray *arrayAllMembers;
@property (strong, nonatomic) NSMutableArray *arrayResultModels;

@property (nonatomic, strong) DataModel* lastAddMember;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self requestForSearch];
    
    self.lastAddMember = [DataCenter sharedDataCenter].lastAddMember;
    if ( ![Utility isBlankString:self.lastAddMember.uid]
        && ![Utility isBlankString:self.lastAddMember.phoneNum]
        && ![self isInSearchResultWithEntity:self.lastAddMember]) {
        
        self.searchBar.text = @"";
        [self.arrayResultModels removeAllObjects];
        [self.arrayResultModels addObject:self.lastAddMember];
        [DataCenter sharedDataCenter].lastAddMember = nil;
        
        [self.tableView reloadData];
    }
}

- (BOOL)isInSearchResultWithEntity:(DataModel*)entity
{
    BOOL bisInSearchResult = NO;
    for (DataModel* entityInArray in self.arrayResultModels) {
        if (entityInArray.uid == entity.uid) {
            bisInSearchResult = YES;
            break;
        }
    }
    return bisInSearchResult;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGBA(0xF5F5F5, 1.0);
    
    [self layoutSubView];
    [self configNavBar];
    
    self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    
    //添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

#pragma mark - 初始化
- (NSMutableArray *)arrayResultModels{
    if (!_arrayResultModels) {
        _arrayResultModels = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _arrayResultModels;
}

- (NSMutableArray *)arrayAllMembers{
    if (!_arrayAllMembers) {
        _arrayAllMembers = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _arrayAllMembers;
}

- (UIImageView *)topBgImgView
{
    if (!_topBgImgView) {
        _topBgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_top_background_list"]];
        [self.view addSubview:_topBgImgView];
    }
    return _topBgImgView;
}

#pragma mark - UILayout
- (void)layoutSubView{
    _searchBar.placeholder = @"会员卡号/手机号搜索";
    _searchBar.backgroundColor = [UIColor clearColor];
    [_searchBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    _searchBar.delegate = self;
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(_searchBtn.mas_left).offset(-12/Proportion_height);
        make.height.mas_equalTo(62/Proportion_height);
    }];
    [_searchBar layoutIfNeeded];
    
    _searchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-18/Proportion_height);
        make.width.mas_equalTo(78/Proportion_height);
        make.height.mas_equalTo(32);
        make.centerY.equalTo(_searchBar.mas_centerY);
    }];
    [_searchBtn layoutIfNeeded];
    
    [self.topBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44+62/Proportion_height);
        make.width.mas_offset(UISCREEN_BOUNCES.size.width);
        make.height.mas_offset(137/Proportion_height);
    }];
    
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44+(62+137)/Proportion_height);
        make.width.mas_offset(UISCREEN_BOUNCES.size.width);
        make.height.mas_offset(UISCREEN_BOUNCES.size.height/2);
    }];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
    _tableView.tableFooterView = [[UIView alloc]init];
}

- (void)configNavBar
{
    self.title = @"慢病会员搜索";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStyleBordered target:self action:@selector(addBtnAction)];
    
    [self.navigationItem setRightBarButtonItem:rightBtn];

    self.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#pragma mark - request
- (void)requestForSearch
{
    [PPNetworkHelper GET:URL_SEARCH parameters:nil success:^(id responseObject) {
        NSArray* magazineArr = (NSArray *)responseObject;
        for (NSDictionary *userDic in magazineArr) {
            DataModel *search = [[DataModel alloc] initWithDictionary:userDic];
            [self.arrayAllMembers addObject:search];
        }
        
        [_tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}

#pragma mark - btnAction
- (IBAction)searchAction:(UIButton *)sender {
    //搜索按钮
    [self searchNameOrNumber];
}

//测量按钮
- (void)measureAction:(UIButton *)sender
{
    MeasurePageViewController *vc = [MeasurePageViewController new];
    
    vc.member_id = ((DataModel*)[self.arrayResultModels lastObject]).uid;
    
    NSLog(@"member_id===%@",vc.member_id);

    [self.navigationController pushViewController:vc animated:YES];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBtn];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255 green:89 blue:111 alpha:1];
}

//添加按钮
- (void)addBtnAction
{
    //跳转添加慢病会员页面
    [Utility gotoNextVC:[MemerShipViewController new] fromViewController:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //搜索按钮
    [self searchNameOrNumber];
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (self.arrayResultModels && self.arrayResultModels.count>0) {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CustomSearchResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    DataModel *searchedModel = [self.arrayResultModels lastObject];
    
    if (![Utility isBlankString:searchedModel.phoneNum]){
        cell.phoneNumLabel.text = searchedModel.phoneNum;
    }
    
    cell.measureBtn.tag = self.arrayResultModels.count - 1 + 200;
    [cell.measureBtn addTarget:self action:@selector(measureAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


//会员查询
- (void)searchNameOrNumber
{
    NSString* strKeyWork =_searchBar.text;
    if (strKeyWork) {
        strKeyWork = [strKeyWork stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    BOOL bIsSearchSuccess = NO;
    if ([strKeyWork isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请输入会员卡号或手机号！"];
        [_searchBar resignFirstResponder];
    }
    else
    {
        for (DataModel* modelObj in self.arrayAllMembers) {
            
            if ([modelObj.phoneNum isEqualToString:strKeyWork] ) {
                [self.arrayResultModels removeAllObjects];
                [self.arrayResultModels addObject:modelObj];
                bIsSearchSuccess = YES;
            }
        }
        
        if (NO == bIsSearchSuccess){
            [SVProgressHUD showInfoWithStatus:@"您还不是慢病会员，请检查输入的会员卡号或手机号是否有误"];
        }
    }
    [_tableView reloadData];
}

//键盘下落
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
