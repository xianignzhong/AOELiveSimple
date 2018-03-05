//
//  ViewController.m
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import "ViewController.h"
#import "AOELiveKit.h"
#import <Masonry.h>

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface ViewController ()<AOELiveCaptureSessionDelegate,MTKViewDelegate,MTLCommandQueue,MTLTexture,MTLCommandBuffer>

@property (nonatomic, strong)AOELiveCaptureSession *captureSession;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

//GPUImage美颜
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView * filterView;

@property (nonatomic, strong) FSKGPUImageBeautyFilter * beauty;//美颜

//Metal
@property (nonatomic, strong) MTKView *metalView;
@property (nonatomic, assign) id<MTLCommandQueue> queue;
@property (nonatomic, assign) id<MTLTexture> texture;
@property (nonatomic, strong) MTKTextureLoader *tureLoader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.view insertSubview:self.filterView atIndex:0];
    
    [self aoe_setupFilter];

    [self aoe_setupLayouts];
    
//    [self.view addSubview:self.metalView];
//
//    self.queue = self.metalView.device.newCommandQueue;
    
    [AOELiveTool checkSupportLiveAuth:^(BOOL isSupport, AOELiveSupportLiveStatus status) {
       
        if (isSupport) {
            
            [self.captureSession startSessionRunning];
            
        }else{
            
            NSLog(@"不支持采集数据 %ld", (long)status);
        }
    }];
}

-(void)aoe_setupFilter{
    
    [self.videoCamera addTarget:self.beauty];
    self.beauty.beautyLevel = 0.5;
    self.beauty.toneLevel = 0.8;
    self.beauty.brightLevel = 0.4;
    
    [self.beauty addTarget:self.filterView];
}

-(void)aoe_setupLayouts{
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(self.view).mas_offset(UIEdgeInsetsZero);
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
    
    /**无效果
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
     */
    
    ///**滤镜 美颜等 GPUImage
    [self.videoCamera processVideoSampleBuffer:sampleBuffer];
     //*/
    
    /** 滤镜 美颜等 Matel
    // 这也是一种视频图像展示的方式, 但需要处理视频方向问题, 这里不做处理
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 转换为CIImage
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    // 转化为CGImageRef
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
//    [self.tureLoader newTextureWithCGImage:cgImage options:@{} error:nil];
     */
    
}

-(void)audioCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    //音频
}

#pragma mark - <MTKViewDelegate>
-(void)drawInMTKView:(MTKView *)view{
    
//    id<MTLCommandBuffer> buffer = self.queue.commandBuffer;
//    [buffer presentDrawable:view.currentDrawable];
//    [buffer commit];
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

-(GPUImageVideoCamera *)videoCamera{
    
    if (!_videoCamera) {
        
        _videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    
    return _videoCamera;
}

-(GPUImageView *)filterView{
    
    if (!_filterView) {
        
        _filterView = [[GPUImageView alloc]init];
    }
    
    return _filterView;
}

-(FSKGPUImageBeautyFilter *)beauty{
    
    if (!_beauty) {
        
        _beauty = [[FSKGPUImageBeautyFilter alloc]init];
    }
    
    return _beauty;
}

//Metal
-(MTKView *)metalView{
    
    if (!_metalView) {
        
        _metalView = [[MTKView alloc]initWithFrame:self.view.bounds device:MTLCreateSystemDefaultDevice()];
        _metalView.delegate = self;
        _metalView.framebufferOnly = NO;
    }
    
    return _metalView;
}

-(MTKTextureLoader *)tureLoader{
    
    if (!_tureLoader) {
        
        _tureLoader = [[MTKTextureLoader alloc]initWithDevice:self.metalView.device];
    }
    
    return _tureLoader;
}

@end
