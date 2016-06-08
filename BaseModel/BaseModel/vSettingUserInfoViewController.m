//
//  vSettingUserInfoViewController.m
//  BaseModel
//
//  Created by apple on 15/9/4.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vSettingUserInfoViewController.h"


@interface vSettingUserInfoViewController ()

@end

@implementation vSettingUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //头像
    if (![[SystemPlist GetHeadLogo] isEqualToString:@""]) {
        UIImage *img=[[UIImage alloc] initWithContentsOfFile:[SystemPlist GetHeadLogo]];
        [imgHeadLogo setImage:img];
    }
   
    //名称
    txtUserName.text=[SystemPlist GetName];
    
    //性别
    sGender=[SystemPlist GetGender];
    if ([sGender isEqualToString:@"m"]) {
        lblGender.text=@"性别: 男生";
    }else{
        lblGender.text=@"性别: 女生";
    }
    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];

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

-(void)viewDidLayoutSubviews{
    //圆角
    imgHeadLogo.layer.masksToBounds=YES;
    imgHeadLogo.layer.cornerRadius =imgHeadLogo.frame.size.height/2;
    imgHeadLogo.contentMode=UIViewContentModeScaleAspectFill;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}


#pragma mark 保存
- (IBAction)barBtnItemSaveUserInfoSettingClick:(id)sender {
    //关闭键盘
    [self disKeyboard];
    
    //保存信息到服务器
    ClassUser *cUserObject=[[ClassUser alloc] init];
    cUserObject.sID=[SystemPlist GetID];
    cUserObject.sName=txtUserName.text;
    cUserObject.sGender=sGender;
    
    if ([SystemPlist GetLoginType]==LoginTypeSystem) {
        NSDictionary *dictSelectImg=[[NSDictionary alloc] initWithObjectsAndKeys:dataSelectImg,[SystemPlist GetHeadLogoFileName], nil];
        [ClassUser upLoadUserDataWithObject:cUserObject fromDict:dictSelectImg fatherObject:self returnBlock:^(BOOL bReturnBlock) {
            if (bReturnBlock) {
                //保存头像到本地
                [SystemPlist SaveHeadLogoToLocalWithData:dataSelectImg];
                //保存名称
                [SystemPlist SetName:txtUserName.text];
                //保存性别
                [SystemPlist SetGender:sGender];
                
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
            }
        }];
    }else{
        //保存头像到本地
        [SystemPlist SaveHeadLogoToLocalWithData:dataSelectImg];
        //保存名称
        [SystemPlist SetName:txtUserName.text];
        //保存性别
        [SystemPlist SetGender:sGender];
        
        //提示成功
        [PublicFunc ShowSuccessHUD:nil view:self.view];
        
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
    }
}
-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma-mark 修改头像 并上传到服务器
- (IBAction)btnSetHeadLogoClick:(id)sender {
    
    UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:@"选择图片" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showPhotoLibrary];
    }];
    UIAlertAction *cameraDeviceRearAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCameraDeviceRear];
    }];
    
    [alertSelect addAction:cancelAction];
    [alertSelect addAction:photoLibraryAction];
    [alertSelect addAction:cameraDeviceRearAction];
    
    [self presentViewController:alertSelect animated:YES completion:nil];
    
}
//选中男生
- (IBAction)btnManClick:(id)sender {
    [self disKeyboard];
    lblGender.text=@"性别: 男生";
    sGender=@"m";
}
//选中女生
- (IBAction)btnWomanClick:(id)sender {
    [self disKeyboard];
    lblGender.text=@"性别: 女生";
    sGender=@"w";
}

//启动相册
-(void)showPhotoLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]==NO) {
        //提示要访问设备
        NSLog(@"设备相机功能不能启动");
        return;
    }
    
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing=YES;
    imagePicker.delegate=self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//启动相机
-(void)showCameraDeviceRear{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO) {
        //提示要访问设备
        NSLog(@"设备相机功能不能启动");
        return;
    }
    
    // 前面的摄像头是否可用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]==NO) {
        NSLog(@"前摄像头不可用");
        return;
    }
    
    // 后面的摄像头是否可用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]==NO) {
        NSLog(@"后摄像头不可用");
        return;
    }
    
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    
    //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.showsCameraControls  = YES;
    
    //设置闪光灯模式
    /*
     typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraFlashMode) {
     UIImagePickerControllerCameraFlashModeOff  = -1,
     UIImagePickerControllerCameraFlashModeAuto = 0,
     UIImagePickerControllerCameraFlashModeOn   = 1
     };
     */
    
    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    
    imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    //设置当拍照完或在相册选完照片后，是否跳到编辑模式进行图片剪裁。只有当showsCameraControls属性为true时才有效果
    imagePicker.allowsEditing = NO;
    imagePicker.delegate=self;
    
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

//UIImagePickerController 回调--取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//UIImagePickerController 回调--选中相片
/*
 NSString *const UIImagePickerControllerMediaType;         选取的类型 public.image  public.movie
 NSString *const UIImagePickerControllerOriginalImage;    修改前的UIImage object.
 NSString *const UIImagePickerControllerEditedImage;      修改后的UIImage object.
 NSString *const UIImagePickerControllerCropRect; 原始图片的尺寸NSValue object containing a CGRect data type
 NSString *const UIImagePickerControllerMediaURL;          视频在文件系统中 的 NSURL地址
 保存视频主要时通过获取其NSURL 然后转换成NSData
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //只是图片类型
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *getImage=nil;
        
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            getImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            getImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        NSData *getImageData;
        getImageData = [PublicFunc resetSizeOfImageData:getImage maxSize:100];
        
        //UIImagePNGRepresentation转换PNG格式的图片为二进制，如果图片的格式为JPEG则返回nil；
        /*
        if (UIImagePNGRepresentation(getImage) == nil) {
            sExtension=@".jpg";
            getImageData = UIImageJPEGRepresentation(getImage, 1);
        } else {
            sExtension=@".png";
            getImageData = UIImagePNGRepresentation(getImage);
        }*/
        
        dataSelectImg=getImageData;
        UIImage *img=[[UIImage alloc] initWithData:dataSelectImg];
        [imgHeadLogo setImage:img];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [txtUserName resignFirstResponder];
}
@end
