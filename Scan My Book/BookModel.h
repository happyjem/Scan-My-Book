//
//  BookModel.h
//  Scan My Book
//
//  Created by hwang hee on 13. 1. 15..
//  Copyright (c) 2013년 hwang hee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookModel : NSObject

@property (nonatomic) NSString   *title;
@property (nonatomic) NSString   *link;
@property (nonatomic) NSString   *image;
@property (nonatomic) NSString   *author;
@property (nonatomic) NSUInteger price;
@property (nonatomic) NSUInteger discount;
@property (nonatomic) NSString   *publisher;
@property (nonatomic) NSDate     *date;
@property (nonatomic) NSString   *isbn;
@property (nonatomic) NSString   *description;

@end
