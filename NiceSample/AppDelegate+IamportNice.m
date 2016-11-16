//
//  AppDelegate+IamportNice.m
//  WebView
//
//  Created by SIOT on 2015. 5. 22..
//  Copyright (c) 2015년 user. All rights reserved.
//

#import "AppDelegate.h"
#define MY_APP_URL_KEY  @"iamporttest://"

@implementation AppDelegate (IamportNice)
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString* redirectURL = [NSString stringWithString:[url absoluteString]];
    
    if(redirectURL !=  nil) {
        if([redirectURL hasPrefix:MY_APP_URL_KEY]) { //scheme 를 통한 호출 여부
            //결제인증 후 복귀했을 때 후속조치를 하기 위해 각 수단별 URL을 추출하는 단계
            
            //(1)실시간계좌이체 인증 후 추출된 주소를 통해 후속조치 함수 호출
            NSRange range = [redirectURL rangeOfString:@"?bankpaycode"];    //계좌이체 인경우
            if(range.location != NSNotFound) { //계좌이체 인증 후 거래 진행
                
                //[MY_APP_URL_KEY length]+1 => 계좌이체인 경우  scheme + ? 로 리던 되어 "?" 도 함께 삭제 함.
                //iamporttest://?bankpaycode=xxxx ...." 에서 "bankpaycode=xxxx ...." 추출하기 위함
                redirectURL = [redirectURL substringFromIndex:[MY_APP_URL_KEY length]+1];
                [self.webViewController requestBankPayResult:redirectURL];
                return YES;
            }
            
            //(2)ISP인증과정 도중 결제 취소를 선택한 경우 별도 처리
            range = [redirectURL rangeOfString:@"ISPCancel"];
            if(range.location != NSNotFound) { //ISP 취소인 경우
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"알림"
                                                                    message:@"결제를 취소하셨습니다."
                                                                   delegate:self cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil];
                alertView.tag = 900;
                [alertView show];
                return YES;
            }
            
            //(3)추출된 주소를 통해 ISP결제 후속조치 함수 호출
            range = [redirectURL rangeOfString:@"ispResult.jsp"];
            if(range.location != NSNotFound) { //ISP 인증 후 결제 진행
                //[MY_APP_URL_KEY length]+3 => ISP 경우  scheme + :// 로 리턴 되어 "://" 도 함께 삭제 함.
                //  iamporttest://://http://web.nicepay.co.kr/smart/card/isp/ .... ispResult.jsp 에서
                // http://web.nicepay.co.kr/smart/card/isp/.... ispResult.jsp" 추출하기 위함
                redirectURL = [redirectURL substringFromIndex:[MY_APP_URL_KEY length]+3];
                
                [self.webViewController requesIspPayResult:redirectURL];
                return YES;
            }
        }
    }

    return YES;
}
@end