//
//  BookService.m
//  Scan My Book
//
//  Created by hwang hee on 13. 1. 16..
//  Copyright (c) 2013년 hwang hee. All rights reserved.
//

#import "BookService.h"

#pragma mark - Private interace

@interface BookService()

@property (nonatomic, strong)   MSTable *table;
@property (nonatomic)           NSInteger busyCount;

@end

@implementation BookService

@synthesize items;

-(BookService *) init
{
    // Initialize the Mobile Service client with your URL and key
    MSClient *newClient = [MSClient clientWithApplicationURLString:@"https://happyjemguestbook.azure-mobile.net/"
                                                withApplicationKey:@"UmgkNzVHDExATPuJiRhBFyeoIHDvgw55"];
    
    // Add a Mobile Service filter to enable the busy indicator
    self.client = [newClient clientwithFilter:self];
    
    // Create an MSTable instance to allow us to work with the TodoItem table
    self.table = [_client getTable:@"mybooks"];
    
    self.items = [[NSMutableArray alloc] init];
    self.busyCount = 0;
    
    return self;
}


- (void) refreshDataOnSuccess:(CompletionBlock)completion
{
    // Create a predicate that finds items where complete is false
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    
    // Query the MyBooks table and update the items property with the results from the service
    [self.table readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        
        // Let the caller know that we finished
        completion();
    }];
    
}

-(void) addItem:(NSDictionary *)item completion:(CompletionWithIndexBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        
        [self logErrorIfNotNil:error];
        NSUInteger index = [items count];
        [(NSMutableArray *)items insertObject:result atIndex:index];
        
        // Let the caller know that we finished
        completion(index);
    }];
}

-(void) addItem:(NSDictionary *)item
{
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        if (error) {
            [self logErrorIfNotNil:error];
        }
        else{
            NSLog(@"Item inserted, id: %@", [item objectForKey:@"id"]);
            NSUInteger index = [items count];
            [(NSMutableArray *)items insertObject:result atIndex:index];
        }
    }];
}

-(void) completeItem:(NSDictionary *)item completion:(CompletionWithIndexBlock)completion
{
    // Cast the public items property to the mutable type (it was created as mutable)
    NSMutableArray *mutableItems = (NSMutableArray *) items;
    
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
    [mutable setObject:@(YES) forKey:@"complete"];
    
    // Replace the original in the items array
    NSUInteger index = [items indexOfObjectIdenticalTo:item];
    [mutableItems replaceObjectAtIndex:index withObject:mutable];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.table update:mutable completion:^(NSDictionary *item, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        NSUInteger index = [items indexOfObjectIdenticalTo:mutable];
        [mutableItems removeObjectAtIndex:index];
        
        // Let the caller know that we have finished
        completion(index);
    }];
}

- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil) {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil) {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}


#pragma mark - MSFilter methods


- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self busy:NO];
        onResponse(response, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    onNext(request, wrappedResponse);
}


@end
