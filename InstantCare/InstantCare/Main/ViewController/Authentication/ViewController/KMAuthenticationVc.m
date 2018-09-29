//
//  KMAuthenticationVc.m
//  InstantCare
//
//  Created by KM on 2016/11/29.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAuthenticationVc.h"
#import "KMSimTextField.h"
#import "KMAuthenticationCell.h"
#import "KMCustomButton.h"

//#import "KMSetNameVc.h"
#import "KMSetSexVc.h"
//#import "KMSetCardVc.h"
#import "KMSetAddressVc.h"

#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMCompleteVc.h"
#import "JKAlert.h"
#import "UIImage+Resize.h"
#import "AFNetworking.h"
#import "SKFCamera.h"
#import "TOCropViewController.h"
#import "UIBarButtonItem+Extension.h"
#define DEF_NUMBERCHARCHIN [self specialSymbolsAction]

@interface KMAuthenticationVc ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,TOCropViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewTopConstraints;
@property (weak, nonatomic) IBOutlet KMSimTextField *simTextField;
@property (weak, nonatomic) IBOutlet UIView *simTextView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet KMCustomButton *leftBtn;
@property (weak, nonatomic) IBOutlet KMCustomButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *comitBtn;

/** nameField */
@property (nonatomic,strong)KMSimTextField *nameField;

/** cardField */
@property (nonatomic,strong)KMSimTextField *cardField;

/** 任务管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;

/**
 *标记
 */
@property (nonatomic,assign)int flag;

/**
 *  身份证正面照片
 */
@property (nonatomic, strong) UIImage *topImage;
/**
 *  身份证背面照片
 */
@property (nonatomic, strong) UIImage *bottomImage;


/**名称*/
@property (nonatomic,copy)NSString *name;
/**性别*/
@property (nonatomic,copy)NSString *sex;
/**住址*/
@property (nonatomic,copy)NSString *address;
/**身份证号*/
@property (nonatomic,copy)NSString *card;

/**
 *title数据
 */
@property (nonatomic,strong)NSArray *titleArr;


@property(nonatomic,strong)UIDatePicker * dataPicker;
@property(nonatomic,strong)CustomIOSAlertView * timeSelected;
/** seletTime */
@property (nonatomic,copy)NSString *birthday;

@end

@implementation KMAuthenticationVc

#pragma mark -懒加载
/** _manager */
-(AFHTTPSessionManager *)manager
{
    if (_manager == nil) {
        
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArr = @[@"KMVIPServer_Name",@"KMVIPServer_Sex",@"KMVIPServer_Birthday",@"Reg_VC_tip_address",@"KMVIPServer_IDCard"];
    
    //先清除历史参数
    [self removeParame];
    
    [self setupUI];
}

/**
 *先清除历史参数
 */
- (void)removeParame
{
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"nameTextField"];
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"Sex"];
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"Address"];
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"CardTextField"];
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"Birthday"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.name = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameTextField"];
    self.sex = [[NSUserDefaults standardUserDefaults]objectForKey:@"Sex"];
    self.card = [[NSUserDefaults standardUserDefaults]objectForKey:@"CardTextField"];
    self.address = [[NSUserDefaults standardUserDefaults]objectForKey:@"Address"];
    [self.tableView reloadData];
}

