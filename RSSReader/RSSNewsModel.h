//
//  RSSNewsModel.h
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSNewsModel : NSObject

@property (nonatomic, strong) NSURL* newsImageURL;
@property (nonatomic, strong) NSData* newsImageData;
@property (nonatomic, strong) NSURL* newsLink;
@property (nonatomic, strong) NSString* newsTitle;
@property (nonatomic, strong) NSString* newsDescription;
@property (nonatomic, strong) NSString* newsAuthor;
@property (nonatomic, strong) NSString* newsOrigin;
@property (nonatomic, strong) NSDate* newsDate;
@property (nonatomic, assign) NSInteger newsImageWidth;
@property (nonatomic, assign) NSInteger newsImageHeight;


+(instancetype) sharedModel;

@end
