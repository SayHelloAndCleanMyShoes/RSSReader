//
//  RSSNewsDownloader.h
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSNewsDownloader : NSObject

typedef void(^RSSNewsDownloaderBlock)(NSArray *rssArrayToParse, NSError *error);

@property (nonatomic, strong) NSMutableArray* rssList;

+ (instancetype)sharedDownloader;
-(void) downloadRSSFromURL:(NSURL*) URL withCompletion:(RSSNewsDownloaderBlock)completionBlock;
@end
