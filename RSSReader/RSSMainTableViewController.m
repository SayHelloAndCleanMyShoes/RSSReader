//
//  ViewController.m
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//

#import "RSSMainTableViewController.h"
#import "RSSNewsDownloader.h"
#import "RSSParseOperation.h"
#import "RSSNewsTableViewCell.h"
#import "RSSNewsModel.h"

@interface RSSMainTableViewController () <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic) NSOperationQueue *parseQueue;

@end

@implementation RSSMainTableViewController
#pragma mark - ViewDidLoad & Dealloc

- (void)viewDidLoad {
    [super viewDidLoad];
    RSSNewsDownloaderBlock completion = ^(NSData *rssDataToParse, NSError *error) {
        if (error == nil && rssDataToParse != nil) {
            self.parseQueue = [NSOperationQueue new];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(addNews:)
                                                         name:kAddNewsNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newsError:)
                                                         name:kNewsErrorNotificationName object:nil];
            
            // if the locale changes behind our back, we need to be notified so we can update the date
            // format in the table view cells
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(localeChanged:)
                                                         name:NSCurrentLocaleDidChangeNotification
                                                       object:nil];
        } else {
            [self handleError:error];
        }
    };
    [[RSSNewsDownloader sharedDownloader] downloadRSSwithCompletion:completion];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAddNewsNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNewsErrorNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}


#pragma mark - Error handling

-(void)handleError: (NSError*) error {
    NSString *errorMesage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMesage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
}

-(void) addNews: (NSNotification*) notification {
    assert([NSThread isMainThread]);
    [self addNewsToList:[[notification userInfo] valueForKey:kNewsResultsKey]];
}

-(void) newsError: (NSNotification*) notification {
    assert([NSThread isMainThread]);
    [self handleError:[[notification userInfo] valueForKey:kNewsMessageErrorKey]];
    
}

#pragma mark - Add news to list

-(void) addNewsToList: (NSArray*) newsArray {
    NSInteger startingRow = [[RSSNewsDownloader sharedDownloader].rssList count];
    NSInteger newsCount = [newsArray count];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:newsCount];
    for (NSInteger row = startingRow; row < (startingRow + newsCount); row++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [[RSSNewsDownloader sharedDownloader].rssList addObjectsFromArray:newsArray];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RSSNewsDownloader sharedDownloader].rssList count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *newsCellID = @"NewsCellID";
    RSSNewsTableViewCell *cell = (RSSNewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:newsCellID];
    
    RSSNewsModel *newsModel = ([RSSNewsDownloader sharedDownloader].rssList)[indexPath.row]; // Можно ли использовать?
    [cell configureWithNews:newsModel];
    return cell;
}




















#pragma mark - Locale Changed

-(void) localeChanged: (NSNotification *) notification {
    [self.tableView reloadData];
}

@end
