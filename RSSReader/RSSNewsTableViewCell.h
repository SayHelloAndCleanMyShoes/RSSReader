//
//  RSSNewsTableViewCell.h
//  RSSReader
//
//  Created by Dmitriy Kazhura on 06/11/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RSSNewsModel;

@interface RSSNewsTableViewCell : UITableViewCell

-(void) configureWithNews: (RSSNewsModel*) news;

@end
