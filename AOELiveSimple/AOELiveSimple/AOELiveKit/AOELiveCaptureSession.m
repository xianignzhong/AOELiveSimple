//
//  AOELiveCaptureSession.m
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import "AOELiveCaptureSession.h"

@interface AOELiveCaptureSession ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong)AVCaptureSession *session; //音视频管理对象

@property (nonatomic, strong)AVCaptureDevice *videoDevice; //视频设备对象
@property (nonatomic, strong)AVCaptureDevice *audioDevice; //音频设备对象

@property (nonatomic, strong)AVCaptureDeviceInput *videoInput; //视频输入对象
@property (nonatomic, strong)AVCaptureDeviceInput *audioInput; //音频输入对象

@property (nonatomic, strong)AVCaptureVideoDataOutput *videoOutput; //视频输出对象
@property (nonatomic, strong)AVCaptureAudioDataOutput *audioOutput; //音频输出对象

@property (nonatomic, assign)AOELiveCaptureSessionPreset sessionPreset;//采集分辨率
@property (nonatomic, strong)NSString * sdkPreset;//转化SDK采集分辨率

@end

@implementation AOELiveCaptureSession

-(instancetype)initLiveCaptureSession:(AOELiveCaptureSessionPreset)preset{
    
    self = [super init];
    if (self) {
        
        self.sessionPreset = preset;
        [self captureSessionSet];
    }
    
    return self;
}

-(void)startSessionRunning{
    
    [self.session startRunning];
}

-(void)stopSessionRunning{
    
    [self.session stopRunning];
}

