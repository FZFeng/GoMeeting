//
//  vActionDetailViewController.m
//  BaseModel
//
//  Created by apple on 15/10/20.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vActionDetailViewController.h"

#define  iNavigationBarHight 64
//#define  iImageHight 200
#define  iBtnH 35
#define  iexcursion  0.03
#define  fImageRatio 1.6
#define  iNumStrOfLine  20
#define  ilblActionDetailH 21
#define  fTabRowH 50.0
#define  iBrowseImgH 50
#define  iShowBtn -150

#define  sWaiting       @"正在处理中..."
#define  sErrorGetPlace @"获取当前地址失败"

@implementation vActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    iViewW=self.view.frame.size.width;
    iViewH=self.view.frame.size.height;
    
    //根据比例率算出imageView的高度
    iImageHeight=iViewW/fImageRatio;

    self.navigationItem.title = @"活动详情";
    
    imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, iNavigationBarHight, self.view.frame.size.width, iImageHeight)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;//重点（不设置那将只会被纵向拉伸）
    UIImage *image;
    if (_cActionData.bActionImageHasDownload) {
        image=[UIImage imageWithContentsOfFile:[_cActionData.arryActionImagePath objectAtIndex:1]];
        imgView.image=image;
    }else{
        //使用sdImage下载
        [imgView sd_setImageWithURL:[NSURL URLWithString:[_cActionData.arryActionImagePath firstObject]]];
    }
    [self.view addSubview:imgView];
    
    tbActionDetail=[[UITableView alloc] initWithFrame:CGRectMake(0, iNavigationBarHight, iViewW, iViewH) style:UITableViewStyleGrouped];
    tbActionDetail.contentInset = UIEdgeInsetsMake(iImageHeight,0,0, 0);
    tbActionDetail.backgroundColor=[UIColor clearColor];
    tbActionDetail.showsVerticalScrollIndicator=NO;
    tbActionDetail.delegate=self;
    tbActionDetail.dataSource=self;
    UIView *viewFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iViewW, iImageHeight-iNavigationBarHight)];
    tbActionDetail.tableFooterView=viewFooter;
    tbActionDetail.sectionFooterHeight=0.0;
    
    //去掉左边的空白
    if ([tbActionDetail respondsToSelector:@selector(setLayoutMargins:)]) {
        [tbActionDetail setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([tbActionDetail respondsToSelector:@selector(setSeparatorInset:)]) {
        [tbActionDetail setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    [self.view addSubview:tbActionDetail];
    
    btnJoinAction=[UIButton buttonWithType:UIButtonTypeCustom];
    btnJoinAction.frame=CGRectMake(0,iViewH,iViewW, iBtnH);
    [btnJoinAction setTitle:@"我要参加" forState:UIControlStateNormal];
    [btnJoinAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnJoinAction.backgroundColor=[UIColor orangeColor];
    btnJoinAction.titleLabel.font=[UIFont systemFontOfSize:15];
    [btnJoinAction addTarget:self action:@selector(btnJoinActionClick) forControlEvents:UIControlEventTouchUpInside];
    btnJoinAction.alpha=0.6;
    [self.view addSubview:btnJoinAction];
    
    //通过活动详细的string 计算UILable的高度
    sAction=_cActionData.sActionDescription;
    NSString *sNewLineAction=[self ReNewlineWithString:sAction iNumStringOfLine:iNumStrOfLine];
    NSInteger iLines=[sNewLineAction componentsSeparatedByString:@"\n"].count;
    if (iLines==1) {
        iActionDetailHeight=fTabRowH;
    }else{
        iActionDetailHeight=iLines*ilblActionDetailH;
    }
    
    arryActionInfo=[[NSMutableArray alloc] init];
    //活动日期
    [arryActionInfo addObject:[NSString stringWithFormat:@"活动日期:%@",_cActionData.sActionDate]];
    
    //人数,费用
    [arryActionInfo addObject:[NSString stringWithFormat:@"%@      %@",_cActionData.sActionManNum,_cActionData.sActionCharge]];
    
    //活动地点
    [arryActionInfo addObject:_cActionData.sActionPlace];
    sActionPlace=_cActionData.sActionPlace;
    
    //联系电话
    [arryActionInfo addObject:_cActionData.sActionContactPhone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat y = scrollView.contentOffset.y;//根据实际选择加不加上NavigationBarHight（44、64 或者没有导航条）
    if (y < -iImageHeight) {
        CGRect frame = imgView.frame;
        frame.origin.y = iNavigationBarHight;
        frame.size.height =  -y;
        imgView.frame = frame;
    }else{
        if (y<0.0) {
            CGRect frame = imgView.frame;
            frame.size.height =  -y;
            imgView.frame = frame;
        }
    }
    if(!bShowBtn) {
        bShowBtn=YES;
        [self showButton];
    }
}

//拉完后的状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //下拉超过iBrowseImgH偏移值时浏览图片
    if (scrollView.contentOffset.y<-(iImageHeight+iBrowseImgH)) {
        vActionImgBrowseViewController *actionImgBrowse=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewActionImgBrowse"];
        actionImgBrowse.bActionImageHasDownload=_cActionData.bActionImageHasDownload;
        if (_cActionData.bActionImageHasDownload){
            //不显示第一张封面图
            NSMutableArray *arryPath=[[NSMutableArray alloc] init];
            for (int i=1; i<=_cActionData.arryActionImagePath.count-1; i++) {
                [arryPath addObject:[_cActionData.arryActionImagePath objectAtIndex:i]];
            }
            actionImgBrowse.arryActionImagePath=arryPath;
        }else{
            actionImgBrowse.arryActionImagePath=_cActionData.arryActionImagePath;
        }
        
        [self presentViewController:actionImgBrowse animated:YES completion:nil];
    }
}

#pragma mark 定位(获取当前位置用于导航地址)
-(void)startNav{

    //第一步
    if (![CLLocationManager locationServicesEnabled]) {
        //NSLog(@"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开！");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:self.view];
    
    float fSystemVersion=[[[UIDevice currentDevice] systemVersion] floatValue];
    
    //定位管理器
    myLocationManager=[[CLLocationManager alloc]init];
    
    //ios7
    if ( fSystemVersion>6.0 && fSystemVersion<8.0){
        
        //设置代理
        myLocationManager.delegate=self;
        //设置定位精度
        myLocationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=10.0;//十米定位一次
        myLocationManager.distanceFilter=distance;
        //启动跟踪定位(调用这个方法，提示是否允许授权定位服务) 可以在plist中配置Privacy - Location Usage Description自定义提示内容
        [myLocationManager startUpdatingLocation];
        
    }else if (fSystemVersion>=8.0){
        //ios 8
        //第二步 在此之前请在plist中设置NSLocationAlwaysUsageDescription 总是打开
        //或者 NSLocationWhenInUseUsageDescription 使用时才打开
        
        //如果没有授权则请求用户授权
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
            //[myLocationManager requestWhenInUseAuthorization];
            [myLocationManager requestAlwaysAuthorization];
        }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
            //定位管理器
            myLocationManager=[[CLLocationManager alloc]init];
            //设置代理
            myLocationManager.delegate=self;
            //设置定位精度
            myLocationManager.desiredAccuracy=kCLLocationAccuracyBest;
            //定位频率,每隔多少米定位一次
            CLLocationDistance distance=10.0;//十米定位一次
            myLocationManager.distanceFilter=distance;
            //启动跟踪定位
            [myLocationManager startUpdatingLocation];
        }
    }
}

//跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location=[locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    //如果不需要实时定位，使用完即使关闭定位服务
    [myLocationManager stopUpdatingLocation];
    
    [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
}

//根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    CLGeocoder *myGeocoder=[[CLGeocoder alloc] init];
    [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSDictionary *addressDic= placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
        NSString *slocalPlace=[addressDic objectForKey:@"Thoroughfare"];
        NSString *sCity=[addressDic objectForKey:@"City"];
        if (slocalPlace) {
            [self navfrom:[addressDic objectForKey:@"Thoroughfare"] sToPlace:[sCity stringByAppendingString:sActionPlace]];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //关闭提示
                [PublicFunc HideHUD:showHUD];
                [PublicFunc ShowErrorHUD:sErrorGetPlace view:self.view];
            }];
        }
    }];
}

