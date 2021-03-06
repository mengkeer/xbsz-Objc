//
//  ExerciseProgressViewController.h
//  xbsz
//
//  Created by lotus on 2017/4/27.
//  Copyright © 2017年 lotus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseMode.h"

typedef void (^ClickBlock)(NSInteger index);

@interface ExerciseProgressViewController : UIViewController

- (void)updateData:(ExerciseMode)mode
             total:(NSInteger )total
         practicedDic:(NSDictionary *)practicedDic
         judgedDic:(NSDictionary *)judgedDic
      currentIndex:(NSInteger) currentIndex
           clicked:(ClickBlock)clickBlock;

@end


@interface  ExerciseProgressCollectionViewCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *symbolLabel;


- (void)updateUIByQuestionIndex:(NSInteger)index;

//是否是当前焦点，根据跳转过来时的index判断
- (void)updateUIByQuestionIndex:(NSInteger)index isFocused:(BOOL)isFocused;
//设置当前题目已做完，但没判断正确
- (void)updateUIByQuestionIsSelected:(BOOL)isSelected;

- (void)updateUIByQuestionIsRight:(BOOL)isRight;

@end
