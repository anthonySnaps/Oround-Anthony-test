//
//  fingerNotificationService.h
//  finger
//
//  Created by wondriver on 19/10/2018.
//  Copyright © 2018 wondriver. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>



API_AVAILABLE(ios(10.0))
@interface fingerNotificationService : UNNotificationServiceExtension

-(void)disableSyncBadge;

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end


