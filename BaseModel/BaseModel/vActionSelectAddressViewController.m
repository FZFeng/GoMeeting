#import "vActionSelectAddressViewController.h"

#define  txtLoadingAdress        @"正在加载地址中..."
#define  txtSearchNothing        @"没有搜索到相关内容"
#define  txtSearchBarPlaceholder @"小区/写字楼/学校等"
#define  txtOpenLocationNote     @"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开"
#define  kGDMapApiKey            @"a3737a8532de22ff1def4cff7e8fcb90"


@implementation vActionSelectAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrySearchAddress=[[NSMutableArray alloc] init];
    arryMapAddress=[[NSMutableArray alloc] init];
    
    //tbMapAddress 注册自定义类型的cell
    UINib *cellNib = [UINib nibWithNibName:@"tbCellActionSelectAddress" bundle:nil];
    [tbMapAddress registerNib:cellNib forCellReuseIdentifier:@"tbCellActionSelectAddress"];
    //tbMapAddress 添加footer
    [self addTbFooter:tbMapAddress lblText:txtLoadingAdress];
    
    //关键字搜索
    mySearchBar =[[UISearchBar alloc] init];
    mySearchBar.delegate = self;
    mySearchBar.placeholder=txtSearchBarPlaceholder;
    //设置选项 tapcontrol
    //[searchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"First",@"Last",nil]];
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    navItemSearchBar.titleView=mySearchBar;
    
    //默认使用地图搜索地址
    bUseSearchBar=NO;
    
    //开启定位功能
    //第一步
    if (![CLLocationManager locationServicesEnabled]) {
        //NSLog(@"定位服务当前可能尚未打开，请在手机设置-隐私-定位服务中设置打开！");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:txtOpenLocationNote delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //定位管理器
    myLocationManager=[[CLLocationManager alloc]init];
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [myLocationManager requestWhenInUseAuthorization];
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
        
        mapAddress.delegate=self;
        
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        mapAddress.userTrackingMode=MKUserTrackingModeFollow;
        
        //设置地图类型
        mapAddress.mapType=MKMapTypeStandard;
        
        mapAddress.userInteractionEnabled=NO;
        
        
        //注册高德地图的Key(这里的key 要和 Bundle Identifier对应)
        [AMapSearchServices sharedServices].apiKey =kGDMapApiKey;
        
        //初始化高德地图的检索对象
        aMapSearch = [[AMapSearchAPI alloc] init];
        aMapSearch.delegate = self;
    }
}

//退出前选关闭键盘
-(void)viewWillDisappear:(BOOL)animated{
    if (bUseSearchBar) {
        [mySearchBar resignFirstResponder];
    }
}

#pragma mark 为tableview 添加footer
-(void)addTbFooter:(UITableView*)tbView lblText:(NSString*)plblText{
    tbView.tableFooterView=nil;
    
    UILabel *lblTbMapAddressFooter=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,tbView.frame.size.width, 35)];
    lblTbMapAddressFooter.text=plblText;
    lblTbMapAddressFooter.font=[UIFont systemFontOfSize:14];
    lblTbMapAddressFooter.textColor=[UIColor lightGrayColor];
    lblTbMapAddressFooter.textAlignment=NSTextAlignmentCenter;
    tbView.tableFooterView=lblTbMapAddressFooter;
}

