//
//  BookService.h
//  Scan My Book
//
//  Created by hwang hee on 13. 1. 16..
//  Copyright (c) 2013년 hwang hee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#pragma mark - Block Definitions

typedef void (^CompletionBlock) ();
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^BusyUpdateBlock) (BOOL busy);


@interface BookService : NSObject<MSFilter>

@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;

- (void) refreshDataOnSuccess:(CompletionBlock) completion;

- (void) addItem:(NSDictionary *) item
      completion:(CompletionWithIndexBlock) completion;

-(void) addItem:(NSDictionary *)item;

- (void) completeItem: (NSDictionary *) item
           completion:(CompletionWithIndexBlock) completion;


- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse;


@end
