//
//  AZDownItem.m
//  AZSessionDownLoaderDemo
//
//  Created by Andrew on 16/6/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDownItem.h"

@implementation AZDownItem

+(instancetype)downItemWithUrl:(NSString *)url DownloadTask:(NSURLSessionDownloadTask *)downloadTask  SavePath:(NSString *)savePath DownProcess:(AZDownProcess) downProcess  DownSuccess:(AZDownSuccess) downSuccess ErrorBlock:(AZErrorBlock)  errorBlock
{
    AZDownItem *downItem=[AZDownItem new];
    downItem.url=url;
    downItem.downloadTask=downloadTask;
    downItem.savePath=savePath;
    downItem.downProcess=downProcess;
    downItem.downSuccess=downSuccess;
    downItem.errorBlock=errorBlock;
    return downItem;
}

@end
