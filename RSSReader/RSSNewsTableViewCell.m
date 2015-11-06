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

-(void) configureWithNews:(RSSNewsModel *)news {
    self.newsTitleLabel.text = news.newsTitle;
    self.newsAuthorLabel.text = news.newsAuthor;
    self.newsDateLabel.text = [NSString stringWithFormat:@"%@",[self.dateFormatter stringFromDate:news.newsDate]];
    self.newsThumbnailImage.image = [UIImage imageWithData:[RSSNewsModel sharedModel].newsImageData];
}


@end

