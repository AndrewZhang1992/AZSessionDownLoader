//
//  AZDownItem.h
//  AZSessionDownLoaderDemo
//
//  Created by Andrew on 16/6/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

// define blocks

typedef void (^AZErrorBlock)(NSError *error);
typedef void (^AZDownProcess)(double process,unsigned long long totalSize);
typedef void (^AZDownSuccess) (NSString *location);


@interface AZDownItem : NSObject

/**
 *  下载资源 url
 */
@property (nonatomic,copy)NSString *url;

/**
 *  文件 保存 路径
 */
@property (nonatomic,copy)NSString *savePath;


@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,copy)AZDownProcess downProcess;
@property (nonatomic,copy)AZDownSuccess downSuccess;
@property (nonatomic,copy)AZErrorBlock  errorBlock;



+(instancetype)downItemWithUrl:(NSString *)url DownloadTask:(NSURLSessionDownloadTask *)downloadTask  SavePath:(NSString *)savePath DownProcess:(AZDownProcess) downProcess  DownSuccess:(AZDownSuccess) downSuccess ErrorBlock:(AZErrorBlock)  errorBlock;

@end
