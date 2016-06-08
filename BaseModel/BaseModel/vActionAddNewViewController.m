#import "vActionAddNewViewController.h"
#define  sPersionLimit  @"限人数"
#define  sPersionUnLimit  @"不限"

#define  sChargeFree    @"免费"
#define  sChargeUnFree  @"人均"
#define  sTxtImageAddNew @"添加图片+"

#define  iMaxImgNum 4 //可选的最大相片数量

#define iBtnImageAddNew1Tag 100
#define iBtnImageDelete1Tag 200

#define iNumImageControl 4

@implementation vActionAddNewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fztxtDetailTitle.placeholderText=@"填写活动主题";
    fztxtDetailTitle.bNoLeftIcon=YES;
    fztxtDetailTitle.bNoLeftLable=YES;
    fztxtDetailTitle.delegate=self;
    
    fztxtDetailPersion.placeholderText=@"人数";
    fztxtDetailPersion.bNoLeftIcon=YES;
    fztxtDetailPersion.bNoLeftLable=YES;
    fztxtDetailPersion.delegate=self;
    
    fztxtDetailCharge.placeholderText=@"费用";
    fztxtDetailCharge.bNoLeftIcon=YES;
    fztxtDetailCharge.bNoLeftLable=YES;
    fztxtDetailCharge.delegate=self;
    
    fztxtDetailPhone.placeholderText=@"填写联系电话";
    fztxtDetailPhone.bNoLeftIcon=YES;
    fztxtDetailPhone.bNoLeftLable=YES;
    fztxtDetailPhone.delegate=self;

    
    txtTDetailExplain.delegate=self;
    
    //圆角
    btnDetailDate.layer.cornerRadius =5.0;
    btnDetailPlace.layer.cornerRadius =5.0;
    btnDetailPersion.layer.cornerRadius =5.0;
    btnDetailCharge.layer.cornerRadius =5.0;
    txtTDetailExplain.layer.cornerRadius=5.0;
    
    btnImageAddNew1.tag=iBtnImageAddNew1Tag;
    btnImageAddNew2.tag=iBtnImageAddNew1Tag+1;
    btnImageAddNew3.tag=iBtnImageAddNew1Tag+2;
    btnImageAddNew4.tag=iBtnImageAddNew1Tag+3;
    
    [btnImageAddNew1.layer setBorderWidth:0.5];
    [btnImageAddNew1.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    
    btnImageDelete1.tag=iBtnImageDelete1Tag;
    btnImageDelete2.tag=iBtnImageDelete1Tag+1;
    btnImageDelete3.tag=iBtnImageDelete1Tag+2;
    btnImageDelete4.tag=iBtnImageDelete1Tag+3;
    
    arrySelectImg=[[NSMutableArray alloc] init];
    sDetailDate=@"";
    _sDetailPlace=@"";
    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];
    
}

