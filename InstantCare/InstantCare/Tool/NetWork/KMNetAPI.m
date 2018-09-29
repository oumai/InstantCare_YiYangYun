 //
//  KMNetAPI.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/4.
//  Copyright © 2015年 omg. All rights reserved.
// 

#import "KMNetAPI.h"
#import "KMUserRegisterModel.h"
#import "AFNetworking.h"
#import "KMDeviceSettingModel.h"
#import "KMBundleDevicesModel.h"
#import "EXTScope.h"
#import "MJExtension.h"

#define kNetworkReqTimeout      10

@interface KMNetAPI()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) KMRequestResultBlock requestBlock;

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation KMNetAPI

+ (instancetype)manager
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableData data];
    }

    return self;
}

-(void)dealloc{
    NSLog(@"dealloc KMNETAPI %@",self);
}

- (void)postWithURL:(NSString *)url body:(NSString *)body block:(KMRequestResultBlock)block
{
    // debug
    DMLog(@"-> %@  %@", url, body);

    NSData *httpBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval = 60;
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:httpBody];
    
    self.requestBlock = block;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 *  获取设备列表
 *
 *  @param account 用户账号
 *  @param block   结果返回block
 */
- (void)getDevicesListWithAccount:(NSString *)account
                            Block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/getbindDeviceWithWearersInfo/%@?_type=json",
                     kServerAddress, account];
    DMLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
             if (self.requestBlock) {
                 self.requestBlock(0, jsonString);
             }
             self.requestBlock = nil;
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (self.requestBlock) {
                 self.requestBlock((int)error.code, nil);
             }
             self.requestBlock = nil;
         }];
}


- (void)getValWithIMEI:(NSString *)imei
                 Block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/getCheckSummary/%@?_type=json",
                     kServerAddress, imei];
    DMLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    __weak __typeof(self)weakSelf = self;
    
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
              __strong __typeof(weakSelf)strongSelf = weakSelf;
             
             NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
             if (strongSelf.requestBlock) {
                 strongSelf.requestBlock(0, jsonString);
             }
             self.requestBlock = nil;
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             if (strongSelf.requestBlock) {
                 strongSelf.requestBlock((int)error.code, nil);
             }
             strongSelf.requestBlock = nil;
         }];
}

/**
 *  获取打卡记录
 *
 *  @param imei  IMEI
 *  @param block 结果返回block
 */
- (void)getCheckRecordsWithIMEI:(NSString *)imei
                          Block:(KMRequestResultBlock)block {
    [self getRecodrsWithIMEI:imei Key:@"getCheckRecord" Block:block];
}

/**
 *  获取历史记录
 *
 *  @param imei  IMEI
 *  @param block
 */
- (void)getHisRecordsWithIMEI:(NSString *)imei
                        Block:(KMRequestResultBlock)block {
    [self getRecodrsWithIMEI:imei Key:@"getRegular" Block:block];
}

/**
 *  获取紧急救援记录
 *
 *  @param imei  IMEI
 *  @param block
 */
- (void)getEmgRecordsWithIMEI:(NSString *)imei
                  Block:(KMRequestResultBlock)block {
    [self getRecodrsWithIMEI:imei Key:@"getEmg" Block:block];
}

/**
 *  获取跌倒记录
 *
 *  @param imei  IMEI
 *  @param block
 */
- (void)getFallRecordsWithIMEI:(NSString *)imei
                         Block:(KMRequestResultBlock)block {
    [self getRecodrsWithIMEI:imei Key:@"getFall" Block:block];
}

- (void)getRecodrsWithIMEI:(NSString *)imei
                       Key:(NSString *)key
                     Block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@/0/10?_type=json",
                     kServerAddress, key, imei];
    DMLog(@"-> %@", url);
   AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    @weakify(self)
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @strongify(self)
           NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                         encoding:NSUTF8StringEncoding];
            DMLog(@"<- %@", jsonString);
            if (self.requestBlock) {
                self.requestBlock(0, jsonString);
            }
            self.requestBlock = nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             @strongify(self)
            if (self.requestBlock) {
                self.requestBlock((int)error.code, nil);
            }
            self.requestBlock = nil;
        }];
}

/**
 *  获取账号信息
 *
 *  @param account 注册的手机号
 *  @param block
 */
- (void)getAccountInfoWithAccount:(NSString *)account
                            Block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/accountInfo/%@?_type=json",
                     kServerAddress, account];
    DMLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    __weak __typeof(self)weakSelf = self;
    [manager GET:url parameters:nil  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                     encoding:NSUTF8StringEncoding];
        DMLog(@"<- %@", jsonString);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.requestBlock) {
            strongSelf.requestBlock(0, jsonString);
        }
        self.requestBlock = nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.requestBlock) {
            strongSelf.requestBlock((int)error.code, nil);
        }
        strongSelf.requestBlock = nil;
    }];
}


/**
 *  通用GET网络请求接口
 *
 *  @param keyURL  前面一部分
 *  @param block   结果
 */
