//
//  GPUViewController.m
//  AOELiveSimple
//
//  Created by 夏宁忠 on 2018/3/1.
//  Copyright © 2018年 夏宁忠. All rights reserved.
//

#import "GPUViewController.h"
#import <GPUImage.h>
#import <Masonry.h>

#import "FSKGPUImageBeautyFilter.h"

@interface GPUViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) GPUImageFilter *baseFilter;//滤镜基类
@property (nonatomic, strong) GPUImageColorInvertFilter *invert; //反色滤镜
@property (nonatomic, strong) GPUImageGammaFilter *gamma; //伽马线滤镜
@property (nonatomic, strong) GPUImageExposureFilter *exposure; //曝光度滤镜
@property (nonatomic, strong) GPUImageSepiaFilter *sepia; //怀旧滤镜

@property (nonatomic, strong) GPUImageFilterGroup *group; //混合滤镜

@property (nonatomic, strong) FSKGPUImageBeautyFilter * beauty;//美颜

@end

@implementation GPUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self aoe_setupViews];
    
    [self aoe_setupFilter];
    
    [self aoe_setupLayouts];
    
    [self.videoCamera startCameraCapture];
}

-(void)aoe_setupViews{
    
    [self.view insertSubview:self.filterView atIndex:0];
}

-(void)aoe_setupFilter{
    
    /**无滤镜
    [self.videoCamera addTarget:self.baseFilter];
    [self.baseFilter addTarget:self.filterView];
    */
    
    /** 单个滤镜
    [self.videoCamera addTarget:self.sepia];
    
//    [self.invert addTarget:self.filterView];
    
//    self.gamma.gamma = 0.2;
//    [self.gamma addTarget:self.filterView];
    
//    self.exposure.exposure = -1;
//    [self.exposure addTarget:self.filterView];
    
    [self.sepia addTarget:self.filterView];
     */
    
    /** 组合滤镜
    [self.videoCamera addTarget:self.group];
    
    [self addGPUImageFilter:self.invert];
    
    self.gamma.gamma = 0.2;
    [self addGPUImageFilter:self.gamma];
    
    self.exposure.exposure = -1;
    [self addGPUImageFilter:self.exposure];
    
    [self addGPUImageFilter:self.sepia];

    [self.group addTarget:self.filterView];
    */
    
    //美颜这里用FSKGPUImageBeautyFilter 都是基于GPUImageFilter
    [self.videoCamera addTarget:self.beauty];
    
    self.beauty.beautyLevel = 0.5;
    self.beauty.toneLevel = 0.8;
    self.beauty.brightLevel = 0.4;
    
    [self.beauty addTarget:self.filterView];
}

#pragma mark 将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageFilter *)filter{
    
    [self.group addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = self.group.filterCount;
    
    if(count == 1){
        
        //设置初始滤镜
        self.group.initialFilters = @[newTerminalFilter];
        //设置末尾滤镜
        self.group.terminalFilter = newTerminalFilter;
        
    }else{
        
        GPUImageOutput<GPUImageInput> *terminalFilter    = self.group.terminalFilter;
        NSArray *initialFilters                          = self.group.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        //设置初始滤镜
        self.group.initialFilters = @[initialFilters[0]];
        //设置末尾滤镜
        self.group.terminalFilter = newTerminalFilter;
    }
}

-(void)aoe_setupLayouts{
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(self.view).mas_offset(UIEdgeInsetsZero);
    }];
}

- (IBAction)change:(UIButton *)sender {
    
    [self.videoCamera rotateCamera];
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

#pragma mark - setter/getter
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

-(GPUImageFilter *)baseFilter{
    
    if (!_baseFilter) {
        
        _baseFilter = [[GPUImageFilter alloc]init];
    }
    
    return _baseFilter;
}

-(GPUImageColorInvertFilter *)invert{
    
    if (!_invert) {
        
        _invert = [[GPUImageColorInvertFilter alloc]init];
    }
    
    return _invert;
}

-(GPUImageGammaFilter *)gamma{
    
    if (!_gamma) {
        
        _gamma = [[GPUImageGammaFilter alloc]init];
    }
    
    return _gamma;
}

-(GPUImageExposureFilter *)exposure{
    
    if (!_exposure) {
        
        _exposure = [[GPUImageExposureFilter alloc]init];
    }
    
    return _exposure;
}

-(GPUImageSepiaFilter *)sepia{
    
    if (!_sepia) {
        
        _sepia = [[GPUImageSepiaFilter alloc]init];
    }
    
    return _sepia;
}

-(GPUImageFilterGroup *)group{
    
    if (!_group) {
        
        _group = [[GPUImageFilterGroup alloc]init];
    }
    
    return _group;
}

-(FSKGPUImageBeautyFilter *)beauty{
    
    if (!_beauty) {
        
        _beauty = [[FSKGPUImageBeautyFilter alloc]init];
    }
    
    return _beauty;
}


@end