- (void)setupUI
{
    
    
    self.navigationItem.title = kLoadStringWithKey(@"real_name_authentication");
    self.view.backgroundColor = RGB(247, 247, 246);
    self.bgView.backgroundColor = RGB(247, 247, 246);
    
    // 设配iphonex
    self.bgViewTopConstraints.constant = IS_IPHONE_X ? 88 : 64;
    [self.view layoutIfNeeded];
    
    [self.leftBtn setTitle:kLoadStringWithKey(@"VIPService_VC_upload_card_top") forState:UIControlStateNormal];
    [self.rightBtn setTitle:kLoadStringWithKey(@"VIPService_VC_upload_card_bottom") forState:UIControlStateNormal];
    
    self.leftBtn.layer.cornerRadius = 5;
    self.rightBtn.layer.cornerRadius = 5;
    self.leftBtn.layer.masksToBounds = YES;
    self.rightBtn.layer.masksToBounds = YES;
    
    UIBarButtonItem *leftNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [leftNegativeSpacer setWidth:-10];
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
    
    self.navigationItem.leftBarButtonItems = @[leftNegativeSpacer,leftBarButtonItem];
    
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 22)];
    
    UIImageView *simImg = [[UIImageView alloc]init];
    simImg.image = [UIImage imageNamed:@"simcaricon"];
    [tempView addSubview:simImg];
    [simImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(tempView);
        make.right.mas_equalTo(tempView.mas_right).offset(-15);
    }];
    
    self.simTextField.leftView = tempView;
    self.simTextField.delegate = self;
    self.simTextField.leftViewMode = UITextFieldViewModeAlways;
    self.simTextField.placeholder = kLoadStringWithKey(@"simTextField_placeholder");
    
    self.simTextView.layer.cornerRadius = 12;
    self.simTextView.layer.masksToBounds = YES;
    self.simTextView.layer.borderWidth = 1;
    self.simTextView.layer.borderColor = RGB(240, 240, 240).CGColor;
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = RGB(247, 247, 246);
    
    self.comitBtn.layer.cornerRadius = 20;
    self.comitBtn.backgroundColor = RGB(241, 132, 43);
    [self.comitBtn setTitle:kLoadStringWithKey(@"submit") forState:UIControlStateNormal];
    self.comitBtn.layer.masksToBounds = YES;
    
    
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"self.name = %@",self.name);
    KMAuthenticationCell *cell = [KMAuthenticationCell cellWithTableView:tableView];

    cell.title = self.titleArr[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            KMSimTextField *nameField = [[KMSimTextField alloc]init];
            nameField.textAlignment = NSTextAlignmentRight;
            nameField.textColor = [UIColor grayColor];
            nameField.text = self.name;
            [cell.contentView addSubview:nameField];
            
            [nameField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(cell.contentView);
                make.left.equalTo(cell.contentView).mas_offset(80);
                make.right.equalTo(cell.contentView).mas_offset(-35);
            }];
            
            nameField.text = self.nameField.text;
            [self.nameField removeFromSuperview];
            
            self.nameField = nameField;
            
            self.nameField.delegate = self;
            
            self.name = self.nameField.text;
            
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
            break;
        case 1:
            cell.detailTextLabel.text = self.sex;
            break;
        case 2:
            cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Birthday"];
            break;
        case 3:
            cell.detailTextLabel.text = self.address;
            break;
        case 4:
        {
            KMSimTextField *cardField = [[KMSimTextField alloc]init];
            cardField.textAlignment = NSTextAlignmentRight;
            cardField.textColor = [UIColor grayColor];
            cardField.text = self.card;
            [cell.contentView addSubview:cardField];
            
            [cardField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(cell.contentView);
                make.left.equalTo(cell.contentView).mas_offset(80);
                make.right.equalTo(cell.contentView).mas_offset(-30);
            }];
            cardField.text = self.cardField.text;
            
            [self.cardField removeFromSuperview];
            self.cardField = cardField;
            self.cardField.delegate = self;
            
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate 模块
// cell 选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:// 名称设置
        {
            //            KMSetNameVc *vc = [[KMSetNameVc alloc]init];
            //            vc.text = self.name;
            //            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:// 性别
        {
            KMSetSexVc *vc = [[KMSetSexVc alloc]init];
            vc.sex = self.sex;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:// 生日
        {
            [self showTimeSelectedAlertView];
        }
            break;
        case 3:// 住址
        {
            KMSetAddressVc *vc = [[KMSetAddressVc alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:// 身份证号
        {
            //            KMSetCardVc *vc = [[KMSetCardVc alloc]init];
            //            vc.text = self.card;
            //            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

//身份证正面
- (IBAction)btnClick:(KMCustomButton *)sender {
    
    self.flag = 0;
    [self photoClick:sender];
    
}

//身份证反面
- (IBAction)btnRightClick:(KMCustomButton *)sender {
    self.flag = 1;
    [self photoClick:sender];
}

- (void)photoClick:(UIButton *)sender
{
    WS(ws);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    // 照相机
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src_camera")style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            SKFCamera *homec=[[SKFCamera alloc]init];
            __weak typeof(self)myself=self;
            homec.fininshcapture=^(UIImage *img){
                if (img) {
                    if (sender.tag == 100) {
                        _topImage = img;
                        [self.leftBtn setBackgroundImage:img forState:UIControlStateNormal];
                        self.leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [self.leftBtn setTitle:@"" forState:UIControlStateNormal];
                        [self.leftBtn setImage:nil forState:UIControlStateNormal];
                    }else if(sender.tag == 101){
                        _bottomImage = img;
                        [self.rightBtn setBackgroundImage:img forState:UIControlStateNormal];
                        self.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [self.rightBtn setTitle:@"" forState:UIControlStateNormal];
                        [self.rightBtn setImage:nil forState:UIControlStateNormal];
                    }
                    DMLog(@"照片存在");
                    
                }
            } ;
            [myself presentViewController:homec animated:NO completion:^{}];}
        
    }];
    [alertController addAction:cameraAction];
    
    // 本地相册
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src_gallery")style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = ws;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        [ws presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    [alertController addAction:galleryAction];
    
    // 取消
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Common_cancel", APP_LAN_TABLE, nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action1];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = nil;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:img];
    cropController.delegate = self;
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:cropController animated:YES completion:nil];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
    if (self.flag == 0) {
        _topImage = image;
        [self.leftBtn setBackgroundImage:image forState:UIControlStateNormal];
        self.leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.leftBtn setTitle:@"" forState:UIControlStateNormal];
        [self.leftBtn setImage:nil forState:UIControlStateNormal];
    }else if (self.flag == 1){
        _bottomImage = image;
        [self.rightBtn setBackgroundImage:image forState:UIControlStateNormal];
        self.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.rightBtn setTitle:@"" forState:UIControlStateNormal];
        [self.rightBtn setImage:nil forState:UIControlStateNormal];
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 *   返回上一级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -时间处理

// 启动选择时间对话框
-(void)showTimeSelectedAlertView
{
    // 提示框
    self.timeSelected = [[CustomIOSAlertView alloc] init];
    self.timeSelected.buttonTitles = nil;
    [self.timeSelected setUseMotionEffects:NO];
    
    
    //提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300,250)];
    view.titleLabel.text = kLoadStringWithKey(@"KMVIPServer_Birthday");
    view.buttonsArray = @[kLoadStringWithKey(@"Reg_VC_birthday_cancel"),kLoadStringWithKey(@"Reg_VC_birthday_OK")];
    
    //按钮点击事件；
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(timeAlertSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(timeAlertSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置内容视图
    
    UIDatePicker * datePicker = [[UIDatePicker alloc] init];
    [view.customerView addSubview:datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.center.equalTo(view);
        make.height.mas_equalTo(150);
    }];
    datePicker.locale = [NSLocale currentLocale];
    
    datePicker.datePickerMode = UIDatePickerModeDate;
    //    datePicker.minimumDate = [NSDate date];
    self.dataPicker = datePicker;
    
    //提示框显示
    self.timeSelected.containerView = view;
    [self.timeSelected show];
    
}

-(void)timeAlertSelectedAction:(UIButton *)sender
{
    NSInteger index = sender.tag - 3000;
    if (index == 2)
    {
        
        // 设置标签内容；
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        //        dateFormatter.dateFormat = @"HH:mm";MMM
        NSString *birthdayStr = [NSMutableString stringWithString:[dateFormatter stringFromDate:self.dataPicker.date]];
        
        [[NSUserDefaults standardUserDefaults]setObject:birthdayStr forKey:@"Birthday"];
        
        //         [self.tableView reloadData];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    [self.timeSelected close];
}

- (IBAction)submit:(UIButton *)sender {
    [SVProgressHUD show];
    // 取消所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    self.birthday = [[NSUserDefaults standardUserDefaults]objectForKey:@"Birthday"];
    
    if ((self.simTextField.text.length > 0) && (self.nameField.text.length > 0) && (self.sex.length > 0) && (self.address.length >0) && (self.cardField.text.length > 0) && (self.birthday.length > 0) && (self.topImage != nil) && (self.bottomImage != nil)){
        
        self.navigationItem.title = kLoadStringWithKey(@"loading");
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        self.manager.requestSerializer = serializer;
        
        NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/identifySIM",kServerAddress];
        
        NSString *leftImg = [self base64StringWithImage:self.topImage];
        NSString *rightImg = [self base64StringWithImage:self.bottomImage];
        
        NSDictionary *params = @{@"account":member.loginAccount,@"sim":self.simTextField.text,@"sex":self.sex,@"name":self.nameField.text,@"birthday":self.birthday,@"address":self.address,@"Idnumber":self.cardField.text,@"uploadPositive":leftImg,@"uploadOpposite":rightImg};
        
        [self.comitBtn setUserInteractionEnabled:NO];
        // 发送请求
        [self.manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *responseObject) {
            
            NSString *msg = responseObject[@"msg"];
            DMLog(@"code = %@",msg);
            
            if ([msg isEqualToString:@"OK"]) {
                [SVProgressHUD dismiss];
                KMCompleteVc *vc = [[KMCompleteVc alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([msg isEqualToString:@"ERROR: SIM card does not exist."]){
                
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"SIM_card_does_not_exist")];
            }else if ([msg isEqualToString:@"ERROR: SIM card real name authentication."]){
                
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"sim_real_name_authentication")];
            }else if ([msg isEqualToString:@"ERROR: SIM card has real name authentication."]){
                
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"sim_real_name_authentication")];
            }else if ([msg isEqualToString:@"ERROR: SIM error."]){
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"SIM_card_does_not_exist")];
            }else if ([msg isEqualToString:@"ERROR: Account not exist or sim number is not belong to kangmei health cloud"]){
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"sim_not_exist")];
            }else{
                [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"Authentication_failed")];
            }
            
            self.navigationItem.title = kLoadStringWithKey(@"real_name_authentication");
            
            DMLog(@"responseObject = %@",responseObject);
            
             [self.comitBtn setUserInteractionEnabled:YES];
