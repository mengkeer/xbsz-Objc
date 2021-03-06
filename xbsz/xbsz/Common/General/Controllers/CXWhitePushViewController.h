//
//  CXWhitePushViewController.h
//  xbsz
//
//  Created by lotus on 14/03/2017.
//  Copyright © 2017 lotus. All rights reserved.
//

#import "CXBaseViewController.h"

@interface CXWhitePushViewController : CXBaseViewController

@property (nonatomic,strong) UIView *customNavBarView;
@property (nonatomic,assign) BOOL showTopRadius;

@property (nonatomic, strong) UILabel *titleLabel;

- (float)getStartOriginY;

- (float)getContentViewHeight;

- (void)popFromCurrentViewController;

- (void)setCustomNavBarHidden:(BOOL)hidden;

- (void)showTopLineView;

@end
