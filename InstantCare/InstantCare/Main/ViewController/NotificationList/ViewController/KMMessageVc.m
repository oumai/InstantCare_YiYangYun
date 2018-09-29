//
//  KMMessageVc.m
//  InstantCare
//
//  Created by zxy on 2016/11/30.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMMessageVc.h"
#import "KMMessageCell.h"
#import "KMHeaderView.h"
#import "KMAlter.h"
#import "JPUSHService.h"
#import "KMPushListModel.h"
#import "AFNetworking.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "MJRefresh.h"
#import "EXTScope.h"
#import "MJExtension.h"
@interface KMMessageVc ()<UITableViewDataSource,UITableViewDelegate,KMHeaderViewDelegate,KMMessageCellDelegate>

/** 表格 */
@property (nonatomic,strong)UITableView *tableView;

/** 任务管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;

/** index*/
@property (nonatomic,assign)int index;

/** headerView */
@property (nonatomic,weak)KMHeaderView *headerView;

/** 网络请求模型 */
@property (nonatomic,strong) KMPushListModel *pushList;

/** 选中按钮数组 */
@property (nonatomic,strong) NSMutableArray *selArray;

/** 删除按钮 */
@property (nonatomic,weak) UIButton *deleteBtn;

/** 全选按钮 */
@property (nonatomic,weak) UIButton *allBtn;

@end

@implementation KMMessageVc

#pragma mark -懒加载
/** _manager */
-(AFHTTPSessionManager *)manager
{
    if (_manager == nil) {
        
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 10;
    }
    return _manager;
}

- (NSMutableArray *)selArray{
    if (_selArray != nil) {
        return _selArray;
    }
    _selArray = [NSMutableArray array];
    
    return _selArray;
}

-(void)dealloc
{
    //删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appHasGoneInForeground:(NSNotification *)not
{
    NSLog(@"appHasGoneInForeground");
    
    [self showHides];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(240, 240, 240);
    
    DMLog(@"jID = %@",[JPUSHService registrationID]);
    
    //增加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    DMLog(@"--deviceToken--%@",member.deviceToken);
    DMLog(@"loginAccount = %@",member.loginAccount);
    
    [self configNavigation];
    [self configTableView];
    [self setupRefresh];
}

-(void)configNavigation
{
    self.title = kLoadStringWithKey(@"nav_message");
     self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
}

/**
 *   返回上一级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 创建表格
 */
- (void)configTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 80;
    self.tableView.userInteractionEnabled = YES;

    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-49);
    }];
    
    KMHeaderView *headerView = [KMHeaderView viewFromXib];
    headerView.delegate = self;
    headerView.frame = CGRectMake(0, 0, self.view.size.width, 40);
    
    self.headerView = headerView;
    
    //tabbar
    UIView *tabbarView = [[UIView alloc]init];
    [self.view addSubview:tabbarView];
    
    tabbarView.backgroundColor = [UIColor whiteColor];
    tabbarView.layer.borderWidth = 1;
    tabbarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [tabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(49));
        make.bottom.equalTo(self.view);
    }];
    
    //delete按钮
    UIButton *deleteBtn = [[UIButton alloc]init];
    self.deleteBtn = deleteBtn;
    deleteBtn.backgroundColor = [UIColor redColor];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [deleteBtn setTitle:kLoadStringWithKey(@"message_delete_VC") forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tabbarView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tabbarView);
        make.width.equalTo(@(80));
    }];
    [deleteBtn addTarget:self action:@selector(deletePushMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    //全选按钮
    UIButton *allBtn = [[UIButton alloc]init];
    self.allBtn = allBtn;
    [allBtn setImage:[UIImage imageNamed:@"message_delete_nor"] forState:UIControlStateNormal];
    [allBtn setImage:[UIImage imageNamed:@"message_delete_sel"] forState:UIControlStateSelected];
    [tabbarView addSubview:allBtn];
    [allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(50));
        make.centerY.equalTo(tabbarView);
        make.left.equalTo(tabbarView);
    }];
    [allBtn addTarget:self action:@selector(didClickAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //全选Label
    UILabel *allLab = [[UILabel alloc]init];
    allLab.text = kLoadStringWithKey(@"message_all_selected_VC");
    allLab.textColor = [UIColor blackColor];
    allLab.font = [UIFont systemFontOfSize:15];
    [tabbarView addSubview:allLab];
    [allLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(allBtn.mas_right);
        make.centerY.equalTo(allBtn);
    }];
    
}

