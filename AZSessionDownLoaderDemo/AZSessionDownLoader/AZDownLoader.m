//
//  AZDownLoader.m
//  AZSessionDownLoaderDemo
//
//  Created by Andrew on 16/6/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZDownLoader.h"
#import <CommonCrypto/CommonDigest.h>
#import "AZDownItem.h"


@interface AZDownLoader ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) NSMutableDictionary *downloads;

@end

@implementation AZDownLoader

+(instancetype)shareDownLoader
{
    static AZDownLoader *downLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downLoader=[AZDownLoader new];
    });
    return downLoader;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        // Default session
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
//        // Background session
//        NSURLSessionConfiguration *backgroundConfiguration = nil;
//        
//        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
//            backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
//        } else {
//            backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"re.touchwa.downloadmanager"];
//        }
//        
//        self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:nil];
        
        _downloads = [NSMutableDictionary new];
    }
    return self;
}


- (void)addDownloadTaskToQueueandDownURL:(NSString *)downURL toSaveFilePath:(NSString *)saveFilePath onDownloadProgress:(AZDownProcess) downProcess onCompletion:(AZDownSuccess) downSucess onError:(AZErrorBlock)errorBlock
{
    
    NSURL *url = [NSURL URLWithString:downURL];

    BOOL isHave=NO;
 
    if (isHave) {
        AZDownLog(@"down task has exist!");
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask;
     downloadTask = [self.session downloadTaskWithRequest:request];
    [downloadTask resume];
    
    AZDownItem *downItem=[AZDownItem downItemWithUrl:downURL DownloadTask:downloadTask SavePath:saveFilePath DownProcess:downProcess DownSuccess:downSucess ErrorBlock:errorBlock];
    
    [self.downloads setObject:downItem forKey:[self getKeyByURL:downURL]];
    
}

/**
 *   取消一个下载
 */
-(void)cancelDownloadTaskByDownURL:(NSString *)downURL
{
    NSString *key=[self getKeyByURL:downURL];
    AZDownItem *downItem=[self.downloads objectForKey:key];
    if (downItem) {
        [downItem.downloadTask cancel];
        [self.downloads removeObjectForKey:key];
    }
    if (self.downloads.count == 0) {
        [self cleanTmpDirectory];
    }
}

/**
 *   取消所有下载任务
 */
-(void)cancelAllDownloadTask
{
    for (NSString *key in self.downloads) {
        AZDownItem *downItem  = self.downloads[key];
        [downItem.downloadTask cancel];
    }
    [self.downloads removeAllObjects];
    [self cleanTmpDirectory];
}

#pragma mark - delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *key=[self getKeyByURL:downloadTask.originalRequest.URL.absoluteString];
    AZDownItem *downItem=[self.downloads objectForKey:key];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *saveFilePath = downItem.savePath;
    
    // 下载完成以后 先删除之前的文件 然后mv新的文件
    if ([fileManager fileExistsAtPath:saveFilePath]) {
        [fileManager removeItemAtPath:saveFilePath error:&error];
        if (error) {
            NSLog(@"remove %@ file failed!\nError:%@", saveFilePath, error);
            exit(-1);
        }
    }
    
    [fileManager moveItemAtPath:location.path toPath:saveFilePath error:&error];
    if (error) {
        NSLog(@"move %@ file to %@ file is failed!\nError:%@", location.path, saveFilePath, error);
        exit(-1);
    }
    
    if (downItem.downSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            downItem.downSuccess(saveFilePath);
        });
    }
    
    [self.downloads removeObjectForKey:key];

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    unsigned long long totalSize = totalBytesExpectedToWrite;
    
    NSString *key=[self getKeyByURL:downloadTask.originalRequest.URL.absoluteString];
    AZDownItem *downItem=[self.downloads objectForKey:key];
    
    if (downItem.downProcess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            downItem.downProcess(progress,totalSize);
        });
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        AZDownLog(@"ERROR: %@", error);
        
        NSString *key=[self getKeyByURL:task.originalRequest.URL.absoluteString];
        AZDownItem *downItem=[self.downloads objectForKey:key];
        
        if (downItem.errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                downItem.errorBlock(error);
            });
        }
    }
}


#pragma  method  - private

-(NSString *)getKeyByURL:(NSString *)url
{
    NSString *tempDownURL=[url copy];
    
    const char *cStr = [tempDownURL UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr),result );
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    NSString *md5Str=[NSString stringWithString:hash];
    return md5Str;
}

- (void)cleanTmpDirectory {
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

@end
