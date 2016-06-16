//
//  AZDownLoader.h
//  AZSessionDownLoaderDemo
//
//  Created by Andrew on 16/6/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZDownItem.h"


#if DEBUG
#define AZDownLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#elif
#define AZDownLog(...)
#endif




@interface AZDownLoader : NSObject

/**
 *  返回 单例
 *
 *  @return
 */
+(instancetype)shareDownLoader;


/*!
 *  添加下载任务，一经添加，则会立即下载
 *
 *  @param downURL : 下载资源的url（NSString）
 *  @param saveFilePath : 下载资源文件后保存的路径（NSString） !!! 是文件路径，而不是文件夹路径
 *
 */
- (void)addDownloadTaskToQueueandDownURL:(NSString *)downURL toSaveFilePath:(NSString *)saveFilePath onDownloadProgress:(AZDownProcess) downProcess onCompletion:(AZDownSuccess) downSucess onError:(AZErrorBlock)errorBlock;

/**
 *   取消一个下载
 */
-(void)cancelDownloadTaskByDownURL:(NSString *)downURL;

/**
 *   取消所有下载任务
 */
-(void)cancelAllDownloadTask;


@end