#pragma mark - Action
//全选按钮
- (void)didClickAllBtn:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    [self.selArray removeAllObjects];
    if (sender.isSelected) {
        //全选
        for (List *model in self.pushList.content.list) {
            model.isSelected = YES;
            [self.selArray addObject:[NSString stringWithFormat:@"%zd",model.p_id]];
        }
        [self.deleteBtn setTitle:[NSString stringWithFormat:@"%@(%zd)",kLoadStringWithKey(@"message_delete_VC"),self.selArray.count] forState:UIControlStateNormal];
        [self.tableView reloadData];
    }else{
        //取消全选
        for (List *model in self.pushList.content.list) {
            model.isSelected = NO;
        }
        [self.selArray removeAllObjects];
        [self.deleteBtn setTitle:kLoadStringWithKey(@"message_delete_VC") forState:UIControlStateNormal];
        [self.tableView reloadData];
    }
}
//删除按钮
- (void)deletePushMessage:(UIButton *)sender{
    if (self.selArray.count == 0) {
        return;
    }
    
    NSString *str = [self.selArray componentsJoinedByString:@","];
//    DMLog(@"%@",str);
    [self removePushWithStr:str];
}

- (void)removeArray{
    for (int i = 0; i < self.pushList.content.list.count; i++) {
        List *model = self.pushList.content.list[i];
        if (model.isSelected) {
            [self.pushList.content.list removeObjectAtIndex:i];
            i--;
        }
    }
    [self.deleteBtn setTitle:kLoadStringWithKey(@"message_delete_VC") forState:UIControlStateNormal];
    [self.selArray removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showHides];
}

#pragma mark - KMHeaderViewDelegate
- (void)headerViewButtonClick
{
    DMLog(@"headerViewButtonClick");
    
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
    {
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0f) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types) {
            NSLog(@"推送关闭");
        }else{
            NSLog(@"推送打开");
            
            self.tableView.tableHeaderView = nil;
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone == type){
            NSLog(@"推送关闭");
        }else{
            NSLog(@"推送打开");
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)showHides
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0f) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types) {
            NSLog(@"推送关闭");
            self.tableView.tableHeaderView = self.headerView;
        }else{
            NSLog(@"推送打开");
            
            self.tableView.tableHeaderView = nil;
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone == type){
            NSLog(@"推送关闭");
            self.tableView.tableHeaderView = self.headerView;
        }else{
            NSLog(@"推送打开");
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)setupRefresh
{
//    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMessage)];
//    [self.tableView.mj_header beginRefreshing];
    
    [self loadNewMessage];
//    self.tableView.mj_header = [MJRefreshHeader ]
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMessage)];

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessage)];
    
}

