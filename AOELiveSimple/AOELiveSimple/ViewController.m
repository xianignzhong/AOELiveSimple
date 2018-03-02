//
//  ViewController.m
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import "ViewController.h"
#import "AOELiveKit.h"

@interface ViewController ()<AOELiveCaptureSessionDelegate>

@property (nonatomic, strong)AOELiveCaptureSession *captureSession;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [AOELiveTool checkSupportLiveAuth:^(BOOL isSupport, AOELiveSupportLiveStatus status) {
       
        if (isSupport) {
            
            [self.captureSession startSessionRunning];
            
        }else{
            
            NSLog(@"不支持采集数据 %ld", (long)status);
        }
    }];
}

- (IBAction)change:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        // 转换至后置摄像头
        self.captureSession.cameraPosition = AOELiveCameraPositionBack;
    } else {
        // 转换至前置摄像头
        self.captureSession.cameraPosition = AOELiveCameraPositionFornt;
    }
}


#pragma mark - <AOELiveCaptureSessionDelegate>
-(void)videoCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    // 这也是一种视频图像展示的方式, 但需要处理视频方向问题, 这里不做处理
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 转换为CIImage
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    // 转换UIImage
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    
    
    
    // 回到主线程更新UI
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.imageView.image = image;
    }); 
}

-(void)audioCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    //音频
}

-(void)dealloc{
    
    NSLog(@"内存释放");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter/getter
-(AOELiveCaptureSession *)captureSession{
    
    if (!_captureSession) {
        
        _captureSession = [[AOELiveCaptureSession alloc]initLiveCaptureSession:AOELiveCaptureSessionPreset1280x720];
        _captureSession.delegate = self;
    }
    
    return _captureSession;
}

@end
