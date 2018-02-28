//
//  AOELiveTool.m
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import "AOELiveTool.h"

@implementation AOELiveTool

+(void)checkCameraDeviceAuth:(void (^)(BOOL, AVAuthorizationStatus))authInfo{
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized://已授权
            authInfo(YES, AVAuthorizationStatusAuthorized);
            break;
        case AVAuthorizationStatusNotDetermined:{ //未授权，进行允许和拒绝
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {
                    
                    authInfo(YES, AVAuthorizationStatusAuthorized);
                }else{
                    
                    authInfo(NO, AVAuthorizationStatusDenied);
                }
            }];
        }
            break;
        case AVAuthorizationStatusDenied: //明确拒绝
            authInfo(NO, AVAuthorizationStatusDenied);
            break;
        case AVAuthorizationStatusRestricted: //可能家长控制
            authInfo(NO, AVAuthorizationStatusRestricted);
            break;
        default:
            break;
    }
}

+(void)checkMicrophoneDeviceAuth:(void (^)(BOOL, AVAuthorizationStatus))authInfo{
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
        case AVAuthorizationStatusAuthorized://已授权
            authInfo(YES, AVAuthorizationStatusAuthorized);
            break;
        case AVAuthorizationStatusNotDetermined:{ //未授权，进行允许和拒绝
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
                if (granted) {
                    
                    authInfo(YES, AVAuthorizationStatusAuthorized);
                }else{
                    
                    authInfo(NO, AVAuthorizationStatusDenied);
                }
            }];
        }
            break;
        case AVAuthorizationStatusDenied: //明确拒绝
            authInfo(NO, AVAuthorizationStatusDenied);
            break;
        case AVAuthorizationStatusRestricted: //可能家长控制
            authInfo(NO, AVAuthorizationStatusRestricted);
            break;
        default:
            break;
    }
}

+(void)checkSupportLiveAuth:(void (^)(BOOL, AOELiveSupportLiveStatus))authInfo{
    
    __block BOOL supportCamera;
    [AOELiveTool checkCameraDeviceAuth:^(BOOL isAllow, AVAuthorizationStatus status) {
        
        supportCamera = isAllow;
        
        __block BOOL supportMicrophone;
        [AOELiveTool checkMicrophoneDeviceAuth:^(BOOL isAllow, AVAuthorizationStatus status) {
            
            supportMicrophone = isAllow;
            
            if (supportCamera && supportMicrophone) { //都支持
                
                authInfo(YES, AOELiveSupportLiveStatusAllow);
            }else if (supportCamera && !supportMicrophone){ //支持视频不支持麦克风
                
                authInfo(NO, AOELiveSupportLiveStatusMicrophoneNot);
            }else if (!supportCamera && supportMicrophone){ //不支持视频支持麦克风
                
                authInfo(NO, AOELiveSupportLiveStatusCameraNot);
            }else{ //都不支持
                
                authInfo(NO, AOELiveSupportLiveStatusAllNot);
            }
        }];
    }];
}

@end
