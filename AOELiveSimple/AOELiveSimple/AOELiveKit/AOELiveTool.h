//
//  AOELiveTool.h
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 直播权限状态

 - AOELiveSupportLiveStatusAllow: 允许直播
 - AOELiveSupportLiveStatusCameraNot: 摄像头未被允许开启
 - AOELiveSupportLiveStatusMicrophoneNot: 麦克风未被允许开启
 - AOELiveSupportLiveStatusAllNot: 摄像头、麦克风都未被允许
 */
typedef NS_ENUM(NSInteger, AOELiveSupportLiveStatus)
{
    AOELiveSupportLiveStatusAllow = 0,
    AOELiveSupportLiveStatusCameraNot,
    AOELiveSupportLiveStatusMicrophoneNot,
    AOELiveSupportLiveStatusAllNot,
};

@interface AOELiveTool : NSObject

/**
 检测摄像头是否允许使用

 @param authInfo 回馈信息
 */
+(void)checkCameraDeviceAuth:(void(^)(BOOL isAllow, AVAuthorizationStatus status))authInfo;

/**
 检测麦克风是否允许使用

 @param authInfo 回馈信息
 */
+(void)checkMicrophoneDeviceAuth:(void(^)(BOOL isAllow, AVAuthorizationStatus status))authInfo;

/**
 检测权限是否可以直播（麦克风、摄像头都开启）

 @param authInfo 回馈信息
 */
+(void)checkSupportLiveAuth:(void(^)(BOOL isSupport, AOELiveSupportLiveStatus status))authInfo;

@end
