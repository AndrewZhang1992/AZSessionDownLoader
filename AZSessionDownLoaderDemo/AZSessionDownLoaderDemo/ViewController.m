//
//  ViewController.m
//  AZSessionDownLoaderDemo
//
//  Created by Andrew on 16/6/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "ViewController.h"
#import "AZDownLoader.h"

#define FILE_URL @"http://dl_dir.qq.com/qqfile/qq/QQforMac/QQ_V1.4.1.dmg"

#define X_AZ_DOWN_PATH  [NSString stringWithFormat:@"%@/Library/",NSHomeDirectory()]


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *savePath=[X_AZ_DOWN_PATH stringByAppendingPathComponent:@"QQ_V1.4.1.dmg"];
    
    [[AZDownLoader shareDownLoader] addDownloadTaskToQueueandDownURL:FILE_URL toSaveFilePath:savePath onDownloadProgress:^(double process, unsigned long long totalSize) {
        
        NSLog(@"%f",process);
        
    } onCompletion:^(NSString *location) {
        NSLog(@"目的文件保存在：%@",location);
    } onError:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
