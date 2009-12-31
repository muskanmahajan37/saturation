//
//  BGSKulerFeedController.h
//  Saturation
//
//  Created by Shawn Roske on 12/29/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGSKulerOperation.h"

#define FEED_BASE_URL			@"http://kuler-api.adobe.com/feeds/rss/get.cfm?listType=%@&itemsPerPage=%i&startIndex=%i&key=%@"
#define FEED_API_KEY			@"B90C327DD1FB1BDA94CEC6A1AF6D84D4"
#define FEED_PER_PAGE			30
#define FEED_MAX_OPERATIONS		2

enum feedTypes 
{
	kKulerFeedTypeNewest = 1000, 
	kKulerFeedTypePopular,
	kKulerFeedTypeRandom,
	kKulerFeedTypeFavorites
};

enum scopes 
{
	kKulerFeedScopeFull = 2000, 
	kKulerFeedScopePartial
};

@interface BGSKulerFeedController : NSObject 
{
	NSOperationQueue *queue;
	NSArray *newestEntries;
	NSArray *popularEntries;
	NSArray *randomEntries;
	NSArray *favoriteEntries;
}

@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSArray *newestEntries;
@property (nonatomic, retain) NSArray *popularEntries;
@property (nonatomic, retain) NSArray *randomEntries;
@property (nonatomic, retain) NSArray *favoriteEntries;

- (void)refreshNewestEntries;
- (void)pageNewestEntries;
- (void)refreshPopularEntries;
- (void)pagePopularEntries;
- (void)refreshRandomEntries;
- (void)pageRandomEntries;

@end