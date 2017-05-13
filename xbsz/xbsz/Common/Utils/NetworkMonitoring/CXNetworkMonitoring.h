//
//  CXNetworkMonitoring.h
//  idemo
//
//  Created by lotus on 06/12/2016.
//  Copyright © 2016 lotus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXNetworkMonitoring : NSObject

+ (AFNetworkReachabilityStatus)currentStatus;

+ (BOOL)canReachable;

+ (BOOL)wifiOnly;

+ (void)startNetworkMonitoring;

@end
