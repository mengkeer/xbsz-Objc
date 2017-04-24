//
//  CXNetwork+download.m
//  xbsz
//
//  Created by lotus on 2017/4/16.
//  Copyright © 2017年 lotus. All rights reserved.
//

#import "DownloadManager.h"

static id _manager = nil;

@interface DownloadManager ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation DownloadManager

+ (instancetype)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[DownloadManager alloc] init];
    });
    return _manager;
}

- (void)downloadFromServer:(NSString *)url{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
   
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        CXLog(@"下载完成");
    }];
    [_downloadTask resume];
}

- (void)resume{
    [_downloadTask resume];
}

- (void)suspend{
    [_downloadTask suspend];
}

@end