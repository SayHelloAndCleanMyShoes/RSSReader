//
//  RSSParseOperation.m
//  RSSReader
//
//  Created by Dmitriy Kazhura on 29/10/15.
//  Copyright © 2015 Dmitriy Kazhura. All rights reserved.
//
// NSNotification name for sending news data back to the app delegate

#import "RSSParseOperation.h"
#import "RSSNewsModel.h"

NSString *kAddNewsNotificationName = @"AddNewsNotif";
NSString *kNewsResultsKey = @"NewsResultsKey";
NSString *kNewsErrorNotificationName = @"NewsErrorNotif";
NSString *kNewsMessageErrorKey = @"NewsMsgErrorKey";

@interface RSSParseOperation () <NSXMLParserDelegate>

@property (nonatomic) RSSNewsModel *currentNewsObject;
@property (nonatomic, strong) NSMutableArray *currentParseBatch;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;

@end

@implementation RSSParseOperation

{
    NSDateFormatter *_dateFormatter;
    
    BOOL _accumulatingParsedCharacterData; //Flag for if we want to keep characters we found
    BOOL _didAbortParsing;                 //Flag for if we aborted parsing by ourselves
    NSUInteger _parsedNewsCounter;
}

- (id)initWithData:(NSData *)parseData {
    
    self = [super init];
    if (self) {
        _rssData = [parseData copy];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:60 * 60 * 3]];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
        [_dateFormatter setDateFormat:@"E, dd MMM yyyy, HH:mm:ss"];
        
        self.currentParseBatch = [[NSMutableArray alloc] init];
        self.currentParsedCharacterData = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)addNewsToList:(NSArray *) news {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddNewsNotificationName object:self userInfo:@{kNewsResultsKey: news}];
}

- (void)main {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.rssData];
    [parser setDelegate:self];
    [parser parse];
    if ([self.currentParseBatch count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addNewsToList:self.currentParseBatch];
        });
    }
}

#pragma mark - Parser constants

static const NSUInteger kMaximumNumberOfNewsToParse = 100;

static NSUInteger const kSizeOfENewsBatch = 10;

static NSString * const kItemElementName = @"item";
static NSString * const kTitleElementName = @"title";
static NSString * const kLinkElementName = @"link";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kPubDateElementName = @"pubDate";
static NSString * const kAuthorElementName = @"author";
static NSString * const kEnclosureElementName = @"enclosure";

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (_parsedNewsCounter >= kMaximumNumberOfNewsToParse) {
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kItemElementName])
        self.currentNewsObject = [[RSSNewsModel alloc] init];
    else if ([elementName isEqualToString:kEnclosureElementName]) {
        // Fullfilling image properties
       
        [RSSNewsModel sharedModel].newsImageURL = [attributeDict valueForKey:@"url"];
        self.currentNewsObject.newsImageWidth = [[attributeDict valueForKey:@"width"] integerValue];
        self.currentNewsObject.newsImageHeight = [[attributeDict valueForKey:@"height"] integerValue];
        
    }
    else if ([elementName isEqualToString:kTitleElementName] || [elementName isEqualToString:kLinkElementName] || [elementName isEqualToString:kDescriptionElementName] || [elementName isEqualToString:kPubDateElementName] || [elementName isEqualToString:kAuthorElementName] || [elementName isEqualToString:kPubDateElementName]) {
        _accumulatingParsedCharacterData = YES;
        [self.currentParsedCharacterData setString:@""]; //Cleaning mutable string
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kItemElementName]) {
        [self.currentParseBatch addObject:self.currentNewsObject];
        _parsedNewsCounter++;
        if ([self.currentParseBatch count] > kSizeOfENewsBatch) {
            [self performSelectorOnMainThread:@selector(addNewsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    }
    else if ([elementName isEqualToString:kTitleElementName]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        if ([scanner scanString:@"<![CDATA[" intoString:NULL]) {
            NSString *titleText = nil;
            if ([scanner scanUpToString:@"]" intoString:&titleText]) {
                self.currentNewsObject.newsTitle = titleText;
            }
        }
    }
    else if ([elementName isEqualToString:kLinkElementName]) {
        self.currentNewsObject.newsLink = [NSURL URLWithString:self.currentParsedCharacterData];
    }
    else if ([elementName isEqualToString:kDescriptionElementName]) {
        if (self.currentNewsObject != nil) {
            NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
            if ([scanner scanString:@"<![CDATA[" intoString:NULL]) {
                NSString *descriptionText = nil;
                if ([scanner scanUpToString:@"]" intoString:&descriptionText]) {
                    self.currentNewsObject.newsDescription = descriptionText;
                }
                
            }
        }
    }
    else if ([elementName isEqualToString:kPubDateElementName]) {
        self.currentNewsObject.newsDate = [_dateFormatter dateFromString:self.currentParsedCharacterData];
    }
    else if ([elementName isEqualToString:kAuthorElementName]) {
        self.currentNewsObject.newsAuthor = self.currentParsedCharacterData;
    }
    _accumulatingParsedCharacterData = NO; // Stops accumulating data until we found specific elements
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

-(void)handleNewsError: (NSError*) parseError {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsErrorNotificationName object:self userInfo:@{kNewsMessageErrorKey : parseError}];
}


-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !_didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleNewsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end