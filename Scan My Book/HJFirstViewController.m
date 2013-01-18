//
//  HJFirstViewController.m
//  Scan My Book
//
//  Created by hwang hee on 13. 1. 11..
//  Copyright (c) 2013년 hwang hee. All rights reserved.
//

#import "HJFirstViewController.h"
#import "TBXML+HTTP.h"
#import "BookModel.h"
#import "ZAActivityBar.h"

@interface HJFirstViewController ()

@property (nonatomic, retain) ZXCapture* capture;
@property (nonatomic, retain) IBOutlet UILabel* decodedLabel;
@property (nonatomic) BOOL isParseComplete;

- (NSString*)displayForResult:(ZXResult*)result;

@end

@implementation HJFirstViewController

@synthesize capture;
@synthesize decodedLabel;
@synthesize isParseComplete;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.delegate = self;
    self.capture.rotation = 90.0f;
    
    // Use the back camera
    self.capture.camera = self.capture.back;
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.decodedLabel];
    
    [self.capture start];
    
    self.isParseComplete = NO;
    myBook = nil;
    
    [self addObserver:self forKeyPath:@"isParseComplete" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.capture stop];
    self.decodedLabel = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
    NSString *formatString;
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    NSLog(@"%@", result.text);
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
}


#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    if (result) {
        // We got a result. Display information about the result onscreen.
        [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self.capture stop];
        
        [ZAActivityBar showWithStatus:@"Processing..." forAction:@"CallAndSaveAction"];
        
        //make naver book open api string
        NSString *naverBookAPIString = [NSString stringWithFormat:@"http://openapi.naver.com/search?key=1ae552c30f1541c7ae8cbdde34b01ac8&target=book_adv&query=art&d_isbn=%@",result.text];
        [self parseXML:naverBookAPIString];
        //[self saveBookModel:nil];
        
        //[ZAActivityBar showSuccessWithStatus:@"Completed!!!" forAction:@"CallAndSaveAction"];
        //[self.capture start];
    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}


#pragma mark - Call API & Parse Result XML

- (void)parseXML:(NSString*)urlString
{

    // Create a success block to be called when the async request completes
    TBXMLSuccessBlock successBlock = ^(TBXML *tbxmlDocument) {
        
        TBXMLElement *rootNode = tbxmlDocument.rootXMLElement;
        // If TBXML found a root node, process element and iterate all children
        if (rootNode)
        {
            TBXMLElement *channelElement = [TBXML childElementNamed:@"channel" parentElement:rootNode];
            if (channelElement) {
                TBXMLElement *itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
                if (itemElement) {
                    TBXMLElement *nextItem = itemElement -> firstChild;
                    if (nextItem) {
                        
                        //create book model
                        myBook = [[BookModel alloc] init];
                        
                        do {
                            //item description
                            if ([[TBXML elementName:nextItem] isEqualToString:@"title"]) {
                                myBook.title = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"link"])
                            {
                                myBook.link = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"image"])
                            {
                                myBook.image = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"author"])
                            {
                                myBook.author = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"price"])
                            {
                                myBook.price = (NSUInteger)[[TBXML textForElement:nextItem] integerValue];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"discount"])
                            {
                                myBook.discount = (NSUInteger)[[TBXML textForElement:nextItem] integerValue];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"publisher"])
                            {
                                myBook.publisher = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"pubdate"])
                            {
                                //String 을 날짜(NSDate)로 변경
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyyMMdd"];
                                NSString *dateString = [TBXML textForElement:nextItem];
                                if (dateString) {
                                    myBook.date = [dateFormatter dateFromString:dateString];
                                }
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"isbn"])
                            {
                                myBook.isbn = [TBXML textForElement:nextItem];
                            }
                            else if([[TBXML elementName:nextItem] isEqualToString:@"description"])
                            {
                                myBook.description = [TBXML textForElement:nextItem];
                            }
                            
                            nextItem = nextItem -> nextSibling;
                            
                        } while (nextItem);
                        self.isParseComplete = YES;
                    }
                }
            }
        }
        
    };
    
    // Create a failure block that gets called if something goes wrong
    TBXMLFailureBlock failureBlock = ^(TBXML *tbxmlDocument, NSError * error) {
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
    };
    
    // Initialize TBXML with the URL of an XML doc. TBXML asynchronously loads and parses the file.
    [TBXML newTBXMLWithURL:[NSURL URLWithString:urlString] success:successBlock failure:failureBlock];
}

#
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"책 검색 완료"
                                                          message:@"클라우드 데이터 저장소에 저장할까요?"
                                                         delegate:self
                                                cancelButtonTitle:@"좋아"
                                                otherButtonTitles:@"싫어",nil];
        [message show];
    });
}

#
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        BookService *bookService = [[BookService alloc] init];
        NSDictionary *item = @{@"title" : myBook.title,@"imageUrl" : myBook.image};
        [bookService addItem:item];
    }
    
    myBook = nil;
    decodedLabel.text = @"";
    [ZAActivityBar dismiss];
    [self.capture start];
    
}

@end
