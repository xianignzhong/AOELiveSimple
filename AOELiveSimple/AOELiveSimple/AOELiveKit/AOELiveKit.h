//
//  AOELiveKit.h
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/2/27.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#ifndef AOELiveKit_h
#define AOELiveKit_h

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

#import "AOELiveTool.h"
#import "AOELiveCaptureSession.h"
#import "FSKGPUImageBeautyFilter.h"


#endif /* AOELiveKit_h */