//此方法会多次调用
-(void)viewDidLayoutSubviews{
    //设置删除图片的圆角
    for (int i=0; i<=iNumImageControl-1; i++) {
        UIButton *btnObject=(UIButton*)[self.view viewWithTag:(iBtnImageDelete1Tag+i)];
        btnObject.layer.masksToBounds=YES;
        btnObject.layer.cornerRadius =btnObject.frame.size.height/2;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (_sDetailPlace && _sDetailPlace.length>0) {
        [btnDetailPlace setTitle:_sDetailPlace forState:UIControlStateNormal];
        [btnDetailPlace setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
}

#pragma mark 关闭
- (IBAction)btnCancelClick:(id)sender {
    [self disKeyboard];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"确定要放弃?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [fztxtDetailTitle resignFirstResponder];
    [fztxtDetailPersion resignFirstResponder];
    [txtTDetailExplain resignFirstResponder];
    [fztxtDetailCharge resignFirstResponder];
    [fztxtDetailPhone resignFirstResponder];
}

#pragma mark UIAlertView 回调
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UITextView  回调
//键盘消失事件
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移100个单位，按实际情况设置
    float fScreenHeight=[[UIScreen mainScreen] bounds].size.height;
    int iRect=-60;
    if (fScreenHeight==480) {
        iRect=-140;
    }
    CGRect rect=CGRectMake(0,iRect,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移100个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,0.0f,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}


#pragma mark 发布
- (IBAction)btnSaveActionClick:(id)sender {
    [self disKeyboard];
    
    //验证信息输入的有效性
    if (!noticeView) {
        noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:YES];
    }
    if (fztxtDetailTitle.text.length==0) {
        [noticeView showWithNotice:@"请输入 活动主题!"];
    }else if ([sDetailDate isEqualToString:@""]){
        [noticeView showWithNotice:@"请输入 活动日期!"];
    }else if ([_sDetailPlace isEqualToString:@""]){
        [noticeView showWithNotice:@"请输入 活动地点!"];
    }else if (fztxtDetailPersion.hidden==NO && fztxtDetailPersion.text.length==0){
        [noticeView showWithNotice:@"请输入 限定人数!"];
    }else if (fztxtDetailCharge.hidden==NO && fztxtDetailCharge.text.length==0){
        [noticeView showWithNotice:@"请输入 费用!"];
    }else if (fztxtDetailPhone.text.length<11 || fztxtDetailPhone.text.length==0){
        [noticeView showWithNotice:@"请输入 用效联系电话!"];
    }else if(txtTDetailExplain.text.length==0){
        [noticeView showWithNotice:@"请输入 活动描述!"];
    }else if(arrySelectImg.count==0){
        [noticeView showWithNotice:@"至少选择一张活动图片!"];
    }else{
        
        ClassAction *cActionObj=[[ClassAction alloc] init];
        cActionObj.sActionTitle=fztxtDetailTitle.text;
        cActionObj.sActionDate=btnDetailDate.titleLabel.text;
        cActionObj.sActionPlace=_sDetailPlace;
        //免费情况下设置为-1
        if (fztxtDetailPersion.hidden==YES) {
            cActionObj.sActionManNum=@"-1";
        }else{
            cActionObj.sActionManNum=fztxtDetailPersion.text;
        }
        
        if (fztxtDetailCharge.hidden==YES) {
            cActionObj.sActionCharge=@"0.0";
        }else{
            cActionObj.sActionCharge=fztxtDetailCharge.text;
        }
        cActionObj.sActionContactPhone=fztxtDetailPhone.text;
        cActionObj.sActionDescription=txtTDetailExplain.text;
        
        [cActionObj issueAction:cActionObj issueImages:arrySelectImg fatherObject:self returnBlock:^(BOOL bReturnBlock) {
            if (bReturnBlock) [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
        }];
    }
}

-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 限人数
- (IBAction)btnDetailPersionClick:(id)sender {
    if ([btnDetailPersion.titleLabel.text isEqualToString:sPersionUnLimit]) {
        [btnDetailPersion setTitle:sPersionLimit forState:UIControlStateNormal];
        [btnDetailPersion setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        fztxtDetailPersion.hidden=NO;
    }else{
        [btnDetailPersion setTitle:sPersionUnLimit forState:UIControlStateNormal];
        [btnDetailPersion setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        fztxtDetailPersion.hidden=YES;
    }
}

#pragma mark 收费
- (IBAction)btnDetailChargeClick:(id)sender {
    if ([btnDetailCharge.titleLabel.text isEqualToString:sChargeFree]) {
        [btnDetailCharge setTitle:sChargeUnFree forState:UIControlStateNormal];
        [btnDetailCharge setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        fztxtDetailCharge.hidden=NO;
    }else{
        [btnDetailCharge setTitle:sChargeFree forState:UIControlStateNormal];
        [btnDetailCharge setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        fztxtDetailCharge.hidden=YES;
    }
}

#pragma mark 增加活动图片
- (IBAction)btnAddImgClick:(id)sender{
    [self disKeyboard];
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = iMaxImgNum-arrySelectImg.count;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark 删除活动图片
- (IBAction)btnDelImgClick:(id)sender {
    //删除arrySelectImg跌内容
    UIButton *btnDelImgObject=sender;
    NSInteger iGetIndex=btnDelImgObject.tag-iBtnImageDelete1Tag;
    [arrySelectImg removeObjectAtIndex:iGetIndex];
    [self updateSelectedImage];
}

#pragma mark 选择日期
- (IBAction)btnDetailDateClick:(id)sender {
    [self disKeyboard];
    FZDatePickerView *datePickerView=[[FZDatePickerView alloc] initWithReferView:self.view];
    datePickerView.delegate=self;
    [datePickerView show];
}
//返回内容
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate{
    sDetailDate=psReturnDate;
    [btnDetailDate setTitle:sDetailDate forState:UIControlStateNormal];
    [btnDetailDate setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
}


#pragma mark 返回的相片信息
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    if (assets.count>0) {
        
        for (int i=0; i<assets.count; i++) {
            ALAsset *asset=assets[i];
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            
            [arrySelectImg addObject:tempImg];
        }
        
        if (arrySelectImg.count>0) {
            [self updateSelectedImage];
        }
    }
}

#pragma mark 更新当前选中图片信息
-(void)updateSelectedImage{
    
    //还原控件状态
    for (int i=0; i<=iNumImageControl-1; i++) {
        UIButton *btnAddNewImgObject=(UIButton*)[self.view viewWithTag:(iBtnImageAddNew1Tag+i)];
        btnAddNewImgObject.hidden=YES;
        btnAddNewImgObject.userInteractionEnabled=YES;//禁用点击 效果比enable好
        [btnAddNewImgObject setTitle:sTxtImageAddNew forState:UIControlStateNormal];
        [btnAddNewImgObject setBackgroundImage:nil forState:UIControlStateNormal];
        UIButton *btnDelImgObject=(UIButton*)[self.view viewWithTag:(iBtnImageDelete1Tag+i)];
        btnDelImgObject.hidden=YES;
    }
    if (arrySelectImg.count>0) {
        for ( int i=0; i<=arrySelectImg.count-1; i++) {
            UIButton *btnAddNewImgObject=(UIButton*)[self.view viewWithTag:(iBtnImageAddNew1Tag+i)];
            btnAddNewImgObject.hidden=NO;
            btnAddNewImgObject.userInteractionEnabled=NO;//禁用点击 效果比enable好
            [btnAddNewImgObject setTitle:@"" forState:UIControlStateNormal];
            [btnAddNewImgObject setBackgroundImage:[arrySelectImg objectAtIndex:i] forState:UIControlStateNormal];
            UIButton *btnDelImgObject=(UIButton*)[self.view viewWithTag:(iBtnImageDelete1Tag+i)];
            btnDelImgObject.hidden=NO;
        }
    }
    //还能增加图片的button
    if (arrySelectImg.count<iMaxImgNum) {
        UIButton *btnAddNewImgObject=(UIButton*)[self.view viewWithTag:(iBtnImageAddNew1Tag+arrySelectImg.count)];
        btnAddNewImgObject.hidden=NO;
        [btnAddNewImgObject.layer setBorderWidth:0.5];
        [btnAddNewImgObject.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueSelectAddress"]) {
        [self disKeyboard];
    }
}


@end