#pragma mark UITableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (bUseSearchBar) {
        tbCellActionSelectAddressSearchBar *cell = (tbCellActionSelectAddressSearchBar*)[tbSearchAddress dequeueReusableCellWithIdentifier:@"tbCellActionSelectAddressSearchBar"];
        return CGRectGetHeight(cell.bounds);
    }else{
        tbCellActionSelectAddress *cell = (tbCellActionSelectAddress*)[tbMapAddress dequeueReusableCellWithIdentifier:@"tbCellActionSelectAddress"];
       return CGRectGetHeight(cell.bounds);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if (bUseSearchBar) {
        return [arrySearchAddress count];
    }else{
        return [arryMapAddress count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (bUseSearchBar) {
        tbCellActionSelectAddressSearchBar *cell = (tbCellActionSelectAddressSearchBar*)[tableView dequeueReusableCellWithIdentifier:@"tbCellActionSelectAddressSearchBar"];
        
        cell.lblAddressName.text=[[arrySearchAddress objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.lblAddressDetail.text=[[arrySearchAddress objectAtIndex:indexPath.row] objectForKey:@"address"];
        
        return cell;
    }else{
        tbCellActionSelectAddress *cell = (tbCellActionSelectAddress*)[tableView dequeueReusableCellWithIdentifier:@"tbCellActionSelectAddress"];
        
        cell.lblAddressName.text=[[arryMapAddress objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.lblAddressDetail.text=[[arryMapAddress objectAtIndex:indexPath.row] objectForKey:@"address"];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    vActionAddNewViewController *viewObject = [self.navigationController.viewControllers objectAtIndex:0];
    if (bUseSearchBar) {
        viewObject.sDetailPlace=[[arrySearchAddress objectAtIndex:indexPath.row] objectForKey:@"address"];
    }else{
        viewObject.sDetailPlace=[[arryMapAddress objectAtIndex:indexPath.row] objectForKey:@"address"];
    }
    
    [self.navigationController popToViewController:viewObject animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISearchBar Delegate
//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    mySearchBar.showsCancelButton = YES;
    
    if (!viewBgWhenInSearchBar) {
        viewBgWhenInSearchBar=[[UIView alloc] initWithFrame:CGRectMake(0, 64,self.view.frame.size.width, self.view.frame.size.height)];
        viewBgWhenInSearchBar.backgroundColor=[UIColor lightGrayColor];
        viewBgWhenInSearchBar.alpha=0.6;
        viewBgWhenInSearchBar.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
        [viewBgWhenInSearchBar addGestureRecognizer:singleTouch];
        [self.view addSubview:viewBgWhenInSearchBar];
    }else{
        viewBgWhenInSearchBar.hidden=NO;
    }
    
    NSArray *subViews;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        subViews = [(mySearchBar.subviews[0]) subviews];
    }
    else {
        subViews = mySearchBar.subviews;
    }
    
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
    

}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearch];
}

#pragma mark 所有txtfield的键盘消失
-(void)cancelSearch{
    bUseSearchBar=NO;
    
    [mySearchBar resignFirstResponder];
    mySearchBar.text=@"";
    mySearchBar.showsCancelButton =NO;
    
    viewBgWhenInSearchBar.hidden=YES;
    tbSearchAddress.hidden=YES;
    
    viewMapInfo.hidden=NO;
}

//键盘消失事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    mySearchBar.showsCancelButton =NO;
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    bUseSearchBar=YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if (![searchText isEqualToString:@""]) {
        
        
        if (!tbSearchAddress) {
            tbSearchAddress=[[UITableView alloc] initWithFrame:viewMapInfo.frame];
            tbSearchAddress.dataSource=nil;
            tbSearchAddress.delegate=self;
         
            [self addTbFooter:tbSearchAddress lblText:txtSearchNothing];
            [self.view addSubview:tbSearchAddress];
            
            //注册自定义类型的cell
            UINib *cellNib = [UINib nibWithNibName:@"tbCellActionSelectAddressSearchBar" bundle:nil];
            [tbSearchAddress registerNib:cellNib forCellReuseIdentifier:@"tbCellActionSelectAddressSearchBar"];

        }else{
            tbSearchAddress.hidden=NO;
        }
        
        //在searchbar搜索出的内容
        [self searchPoiByKeyword:searchText];
        
        viewBgWhenInSearchBar.hidden=YES;
        viewMapInfo.hidden=YES;
    }else{
        tbSearchAddress.dataSource=nil;
        [self addTbFooter:tbSearchAddress lblText:txtSearchNothing];
    }
}

#pragma mark 根据关键字来搜索POI.
- (void)searchPoiByKeyword:(NSString*)psKey
{
    if (!iWaittingHUD) {
        iWaittingHUD=[PublicFunc ShowWaittingHUD:txtLoadingAdress view:self.view];
    }
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords            = psKey;
    request.city                = sLocationCity;
    request.requireExtension    = YES;
    [aMapSearch AMapPOIKeywordsSearch:request];
}


#pragma mark 周边POI搜索
-(void)searchPOIWithLatitude:(CGFloat)platitude longitude:(CGFloat)plongitude{

    if (!iWaittingHUD) {
        iWaittingHUD=[PublicFunc ShowWaittingHUD:txtLoadingAdress view:self.view];
    }

    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest*request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:platitude longitude:plongitude];
    
    //request.keywords = @"方恒";
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    request.types = @"餐饮服务|商务住宅|生活服务";
    request.sortrule=0; //排序规则
    request.requireExtension = YES;
    
    mapAddress.userInteractionEnabled=NO;//防止request 未完成，又执行下一个request
    //发起周边搜索
    [aMapSearch AMapPOIAroundSearch: request];
    

}

#pragma mark 定位,地图,搜索地点 过程
// 地图控件代理方法
// 更新用户位置，只要用户改变则调用此方法（包括第一次定位到用户位置）
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
   
    if (imgCenterPoint.hidden==YES && mapAddress.userInteractionEnabled==NO) {
        imgCenterPoint.hidden=NO;
        
        //获取当前城市用于POI 指定城市搜索
        CLGeocoder *myGeocoder=[[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark=[placemarks firstObject];
            NSDictionary *dictAddress=placemark.addressDictionary;
            sLocationCity=[dictAddress objectForKey:@"City"];
            
            centerLocationCoordinate=userLocation.coordinate;
            
            mapAddress.userInteractionEnabled=YES;
        }];
    }
}

//Map移动 包括在第一次初始时 后执行
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (bUseSearchBar) return;
    
    if (mapAddress.userInteractionEnabled==YES ) {
        //移动后，当前的中心点
        CLLocationCoordinate2D centerCoordinate = mapView.region.center;
        //搜索poi
        [self searchPOIWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    }
}

//实现POI搜索对应的回调函数
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        //关闭等待提示
        mapAddress.userInteractionEnabled=YES;
        [PublicFunc HideHUD:iWaittingHUD];
        iWaittingHUD=nil;
        return;
    }
    
    if (bUseSearchBar) {
        [arrySearchAddress removeAllObjects];
        
        //通过AMapPlaceSearchResponse对象处理搜索结果
        for (AMapPOI *p in response.pois) {
            NSDictionary *dictResult=[[NSDictionary alloc] initWithObjectsAndKeys:p.name,@"name",p.address,@"address", nil];
            [arrySearchAddress addObject:dictResult];
        }
        tbSearchAddress.dataSource=self;
        tbSearchAddress.tableFooterView=nil;
        [tbSearchAddress reloadData];

    }else{
        
        [arryMapAddress removeAllObjects];
        
        //通过AMapPlaceSearchResponse对象处理搜索结果
        for (AMapPOI *p in response.pois) {
            NSDictionary *dictResult=[[NSDictionary alloc] initWithObjectsAndKeys:p.name,@"name",p.address,@"address", nil];
            [arryMapAddress addObject:dictResult];
        }
        tbMapAddress.dataSource=self;
        tbMapAddress.tableFooterView=nil;
        [tbMapAddress reloadData];
    }
    
    mapAddress.userInteractionEnabled=YES;
    
    //关闭等待提示
    [PublicFunc HideHUD:iWaittingHUD];
    iWaittingHUD=nil;
    
}

#pragma mark 回到原位置
- (IBAction)btnBackToCenterPointClick:(id)sender {
    //回到中心点
    [mapAddress setCenterCoordinate:centerLocationCoordinate animated:YES];
}
@end