#pragma mark - <UITableViewDataSource>
/**
 *  告诉tableView第section组有多少行
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pushList.content.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMMessageCell *cell = [KMMessageCell cellWithTableView:tableView];
    
    cell.model = self.pushList.content.list[indexPath.row];
    
    cell.delegate = self;
    
    cell.index = indexPath.row;
    
    return cell;
}

#pragma mark - CellDelegate
- (void)selectCellWithIndex:(NSInteger)index andIs:(BOOL)is{
    self.pushList.content.list[index].isSelected = is;
    NSString *str = [NSString stringWithFormat:@"%zd",self.pushList.content.list[index].p_id];
    if (is) {
        [self.selArray addObject:str];
    }else{
        for (int i = 0; i < self.selArray.count; i++) {
            if ([self.selArray[i] isEqualToString:str]) {
                [self.selArray removeObjectAtIndex:i];
                break;
            }
        }
    }
//    DMLog(@"%@",self.selArray);
    if (self.selArray.count == 0) {
        [self.deleteBtn setTitle:kLoadStringWithKey(@"message_delete_VC") forState:UIControlStateNormal];
    }else{
        [self.deleteBtn setTitle:[NSString stringWithFormat:@"%@(%zd)",kLoadStringWithKey(@"message_delete_VC"),self.selArray.count] forState:UIControlStateNormal];
    }
    
}

#pragma mark - UITableViewDelegate 模块
// cell 选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

//侧滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self removePushWithIndexPath:indexPath];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - 删除通知
- (void)removePushWithIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    @weakify(self)
    List *model = self.pushList.content.list[indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%zd",model.p_id];
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/push/history/remove/%zd",kServerAddress,model.p_id];
    
    DMLog(@"url = %@",url);

    // 发送请求
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        if (model.isSelected) {
            for (int i = 0; i < self.selArray.count; i++) {
                if ([self.selArray[i] isEqualToString:str]) {
                    [self.selArray removeObjectAtIndex:i];
                    break;
                }
            }
            [self.deleteBtn setTitle:[NSString stringWithFormat:@"%@(%zd)",kLoadStringWithKey(@"message_delete_VC"),self.selArray.count] forState:UIControlStateNormal];
        }
        [self.pushList.content.list removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            // 取消了任务
            
        }else{
            // 是其他错误
            
        }
        [SVProgressHUD dismiss];
    }];
}
#pragma mark - 删除多个通知
- (void)removePushWithStr:(NSString *)str{
    [SVProgressHUD show];
    @weakify(self)
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/push/history/remove/%@",kServerAddress,str];
    
    DMLog(@"url = %@",url);
    
    // 发送请求
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        //调整数组
        [self removeArray];
        
        //刷新
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        self.allBtn.selected = NO;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            // 取消了任务
            
        }else{
            // 是其他错误
            
        }
        [SVProgressHUD dismiss];
        
    }];
}

#pragma mark - 数据加载
- (void)loadNewMessage
{
    @weakify(self)
    self.tableView.mj_footer.state = MJRefreshStateIdle;
    self.index = 0;
    
    // 取消所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/push/history/%@/%d/%d",kServerAddress, member.loginAccount,0,10];
    
    DMLog(@"url = %@",url);
                     
    
    // 发送请求
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        self.pushList = [KMPushListModel mj_objectWithKeyValues:responseObject];
        [self.selArray removeAllObjects];
        [self.deleteBtn setTitle:kLoadStringWithKey(@"message_delete_VC") forState:UIControlStateNormal];
        self.allBtn.selected = NO;
        // 刷新表格
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.index = 1;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            // 取消了任务
            [self.tableView.mj_header endRefreshing];
        }else{
            // 是其他错误
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
    
}

/**
 *加载更多
 */
- (void)loadMoreMessage
{
    @weakify(self)
    
    // 取消所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/push/history/%@/%d/%d",kServerAddress, member.loginAccount,self.index,10];
    
    DMLog(@"url = %@",url);
    
    
    // 发送请求
    [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        KMPushListModel *model = [KMPushListModel mj_objectWithKeyValues:responseObject];
        [self.pushList.content.list addObjectsFromArray:model.content.list];
        
        // 刷新表格
        [self.tableView reloadData];
        
        self.index += 1;
        
        if (model.content.list.count < 1) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
        
        // 让[刷新控件]结束刷新
        [self.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            // 取消了任务
            
            // 让[刷新控件]结束刷新
            [self.tableView.mj_footer endRefreshing];
            
        }else{
            // 是其他错误
            
            // 让[刷新控件]结束刷新
            [self.tableView.mj_footer endRefreshing];
        }
    }];

}

@end
