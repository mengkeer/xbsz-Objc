//
//  CXUser.m
//  xbsz
//
//  Created by 陈鑫 on 17/2/24.
//  Copyright © 2017年 lotus. All rights reserved.
//

#import "CXUser.h"

@implementation CXUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"username":@"userName",@"truename":@"trueName",@"studentID":@"studentId"};
}

@end
