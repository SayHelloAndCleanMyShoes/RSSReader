//
//  RSSNewsDownloader.h
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSNewsDownloader : NSObject

typedef void(^RSSNewsDownloaderBlock)(NSData *rssDataToParse, NSError *error);

@property (nonatomic, strong) NSMutableArray* rssList;
@property (nonatomic, strong) NSURL* urlToDownload;

+ (instancetype)sharedDownloader;

-(void) downloadRSSwithCompletion:(RSSNewsDownloaderBlock)completionBlock;

@end
