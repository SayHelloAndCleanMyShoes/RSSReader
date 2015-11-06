//
//  RSSNewsTableViewCell.m
//  RSSReader
//
//  Created by Dmitriy Kazhura on 06/11/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import "RSSNewsTableViewCell.h"
#import "RSSNewsModel.h"

@interface RSSNewsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *newsTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *newsAuthorLabel;
@property (nonatomic, weak) IBOutlet UILabel *newsDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *newsThumbnailImage;

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@end

@implementation RSSNewsTableViewCell

#pragma mark - Configuring news

-(void) configureWithNews:(RSSNewsModel *)news {
    self.newsTitleLabel.text = news.newsTitle;
    self.newsAuthorLabel.text = news.newsAuthor;
    self.newsDateLabel.text = [NSString stringWithFormat:@"%@",[self.dateFormatter stringFromDate:news.newsDate]];
    self.newsThumbnailImage.image = [self generateThumgnailFromImage:
                                     [UIImage imageWithData:[RSSNewsModel sharedModel].newsImageData]];
}

#pragma mark - Image -> Thumbnail

-(UIImage *) generateThumgnailFromImage: (UIImage *) image {
    UIImage *thumbnail;
    CGSize destinationSize = CGSizeMake(160, 78);
    UIGraphicsBeginImageContext(destinationSize);
    [image drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}

#pragma mark - dateFormatter init 


-(NSDateFormatter *) dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:60 * 60 * 3]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}















@end