//            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            DMLog(@"error = %@",error);
            
            [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"Auth_Failed")];
            
            self.navigationItem.title = kLoadStringWithKey(@"real_name_authentication");
            
             [self.comitBtn setUserInteractionEnabled:YES];
            
        }];
        
        
    }else{
        [JKAlert alertText:kLoadStringWithKey(@"JKAlert")];
//        [SVProgressHUD dismiss];
    }
    
    
}



- (NSString *)base64StringWithImage:(UIImage *)originImage {
    UIImage *image;
    if (originImage.size.width > 1280 || originImage.size.height > 900) {
        CGSize bounds = CGSizeMake(1280, 900);
        image = [originImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:bounds interpolationQuality:0.9];
    } else {
        image = originImage;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    return [imageData base64EncodedStringWithOptions:0];
}

- (void)dealloc
{
    // 取消所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
}


//只允许输入数字
- (BOOL)validateNumber:(NSString*)number{
    BOOL res = YES;
    NSCharacterSet *tempSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    int i = 0;
    while (i < number.length) {
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tempSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        
        i++;
    }
    
    return res;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([textField isEqual:self.simTextField]) {
        if (textField.text.length == 11) {
            if ([string isEqualToString:@""]) {
                return YES;
            }else{
                return NO;
            }
        }
        
        return [self validateNumber:string];
    }else if ([textField isEqual:self.cardField]){
        
        if (textField.text.length == 18) {
            if ([string isEqualToString:@""]) {
                return YES;
            }else{
                return NO;
            }
        }
        
        BOOL res = YES;
        NSCharacterSet *tempSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        
        int i = 0;
        while (i < string.length) {
            NSString *str = [string substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [str rangeOfCharacterFromSet:tempSet];
            if (range.length == 0) {
                res = NO;
                break;
            }
            
            i++;
        }
        
        return res;
    }else if ([textField isEqual:self.nameField]){
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:DEF_NUMBERCHARCHIN]invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL basicTest = [string isEqualToString:filtered];
        if(basicTest){
            if([string isEqualToString:@""]){
                return YES;
            }
            return NO;
        }
    }
    
    return YES;
}

/// 特殊符号
- (NSString *)specialSymbolsAction{
    //数学符号
    NSString *matSym = @" ﹢﹣×÷±/=≌∽≦≧≒﹤﹥≈≡≠=≤≥<>≮≯∷∶∫∮∝∞∧∨∑∏∪∩∈∵∴⊥∥∠⌒⊙√∟⊿㏒㏑%‰⅟½⅓⅕⅙⅛⅔⅖⅚⅜¾⅗⅝⅞⅘≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩⊰⊱⋛⋚∫∬∭∮∯∰∱∲∳%℅‰‱øØπ";
    
    //标点符号
    NSString *punSym = @"。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦﹤‐￣¯―﹨ˆ˜﹍﹎+=<＿_-ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸﹀︺︾ˉ﹂﹄︼❝❞!():,'[]｛｝^・.·．•＃＾＊＋＝＼＜＞＆§⋯`－–／—|\"\\";
    
    //单位符号＊·
    NSString *unitSym = @"°′″＄￥〒￠￡％＠℃℉﹩﹪‰﹫㎡㏕㎜㎝㎞㏎m³㎎㎏㏄º○¤%$º¹²³";
    
    //货币符号
    NSString *curSym = @"₽€£Ұ₴$₰¢₤¥₳₲₪₵元₣₱฿¤₡₮₭₩ރ円₢₥₫₦zł﷼₠₧₯₨Kčर₹ƒ₸￠";
    
    //制表符
    NSString *tabSym = @"─ ━│┃╌╍╎╏┄ ┅┆┇┈ ┉┊┋┌┍┎┏┐┑┒┓└ ┕┖┗ ┘┙┚┛├┝┞┟┠┡┢┣ ┤┥┦┧┨┩┪┫┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻┼ ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╪ ╫ ╬═║╒╓╔ ╕╖╗╘╙╚ ╛╜╝╞╟╠ ╡╢╣╤ ╥ ╦ ╧ ╨ ╩ ╳╔ ╗╝╚ ╬ ═ ╓ ╩ ┠ ┨┯ ┷┏ ┓┗ ┛┳ ⊥ ﹃ ﹄┌ ╮ ╭ ╯╰";
    
    NSString *nuberSym = @"0123456789";
    
    return [NSString stringWithFormat:@"%@%@%@%@%@%@",matSym,punSym,unitSym,curSym,tabSym,nuberSym];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 取消所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    [[NSUserDefaults standardUserDefaults]setObject:self.nameField.text forKey:@"nameTextField"];
    [[NSUserDefaults standardUserDefaults]setObject:self.cardField.text forKey:@"CardTextField"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
