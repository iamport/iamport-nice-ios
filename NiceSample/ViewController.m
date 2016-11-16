//
//  ViewController.m
//  WebView
//
//  Created by user on 2015. 5. 22..
//  Copyright (c) 2015년 user. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
//@synthesize webView = _webView;
@synthesize bankPayUrlString;


- (void) requestBankPayResult:(NSString*)bodyString
{
    //bankPayUrlString 계좌이체 인증 결과 url
    NSURL *url = [NSURL URLWithString: bankPayUrlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [bodyString dataUsingEncoding: NSUTF8StringEncoding]];
    [_webView loadRequest: request];
}

- (void) requesIspPayResult:(NSString*)urlString
{
    //isp인증 후 복귀했을 때 결제 후속조치
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"GET"];
    [_webView loadRequest: request];
}

-(void)viewWillAppear:(BOOL)animated
{
    _webView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.webViewController = self;
    
    
    NSString *urlString = @"http://www.iamport.kr/demo";
    //NSString *urlString = @"http://dservice.iamport.kr/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    _webView.scalesPageToFit = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //_webView.scalesPageToFit = YES;
    //현재 URL 을 읽음
    NSString* URLString = [NSString stringWithString:[request.URL absoluteString]];
    
    NSLog(@"current URL %@",URLString);
    
    //app store URL 여부 확인
    BOOL goAppStore =  ([URLString rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL goAppStore2 =  ([URLString rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    
    //app store 로 연결하는 경우 앱스토어 APP을 열어 준다. (isp, bank app 이 설치하고자 경우)
    if(goAppStore || goAppStore2){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    //isp App을 호출하는 경우
    /*if([URLString hasPrefix:@"ispmobile://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {  //설치 되어 있을 경우 isp App 호출
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        else {    //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:99];
            return NO;
        }
        
    }*/
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    [dic objectForKey:@""];
    
    //계좌이체
    if([URLString hasPrefix:@"kftc-bankpay://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            
            NSRange range = [URLString rangeOfString:@"callbackparam1="];
            if(range.location != NSNotFound) {
                int cutIdx = range.location + [@"callbackparam1=" length];
                URLString = [URLString substringFromIndex:cutIdx];
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&(?!\\?)" options:NSRegularExpressionCaseInsensitive error:&error];
                NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:URLString options:0 range:NSMakeRange(0, [URLString length])];
                
                self.bankPayUrlString = [regex stringByReplacingMatchesInString: URLString
                                                                        options: 0
                                                                          range: rangeOfFirstMatch
                                                                   withTemplate: @"?"];
                
                NSLog(@"bankPayUrlString: %@",self.bankPayUrlString);
            }
            [[UIApplication sharedApplication] openURL:request.URL]; //설치 되어 있을 경우 App 호출
        }
        else {
            //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"Bank Pay가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:88];
            return NO;
        }
    }
    return YES;
}

- (void) showAlertViewWithMessage:(NSString*)msg tagNum:(NSInteger)tag
{
    
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"알림"
                                                message:msg
                                               delegate:self
                                      cancelButtonTitle:@"확인"
                                      otherButtonTitles:nil];
    
    v.tag = tag;
    
    [v show];
//    [v release];
}


#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 99)
    {
        NSString* URLString = @"https://itunes.apple.com/app/mobail-gyeolje-isp/id369125087?mt=8";
        NSURL* storeURL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:storeURL];
    }
    else if(alertView.tag == 88)
    {
        NSString* URLString = @"https://itunes.apple.com/app/eunhaeng-gongdong-gyejwaiche/id398456030?mt=8";
        NSURL* storeURL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:storeURL];
        
    }
}


@end