//异航
-(void)navfrom:(NSString*)sFromPlace sToPlace:(NSString*)sToPlace{
    //地址
    CLGeocoder *_geocoder=[[CLGeocoder alloc]init];
    
    //根据“北京市”地理编码
    [_geocoder geocodeAddressString:sFromPlace completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *clPlacemark1=[placemarks firstObject];//获取第一个地标
        MKPlacemark *mkPlacemark1=[[MKPlacemark alloc]initWithPlacemark:clPlacemark1];
        
        //注意地理编码一次只能定位到一个位置，不能同时定位，所在放到第一个位置定位完成回调函数中再次定位
        [_geocoder geocodeAddressString:sToPlace completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *clPlacemark2=[placemarks firstObject];//获取第一个地标
            MKPlacemark *mkPlacemark2=[[MKPlacemark alloc]initWithPlacemark:clPlacemark2];
            NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
            //MKMapItem *mapItem1=[MKMapItem mapItemForCurrentLocation];//当前位置
            MKMapItem *mapItem1=[[MKMapItem alloc]initWithPlacemark:mkPlacemark1];
            MKMapItem *mapItem2=[[MKMapItem alloc]initWithPlacemark:mkPlacemark2];
            [MKMapItem openMapsWithItems:@[mapItem1,mapItem2] launchOptions:options];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //关闭提示
                [PublicFunc HideHUD:showHUD];
            }];
        }];
        
    }];
}


