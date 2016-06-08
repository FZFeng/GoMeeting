//
//  AppDelegate.m
//  BaseModel
//
//  Created by apple on 15/8/24.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "AppDelegate.h"

#define sAppId           @"GKhb6bLyLcAYPRBZo2WOL3"
#define sAppKey          @"uA48f1KpOqArxVkSaJfCB9"
#define sAppSecret       @"BBHulohF1s9TTBQH9hZSjA"

#define  txtOpenLocationNote     @"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (![SystemPlist ExistSystemPlist]) {
        //建表本地表, 初始化系统全局信息
        [SystemPlist CreateSystemPlist];
        
        ClassAction *cActionObj=[[ClassAction alloc] init];
        [cActionObj createTable];
    }
    
    if (![SystemPlist GetLogin]) {
        //注册sharesdk 短信发送平台
        [OuterSDKManager RegisterSMSWithKey];
        
        //注册新浪微博sdk
        [OuterSDKManager RegisterSinaWbWithEnableDebugMode:NO];
    }
    
    //位置注册
    [self registerLocation];

    // 注册APNS推送
    [self registerUserNotification];
    
    //注册个推的推送功能
    // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:sAppId appKey:sAppKey appSecret:sAppSecret delegate:self];
    
    return YES;
}

#pragma mark 位置功能注册
-(void)registerLocation{
    //第一步
    if (![CLLocationManager locationServicesEnabled]) {
        //NSLog(@"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开！");
        [PublicFunc ShowSimpleMsg:txtOpenLocationNote];
    }
    
    //定位管理器
    myLocationManager=[[CLLocationManager alloc]init];
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [myLocationManager requestWhenInUseAuthorization];
    }

}

#pragma mark APP被“推送”启动时处理apns推送消息处理 (这情况是在app未启动的情况下)
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) return;
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfo) {
        // NSDictionary *dictValue=[userInfo objectForKey:@"aps"];
        //NSString *sApnsAlert=[dictValue objectForKey:@"alert"];
        //NSLog(@"%@",sApnsAlert);
    }
}

#pragma mark 推送(远程Apns)功能注册
- (void)registerUserNotification {
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else {      // iOS8.0 以前远程推送设置方式
        // 定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}


#pragma mark 注册并发送本地消息通知
// 设置本地通知
-(void)registerLocalNotification:(NSInteger)alertTime {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 通知内容
    notification.alertBody =  @"宅男,宅女们快动起来...";
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"都动起来,Enjoy 你的生活吧" forKey:@"key"];
    notification.userInfo = userDict;
    
    // 通知重复提示的单位，可以是天、周、月
    notification.repeatInterval = NSCalendarUnitDay;
    
    // 执行通知注册(按计划调度)
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //presentLocalNotificationNow立即调用通知
    //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark 移除本地通知，在不需要此通知时记得移除
-(void)removeNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark 本地消息处理
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{

    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
    NSString *notMess = [notification.userInfo objectForKey:@"key"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本地通知(前台)"
                                                    message:notMess
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    // 更新显示的徽章个数
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge--;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
}


#pragma mark - 用户通知(本地,远程Apns)回调 _IOS 8.0以上使用
/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
    
    if (notificationSettings.types!=UIUserNotificationTypeNone) {
        //注册本地通知
        //[self registerLocalNotification:2];
    }
}

#pragma mark - 远程Apns(推送)回调
//远程通知注册成功委托
//ps:注意在development开发模式下时 在真机或 simulator下删除app后 值会改变
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [GeTuiSdk registerDeviceToken:myToken];
}

//远程通知注册失败委托
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [GeTuiSdk registerDeviceToken:@""];
}

#pragma mark - 远程Apns(推送)处理
//APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) 旧方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;        // 标签
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息 ios7以后的方法 (App未启动/App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    application.applicationIconBadgeNumber = 0;        // 标签
    
    // 处理APN(这里要看服务器发送的json数据格式来解释数据)
    /*
    if (userInfo) {
        NSDictionary *dictValue=[userInfo objectForKey:@"aps"];
        NSString *sApnsAlert=[dictValue objectForKey:@"alert"];
        //app处理活动状态时才弹框
        if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
            [self showAlertWithMsg:sApnsAlert];
        }
    }*/
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark UIAlert delegate
-(void)showAlertWithMsg:(NSString*)sMsg{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:sMsg message:nil delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"立即查看", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        //查看活动页
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIViewController *receRemoteNotificationView=[navigationController.storyboard instantiateViewControllerWithIdentifier:@"UIViewReceRemoteNotification"];
        [navigationController pushViewController:receRemoteNotificationView animated:YES];
    }
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    //NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
   // NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调(socket技术处理) */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    
    // 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes length:payload.length encoding:NSUTF8StringEncoding];
        //app处理活动状态时才弹框
        if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
            [self showAlertWithMsg:payloadMsg];
        }
    }
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId];
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    //发送上行消息结果反馈
    //NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    //NSLog(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n",msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    //通知SDK运行状态
    //NSLog(@"\n>>>[GexinSdk SdkState]:%u\n\n",aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n",[error localizedDescription]);
        return;
    }
    //NSLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n",isModeOff?@"开启":@"关闭");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;        // 标签
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
   return  [OuterSDKManager handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
     return  [OuterSDKManager handleOpenURL:url];
}

@end