- (void)commonGetRequestWithURL:(NSString *)keyURL
                          Block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    NSString * url;
    if ([keyURL containsString:@"?"]) {
        url  = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@&_type=json",
                kServerAddress, keyURL];
    }else if ([keyURL containsString:@"t9"]){
        url  = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@",
                kServerAddress, keyURL];
    }else{
        
      url  = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@?_type=json",
           kServerAddress, keyURL];
    }
    
    if ([url containsString:@"immediate"]) {
        url = [url stringByReplacingOccurrencesOfString:@"member/" withString:@""];
    }
    NSLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    // 防止URL中有非法字符
    NSString *realurl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    __weak __typeof(self)weakSelf = self;
    [manager GET:realurl  parameters:nil progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
            __strong __typeof(weakSelf)strongSelf = weakSelf;
             NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
             if (strongSelf.requestBlock) {
                 strongSelf.requestBlock(0, jsonString);
             }
             self.requestBlock = nil;
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             if (strongSelf.requestBlock) {
                 strongSelf.requestBlock((int)error.code, nil);
             }
             strongSelf.requestBlock = nil;
         }];
}
/**
 *  获取用户健康档案接口
 */
- (void)getUserHealthRecordWithUrl:(NSString *)urlString
                             block:(KMRequestResultBlock)block
{
    self.requestBlock = block;
    NSLog(@"%@",urlString);
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        if ([urlString containsString:@"examrecord"]) {
            self.requestBlock(1,nil);
        }
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString * url = [NSString stringWithFormat:@"http://120.25.225.5:8060/api/hlthrecord/%@",urlString];
    DMLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    __weak __typeof(self)weakSelf = self;
    [manager GET:url parameters:nil   progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
        
             if (strongSelf.requestBlock) {
                 
                 strongSelf.requestBlock(0, jsonString);
             }
        
             strongSelf.requestBlock = nil;
        
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             if (strongSelf.requestBlock) {
                 
                 strongSelf.requestBlock((int)error.code, nil);
             }
             strongSelf.requestBlock = nil;
         }];
}


/**
 *  更新用户信息
 *
 *  @param model   用户信息模型
 *  @param account 用户账号
 *  @param block
 */
- (void)updateAccountInfoWith:(KMPersonDetailModel *)model
                      account:(NSString *)account
                        block:(KMRequestResultBlock)block
{
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/accountInfo/%@", kServerAddress, account];
    
    [self postWithURL:url body:[model mj_JSONString] block:block];
}

- (void)commonPOSTRequestWithURL:(NSString *)keyURL
                        jsonBody:(NSString *)body
                           Block:(KMRequestResultBlock)block {
    
    NSString *url = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@", kServerAddress, keyURL];
    [self postWithURL:url body:body block:block];
}

- (void)updateUserHeaderWithIMEI:(NSString *)imei
                          header:(UIImage *)header
                           block:(KMRequestResultBlock)block {
    if (header) {
        NSData *jpg = UIImageJPEGRepresentation(header, 0.8);
        NSString *base64Encoded = [jpg base64EncodedStringWithOptions:0];

        KMPortraitModel *m = [KMPortraitModel new];
        m.portrait = base64Encoded;
        NSString *keyURL = [NSString stringWithFormat:@"portrait/%@/%@",
                            member.loginAccount,
                            imei];
        [[KMNetAPI manager] commonPOSTRequestWithURL:keyURL jsonBody:[m mj_JSONString] Block:block];
    }
}

/**
 *  检查iOS APP软件版本
 *
 *  @param appid APP在iTunes中ID
 *  @param block 结果
 */
- (void)checkVersionWithAPPID:(NSString *)appid
                        block:(KMRequestResultBlock)block {
    self.requestBlock = block;
    
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", appid];
    DMLog(@"-> %@", url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
    
    @weakify(self)
    [manager GET:url parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             @strongify(self)
             NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
             if (self.requestBlock) {
                 self.requestBlock(0, jsonString);
             }
             self.requestBlock = nil;
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              @strongify(self)
             if (self.requestBlock) {
                 self.requestBlock((int)error.code, nil);
             }
             self.requestBlock = nil;
         }];
}

#pragma mark - 连接成功
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)aResponse
{
    self.data.length = 0;
}

#pragma mark 存储数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incomingData
{
    [self.data appendData:incomingData];
}

#pragma mark 完成加载
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonData = [[NSString alloc] initWithData:self.data
                                               encoding:NSUTF8StringEncoding];

    // debug
    DMLog(@"<- %@", jsonData);

    if (self.requestBlock) {
        self.requestBlock(0, jsonData);
    }

    self.requestBlock = nil;
}

#pragma mark 连接错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.requestBlock) {
        self.requestBlock((int)error.code, nil);
    }

    self.requestBlock = nil;
}

#pragma mark - 重构代码

+ (instancetype)sharedInstance{
    static KMNetAPI* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)requestWithPath:(NSString*)path
          requestType:(RequestType)requestType
           parameters:(NSDictionary*)parameters
       successHandler:(void (^)(id data))success
       failureHandler:(void (^)(NSError *error))failure{
    
     DMLog(@"-> %@", path);
    
    if(requestType == RequestTypeGet){
        [self getRequestWithPath:path successHandler:success failureHandler:failure];
    }
}

-(void)getRequestWithPath:(NSString*)path
           successHandler:(void (^)(id data))success
           failureHandler:(void (^)(NSError *error))failure{
    
    // 监测网路状态；
    if ([KMMemberManager sharedInstance].netStatus < 1) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = kNetworkReqTimeout;
   
    [manager GET:path
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSString *jsonString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             DMLog(@"<- %@", jsonString);
             success(jsonString);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             failure(error);
         }];
}

@end


