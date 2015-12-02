//
//  ViewController.m
//  测试分合专用
//
//  Created by SGJ on 15/11/10.
//  Copyright © 2015年 SGJ. All rights reserved.
//

#import "ViewController.h"
#import "KrVideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+MJ.h"

@interface ViewController ()

@property (strong, nonatomic) NSURL *outputUrl;

@property (assign, nonatomic) BOOL isOk;

@property(nonatomic,strong)KrVideoPlayerController * videoController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    
    
}
- (IBAction)compound:(id)sender {
    
    [self theVideoWithMixMusic];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)player:(id)sender {
    
    
    if (!self.outputUrl) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
        
        NSLog(@"%@",myDirectory);

        self.outputUrl = [NSURL URLWithString:myDirectory];
    }
    
    [self addVideoPlayerWithURL:self.outputUrl];
    
    
    
}

/** 播放器 **/
- (void)addVideoPlayerWithURL:(NSURL *)url{
    if (!self.videoController) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:CGRectMake(0, 64, width, width*(9.0/16.0))];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController setWillBackOrientationPortrait:^{
            //            [weakSelf toolbarHidden:NO];
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
            //            [weakSelf toolbarHidden:YES];
        }];
        [self.view addSubview:self.videoController.view];
    }
    self.videoController.contentURL = url;
    
    [self.videoController play];
}




//最终音频和视频混合
-(void)theVideoWithMixMusic
{

    NSString *documentsDirectory =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //声音来源路径（最终混合的音频）
    NSURL *urlStr2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"约定" ofType:@"mp3"]];
    NSURL   *audio_inputFileUrl = urlStr2;
    NSURL *urlStr = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"myPlayer" ofType:@"mp4"]];
    
    //视频来源路径
    NSURL *video_inputFileUrl = urlStr;
    
    //最终合成输出路径
    NSString *outputFilePath =[documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    NSURL   *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    
    
    
    if([[NSFileManager defaultManager]fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager]removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    //创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    //视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack =[mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    //声音采集
    AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    
    CMTimeRange audio_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //创建一个输出
    
    AVAssetExportSession *_assetExport = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType =AVFileTypeQuickTimeMovie;
    _assetExport.outputURL =outputFileUrl;
    _assetExport.shouldOptimizeForNetworkUse=YES;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^{
         NSLog(@"完成！输出路径==%@",outputFilePath);
        self.outputUrl = outputFileUrl;
        
        
            
        dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD showSuccess:@"合成成功"];
                
            });
            
       

    }];
   
     

}




@end