#pragma mark UITableview Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        if (indexPath.row==2) {
            //导航
            [self startNav];
        }else if (indexPath.row==3){
            //电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", [arryActionInfo objectAtIndex:indexPath.row]]]];
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return 1;
            break;
        }case 1:{
            return arryActionInfo.count;
            break;
        }
        default:{
            return 1;
            break;
        }
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    if (section==0) {
        UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, fTabRowH)];
        customView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        
        UILabel *lblSectionActionTitle=[[UILabel alloc] initWithFrame:customView.frame];
        lblSectionActionTitle.text=_cActionData.sActionTitle;
        lblSectionActionTitle.textAlignment=NSTextAlignmentCenter;
        lblSectionActionTitle.font=[UIFont systemFontOfSize:20];
        lblSectionActionTitle.textColor=[UIColor grayColor];
        lblSectionActionTitle.backgroundColor=[UIColor clearColor];
        [customView addSubview:lblSectionActionTitle];
        return customView;
    }else{
        UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        customView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        
        UILabel *lblSectionActionTitle=[[UILabel alloc] initWithFrame:customView.frame];
        lblSectionActionTitle.textColor=[UIColor grayColor];
        lblSectionActionTitle.backgroundColor=[UIColor clearColor];
        [customView addSubview:lblSectionActionTitle];
        
         return customView;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return iActionDetailHeight;
    }else{
    
        return fTabRowH;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return fTabRowH;
    }else{
        return 15.0;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (cell) {
        switch (indexPath.section) {
            case 0:{
                
                UILabel *lblActionDetail=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iViewW, iActionDetailHeight)];
                lblActionDetail.textAlignment=NSTextAlignmentCenter;
                lblActionDetail.numberOfLines=0;
                lblActionDetail.text=[self ReNewlineWithString:sAction iNumStringOfLine:iNumStrOfLine];
                lblActionDetail.font= [UIFont systemFontOfSize:15];
                lblActionDetail.textColor=[UIColor grayColor];
                //lblActionDetail.backgroundColor=[UIColor redColor];
                [cell.contentView addSubview:lblActionDetail];
                
                break;
            }case 1:{
                UILabel *lblActionInfo=[[UILabel alloc] initWithFrame:CGRectMake(15, 5, iViewW-30, fTabRowH-10)];
                lblActionInfo.textAlignment=NSTextAlignmentCenter;
                lblActionInfo.numberOfLines=0;
                lblActionInfo.text=[arryActionInfo objectAtIndex:indexPath.row];
                lblActionInfo.font= [UIFont systemFontOfSize:15];
                lblActionInfo.textColor=[UIColor grayColor];
                
                //地图
                if (indexPath.row==2) {
                    int iImgW=10,iImgH=15;
                    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(15,(fTabRowH-iImgH)/2, iImgW, iImgH)];
                    img.image=[UIImage imageNamed:@"imgCenterPoint"];
                    [cell.contentView addSubview:img];
                }else if (indexPath.row==3){
                    int iImgW=15,iImgH=15;
                    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(15,(fTabRowH-iImgH)/2, iImgW, iImgH)];
                    img.image=[UIImage imageNamed:@"phone"];
                    [cell.contentView addSubview:img];
                }
                
                [cell.contentView addSubview:lblActionInfo];
                break;
            }
            default:{
                return nil;
                break;
            }
        }

    }
    return cell;
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
}

#pragma mark 向上滑动才出现的"参加活动"按钮
- (void)showButton{
    
    btnJoinAction.alpha = 0;
    
    [UIView animateWithDuration:0.75f animations:^{
        btnJoinAction.frame=CGRectMake(0,iViewH-iBtnH,iViewW, iBtnH);
        btnJoinAction.alpha =0.6;
    } ];
}

-(void)hideButton{
    btnJoinAction.alpha = 0.6;
    
    [UIView animateWithDuration:0.75f animations:^{
        btnJoinAction.frame=CGRectMake(0,iViewH,iViewW, iBtnH);
        btnJoinAction.alpha =0.0;
    } ];


}

