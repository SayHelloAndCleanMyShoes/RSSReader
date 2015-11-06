//
//  RSSNewsDownloader.m
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import "RSSNewsDownloader.h"
#import "RSSNewsModel.h"
#import "AFNetworking.h"

@interface RSSNewsDownloader() {
dispatch_queue_t downloadQueue;
}
@property (nonatomic, strong) AFHTTPRequestOperationManager* manager;

@end

@implementation RSSNewsDownloader

#pragma mark - Public

+ (instancetype)sharedDownloader {
    static RSSNewsDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloader = [[self alloc] init];
    });
    return sharedDownloader;
}

-(void) downloadRSSwithCompletion:(RSSNewsDownloaderBlock)completionBlock{
    if (!self.rssList)
        self.rssList = [[NSMutableArray alloc] init];
    
    self.urlToDownload = [NSURL URLWithString:@"http://static.feed.rbc.ru/rbc/internal/rss.rbc.ru/rbc.ru/mainnews.rss"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.urlToDownload];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    __weak typeof(self) weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData* responseData) {
        NSData *rssData = [NSData dataWithContentsOfURL:self.urlToDownload];
        [self downloadImageData];
        if (rssData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(rssData, nil);
                [weakSelf.rssList addObject:rssData];
            });
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, error);
            });
        }];
    operation.completionQueue = downloadQueue;
    [self.manager.operationQueue addOperation:operation];
}



#pragma mark - Private

-(void) downloadImageData {
    dispatch_async(downloadQueue, ^{
        [RSSNewsModel sharedModel].newsImageData = [[NSData alloc] initWithContentsOfURL:[RSSNewsModel sharedModel].newsImageURL];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        downloadQueue = dispatch_queue_create("Data Download Queue", 0);
        self.manager = [AFHTTPRequestOperationManager manager];
        self.manager.operationQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

@end