-(void)setCameraPosition:(AOELiveCameraPosition)cameraPosition{
    
    if (_cameraPosition != cameraPosition) {
        
        _cameraPosition = cameraPosition;
        if (_cameraPosition == AOELiveCameraPositionFornt) {
            self.videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        } else {
            self.videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        }
        
        //更改session属性 安全操作
        [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
            NSError *error;
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
            
            if (newVideoInput != nil) {
                //必选先 remove 才能询问 canAdd
                [self.session removeInput:_videoInput];
                if ([self.session canAddInput:newVideoInput]) {
                    [self.session addInput:newVideoInput];
                    _videoInput = newVideoInput;
                }else{
                    [self.session addInput:_videoInput];
                }
            } else if (error) {
                
                NSAssert(error, error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Private
-(void)captureSessionSet{
    
    //设置视频数据采集分辨率
    [self.session canSetSessionPreset:[self deviceSupportSessionPreset]];
    
    //开始配置
    [self.session beginConfiguration];
    
    //...相关配置
    //视频相关输入输出配置
    [self videoInputOutputSet];
    
    //音频相关输入输出配置
    [self audioInputOutputSet];
    
    //提交配置
    [self.session commitConfiguration];
    
}

//视频输入输出设置********************************
-(void)videoInputOutputSet{
    
    NSError *error;
    
    //初始化摄像头设备
    self.videoDevice = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //创建摄像头数组(前置、后置)
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    
    for (AVCaptureDevice *device in devices) {
        
        //默认开启前置摄像头
        if (device.position ==AVCaptureDevicePositionFront) {
            
            self.videoDevice = device;
        }
    }
    
    //视频输入
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.videoDevice error:&error];
    if (error) {
        
        NSAssert(error, error.localizedDescription);
        return;
    }
    //将输入的对象添加到 AVCaptureSession 中
    if ([self.session canAddInput:self.videoInput]) {
        
        [self.session addInput:self.videoInput];
    }
    
    //视频输出
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    //是否允许卡顿时丢帧
    self.videoOutput.alwaysDiscardsLateVideoFrames = NO;
    
    if ([self supportsFastTextureUpload]) {
        
        // 是否支持全频色彩编码 YUV 一种色彩编码方式, 即YCbCr, 现在视频一般采用该颜色空间, 可以分离亮度跟色彩, 在不影响清晰度的情况下来压缩视频
        BOOL supportFullYUVRange = NO;
        
        //获取输出对象所支持的像素格式
        NSArray *supportedPixelFormats = self.videoOutput.availableVideoCodecTypes;
        for (NSNumber *currentPixelFormat in supportedPixelFormats) {
            
            if ([currentPixelFormat integerValue] == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                
                supportFullYUVRange = YES;
            }
        }
        
        //根据是否支持全频色彩编码 YUV 来设置输出对象的视频像素压缩格式
        if (supportFullYUVRange) {
            
            [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }else{
            
            [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }
    }else{
        
        [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    // 创建设置代理是所需要的线程队列 优先级设为高
    dispatch_queue_t videoQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    [self.videoOutput setSampleBufferDelegate:self queue:videoQueue];
    //将输入的对象添加到 AVCaptureSession 中
    if ([self.session canAddOutput:self.videoOutput]) {
        
        [self.session addOutput:self.videoOutput];
        
        //链接视频输入输出
        [self connectionVideoInputOutput];
    }
}

//链接视频输入输出
-(void)connectionVideoInputOutput{
    
    // AVCaptureConnection是一个类，用来在AVCaptureInput和AVCaptureOutput之间建立连接。AVCaptureSession必须从AVCaptureConnection中获取实际数据。
    AVCaptureConnection * connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //默认竖屏
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 设置防抖动
    if ([connection isVideoStabilizationSupported]) {
        
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto; //自动
    }
    
    //设置裁剪,最大
    connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
}

//音频输入输出设置******************************
-(void)audioInputOutputSet{
    
    NSError *error;
    //初始化音频设备对象
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //音频输入
    self.audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.audioDevice error:&error];
    if (error) {
        
        NSAssert(error, error.localizedDescription);
        return;
    }
    //将输入的对象添加到 AVCaptureSession 中
    if ([self.session canAddInput:self.audioInput]) {
        
        [self.session addInput:self.audioInput];
    }
    
    //音频输出
    self.audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    //将输出的对象添加到 AVCaptureSession 中
    if ([self.session canAddOutput:self.audioOutput]) {
        
        [self.session addOutput:self.audioOutput];
    }
    
    // 创建设置代理是所需要的线程队列 优先级设为低 （视频高于音频）
    dispatch_queue_t audioQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    [self.audioOutput setSampleBufferDelegate:self queue:audioQueue];
    
}

#pragma mark - 分辨率、文理、等判断
//设备所支持的分辨率
-(NSString *)deviceSupportSessionPreset{
    
    if (![self.session canSetSessionPreset:self.sdkPreset]) {
        
        self.sessionPreset = AOELiveCaptureSessionPreset960x540;
        
        if (![self.session canSetSessionPreset:self.sdkPreset]) {
            
            self.sessionPreset = AOELiveCaptureSessionPreset640x480;
        }
    }else{
        
        self.sessionPreset = AOELiveCaptureSessionPreset640x480;
    }
    
    return self.sdkPreset;
}

-(NSString *)sdkPreset{
    
    switch (self.sessionPreset) {
        case AOELiveCaptureSessionPreset640x480:
            
            _sdkPreset = AVCaptureSessionPreset640x480;
            break;
        case AOELiveCaptureSessionPreset960x540:
            
            _sdkPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        case AOELiveCaptureSessionPreset1280x720:
            
            _sdkPreset = AVCaptureSessionPreset1280x720;
            break;
            
        default:
            
            _sdkPreset = AVCaptureSessionPreset640x480;
            break;
    }
    
    return _sdkPreset;
}

// 获取需要的设备对象
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //创建摄像头数组(前置、后置)
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
#pragma clang diagnostic pop
    AVCaptureDevice *captureDevice = devices.firstObject;   // 先初始化一个设备对象并赋初值
    // 便利获取需要的设备
    for (AVCaptureDevice *device in devices) {
        
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

//更改设备属性前一定要锁上
-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        
        NSAssert(error, error.localizedDescription);
    }else{
        //调整设备前后要调用beginConfiguration/commitConfiguration
        [self.session beginConfiguration];
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
        [self.session commitConfiguration];
    }
}

// 是否支持快速纹理更新
-(BOOL)supportsFastTextureUpload{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    return (CVOpenGLESTextureCacheCreate != NULL);
#pragma clang diagnostic pop
    
#endif
}


#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>
//实现视频输出对象和音频输出对象的代理方法, 在该方法中获取音视频采集的数据, 或者叫做帧数据
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (output == self.videoOutput) { //视频采集数据
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoCaptureOutputWithSampleBuffer:)]) {
            
            [self.delegate videoCaptureOutputWithSampleBuffer:sampleBuffer];
        }
    }else if (output == self.audioOutput){ //音频采集数据
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioCaptureOutputWithSampleBuffer:)]) {
            
            [self.delegate audioCaptureOutputWithSampleBuffer:sampleBuffer];
        }
    }
}

#pragma mark - setter/getter
-(AVCaptureSession *)session{
    
    if (!_session) {
        
        _session = [[AVCaptureSession alloc]init];
    }
    
    return _session;
}

@end
