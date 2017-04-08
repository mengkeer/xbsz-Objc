//
//  UIViewController+Authorization.h
//  xbsz
//
//  Created by 陈鑫 on 17/3/24.
//  Copyright © 2017年 lotus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Authorization)
//相机是否授权
- (BOOL)cameraAuthorization;
//相册是否授权
- (BOOL)albumAuthorization;

@end
