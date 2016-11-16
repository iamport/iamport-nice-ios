//
//  ViewController.h
//  WebView
//
//  Created by user on 2015. 5. 22..
//  Copyright (c) 2015년 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic,retain)  NSString* bankPayUrlString;

- (void) requestBankPayResult:(NSString*)bodyString;
- (void) requesIspPayResult:(NSString*)urlString;

@end