#pragma mark  参加活动
-(void)btnJoinActionClick{
    //判断是否登陆
    BOOL bLogin=[SystemPlist GetLogin];
    if (!bLogin) {
        UINavigationController *navObject=[self.storyboard instantiateViewControllerWithIdentifier:@"UINavUserLoad"];
        ;
        [self presentViewController:navObject animated:YES completion:nil];
        return;
    }
    
    //如果是第三方登陆要输入联系方式
    if ([SystemPlist GetLoginType]==LoginTypeSdk) {
        [self addContactPhone];
        return;
    }
    
    [self joinAction];
}

-(void)joinAction{
    ClassActionJoinor *cActionJoinorObject=[[ClassActionJoinor alloc] init];
    [cActionJoinorObject joinAction:[_cActionData.sActionID intValue] sContactPhone:_cActionData.sActionContactPhone sRemark:@"" fatherObject:self returnBlock:^(BOOL bReturnBlock) {
        if (!bReturnBlock) {
            [self hideButton];
        }else{
            [self performSelector:@selector(popView) withObject:nil afterDelay:1.0];
        }
    }];
}
//延时关闭窗体
-(void)popView{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//第三方登陆增加联系手机号
-(void)addContactPhone{
    

    viewAddContactPhone=[[UIView alloc] initWithFrame:self.view.frame];
    viewAddContactPhone.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
    [self.view addSubview:viewAddContactPhone];
    
    //点击空白关闭
    UIButton *btnBg=[[UIButton alloc] initWithFrame:viewAddContactPhone.frame];
    [btnBg addTarget:self action:@selector(hideContactPhone) forControlEvents:UIControlEventTouchUpInside];
    [viewAddContactPhone addSubview:btnBg];
    
    int iH=115;
    int iControlH=30;
    int iGap=5;
    viewAddContactPhoneInfo=[[UIView alloc] initWithFrame:CGRectMake(0, (iViewH-iH)/2, iViewH, iH)];
    viewAddContactPhoneInfo.backgroundColor=[UIColor whiteColor];
    [viewAddContactPhone addSubview:viewAddContactPhoneInfo];
    
    fztxtContactPhone=[[FZTextField alloc] initWithFrame:CGRectMake(iGap, iGap, iViewW-iGap*2, iControlH)];
    fztxtContactPhone.placeholderText=@"联系手机号";
    fztxtContactPhone.bNoLeftIcon=YES;
    fztxtContactPhone.iLblLeftWidth=55;
    fztxtContactPhone.lblLeftText=@"手机号";
    [viewAddContactPhoneInfo addSubview:fztxtContactPhone];
    
    lblContactPhoneNote=[[UILabel alloc] initWithFrame:CGRectMake(iGap, iGap*2+iControlH, iViewW-iGap*2, iControlH)];
    lblContactPhoneNote.backgroundColor=[UIColor clearColor];
    lblContactPhoneNote.font=[UIFont systemFontOfSize:15];
    lblContactPhoneNote.textColor=[UIColor grayColor];
    lblContactPhoneNote.textAlignment=NSTextAlignmentCenter;
    [viewAddContactPhoneInfo addSubview:lblContactPhoneNote];
    
    btnContactPhone=[[UIButton alloc] initWithFrame:CGRectMake(iGap, iGap*3+iControlH*2, iViewW-iGap*2, iControlH)];
    [btnContactPhone setTitle:@"我要参加" forState:UIControlStateNormal];
    [btnContactPhone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnContactPhone.backgroundColor=[UIColor orangeColor];
    btnContactPhone.titleLabel.font=[UIFont systemFontOfSize:15];
    [btnContactPhone addTarget:self action:@selector(checkContactPhone) forControlEvents:UIControlEventTouchUpInside];
    btnContactPhone.alpha=0.6;
    [viewAddContactPhoneInfo addSubview:btnContactPhone];
}
-(void)checkContactPhone{
    if (fztxtContactPhone.text.length!=11) {
        lblContactPhoneNote.text=@"请输入11位手机号";
        return;
    }
    [self joinAction];
}

-(void)hideContactPhone{
    [viewAddContactPhone removeFromSuperview];
}


#pragma mark 处理活动详细的字符串 转成段落字符串
//输入一个字符串，可换成有换行的字符串
//sString:输入的字符串
//iNumStringOfLine:规定每行多少个字符
-(NSString*)ReNewlineWithString:(NSString*)sString iNumStringOfLine:(int)iNumStringOfLine{
    NSString *sStr=@"";
    
    int iLine=0;
    for (int i=1; i<=sString.length; i++) {
        if (iLine==i/iNumStringOfLine) {
            sStr=[sStr stringByAppendingString:[sString substringWithRange:NSMakeRange(i-1, 1)]];
        }else{
            iLine=i/iNumStringOfLine;
            sStr=[sStr stringByAppendingFormat:@"%@\n",[sString substringWithRange:NSMakeRange(i-1, 1)]];
        }
    }
    return sStr;
}


@end
