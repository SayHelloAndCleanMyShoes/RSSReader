//
//  RSSParseOperation.h
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *kAddNewsNotificationName;
extern NSString *kNewsResultsKey;
extern NSString *kNewsErrorNotificationName;
extern NSString *kNewsMessageErrorKey;

@interface RSSParseOperation : NSOperation

@property (copy, readonly) NSData *rssData;

- (id)initWithData:(NSData *)parseData;

@end
