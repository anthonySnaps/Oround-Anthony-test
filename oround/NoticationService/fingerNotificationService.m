//
//  fingerNotificationService.m
//  finger
//
//  Created by wondriver on 19/10/2018.
//  Copyright © 2018 wondriver. All rights reserved.
//

//2021.05.14  syncFingerDataWithGroup


#import "fingerNotificationService.h"


API_AVAILABLE(ios(10.0))
@interface fingerNotificationService () {
//    BOOL isDisableSyncBadge;
    BOOL isSyncBadge;
}



@end

@implementation fingerNotificationService
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSString *attachmentUrlString = [self.bestAttemptContent.userInfo objectForKey:@"imgUrl"];
    
    NSURL *url = [NSURL URLWithString:attachmentUrlString];
    if (!url){  //이미지가 없을 경우
        [self showNoti];
        return;
    }
    
    [[[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
        if (!error) {
            NSString *tempDict = NSTemporaryDirectory();
            NSString *attachmentID = [self.bestAttemptContent.userInfo objectForKey:@"msgTag"];
            
            NSString *tempFilePath = [tempDict stringByAppendingPathComponent:attachmentID];
            
            if(response.suggestedFilename)
                tempFilePath = [tempDict stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingString:response.suggestedFilename]];
            
            
            if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:tempFilePath error:&error]) {
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:attachmentID URL:[NSURL fileURLWithPath:tempFilePath] options:nil error:&error];
                
                if (attachment) {
                    self->_bestAttemptContent.attachments = [self->_bestAttemptContent.attachments arrayByAddingObject:attachment];
                } else {
                    NSLog(@"Create attachment error: %@", error);
                }
            } else {
                NSLog(@"Move file error: %@", error);
            }
            
        } else {
            NSLog(@"Download file error: %@", error);
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showNoti];
        }];
        
    }] resume];
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
   [self showNoti];
    NSLog(@"serviceExtensionTimeWillExpire");
}



-(void)recvPush {
    NSString *url_Rcv = [self.bestAttemptContent.userInfo objectForKey:@"rcvchkUrl"];
    if(url_Rcv) {
        if(url_Rcv.length > 0) {
            NSURL *url_ = [NSURL URLWithString:url_Rcv];
            [[[NSURLSession sharedSession] dataTaskWithURL:url_
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             NSLog(@"finger ===>> response: %@",response);
                                             if (!error) {
                                                 // Success
                                                 if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                     NSError *jsonError;
                                                     if (jsonError) {
                                                         // Error Parsing JSON
                                                     }
                                                 }
                                             } else {
                                                 // Fail
                                                 NSLog(@"inger ===>>  error : %@", error.description);
                                             }
                                        }
              ]
             resume];            
        }
    }
}


-(void)showNoti {
    [self recvPush];
    
    if(!isSyncBadge) {
         self.contentHandler(self.bestAttemptContent);
    } else {
        if([self.bestAttemptContent.badge intValue] == 0) {
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
                self.bestAttemptContent.badge = [NSNumber numberWithInteger:notifications.count+1];
                self.contentHandler(self.bestAttemptContent);
            }];
        } else {
            self.contentHandler(self.bestAttemptContent);
        }
    }
}

-(void)disableSyncBadge {
    isSyncBadge = NO;
}

-(void)enableSyncBadge {
    isSyncBadge = YES;
}

@end
