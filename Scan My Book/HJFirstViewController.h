//
//  HJFirstViewController.h
//  Scan My Book
//
//  Created by hwang hee on 13. 1. 11..
//  Copyright (c) 2013년 hwang hee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "BookModel.h"
#import "BookService.h"

@interface HJFirstViewController : UIViewController <ZXCaptureDelegate>
{
    BookModel *myBook;
}

//@property (nonatomic, strong) BookService *bookService;

@end
