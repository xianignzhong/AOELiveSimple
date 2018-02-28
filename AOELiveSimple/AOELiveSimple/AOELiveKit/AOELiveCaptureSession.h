//
//  AOELiveCaptureSession.h
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 视频采集分辨率

 - AOELiveCaptureSessionPreset640x480: 低分辨率
 - AOELiveCaptureSessionPreset960x540: 中等分辨率
 - AOELiveCaptureSessionPreset1280x720: 高分辨率
 */
typedef NS_ENUM(NSUInteger, AOELiveCaptureSessionPreset) {
    AOELiveCaptureSessionPreset640x480 = 0,
    AOELiveCaptureSessionPreset960x540,
    AOELiveCaptureSessionPreset1280x720
};

/**
 摄像头方向

 - AOELiveCameraPositionFornt: 前置摄像头
 - AOELiveCameraPositionBack: 后置摄像头
 */
typedef NS_ENUM(NSInteger, AOELiveCameraPosition) {
    AOELiveCameraPositionFornt = 0,
    AOELiveCameraPositionBack
};

@protocol AOELiveCaptureSessionDelegate <NSObject>

/**
 视频取样数据回调

 @param sampleBuffer 取样数据CMSampleBufferRef
 */
- (void)videoCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 音频取样数据回调
 
 @param sampleBuffer 取样数据CMSampleBufferRef
 */
- (void)audioCaptureOutputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface AOELiveCaptureSession : NSObject

@property (nonatomic, assign) id <AOELiveCaptureSessionDelegate> delegate;

/**
 切换前后摄像头
 */
@property (nonatomic, assign) AOELiveCameraPosition cameraPosition;

/**
 初始化CaptureSession

 @param preset 设置采集分辨率
 @return id
 */
-(instancetype)initLiveCaptureSession:(AOELiveCaptureSessionPreset)preset;

/**
 开始采集数据
 */
-(void)startSessionRunning;

/**
 暂停采集数据
 */
-(void)stopSessionRunning;

@end
