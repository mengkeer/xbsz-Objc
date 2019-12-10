//
//  QuestionCollectionViewCell.m
//  xbsz
//
//  Created by lotus on 2017/4/25.
//  Copyright © 2017年 lotus. All rights reserved.
//

#import "QuestionCollectionViewCell.h"
#import "CXBaseTableView.h"
#import "ExerciseQuestion.h"
#import "FMDBUtil.h"
#import "QuestionTableViewCell.h"
#import "QuestionTitleLabel.h"

static NSString *cellID = @"QuestionTableViewCellID";

static NSInteger TitlePaddingLeft = 8;
static NSInteger TitlePaddingRight = 5;

@interface QuestionCollectionViewCell () <CXBaseTableViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) CXBaseTableView *tableView;

@property (nonatomic, strong) QuestionTitleLabel *titleLabel;

@property (nonatomic, strong) UIView *titleLeftView;

@property (nonatomic, strong) ExerciseQuestion *question;

@property (nonatomic, strong) NSArray *options;     //各个选项内容

@property (nonatomic, assign) BOOL isSingle;        //是否是单选

@property (nonatomic, assign) BOOL showRightAnswer;         //是否显示正确答案  用于预览模式

@property (nonatomic, assign) NSInteger selectedIndex;          //当前点击索引

@property (nonatomic, copy) NSString *selectedIndexs;           //临时选择时的索引

@property (nonatomic, assign) BOOL  showSinglePracticeResult;         //是否显示结果   用于练习模式，即做题的情况下

@property (nonatomic, assign) BOOL showMutiPracticeResult;

@property (nonatomic, assign) BOOL showTemporarySelected;

@property (nonatomic, assign) BOOL allowSelect;

@end

@implementation QuestionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initCollectionCell];
    }
    return self;
}

- (void)initCollectionCell{
    
    [self.contentView addSubview:self.scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.contentView);
    }];
    
    [self.contentView layoutIfNeeded];
    
    [_scrollView addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).mas_offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-15);
        make.top.mas_equalTo(_scrollView.mas_top).mas_offset(15);
        make.height.mas_equalTo(25);
    }];
    
    _titleLeftView = [[UIView alloc] init];
    _titleLeftView.backgroundColor = CXHexColor(0x08b292);
    [_scrollView addSubview:_titleLeftView];
    [_titleLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(_titleLabel);
        make.width.mas_equalTo(2);
    }];
    
    
    [_scrollView addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(15);
        make.left.right.bottom.mas_equalTo(self.contentView);
    }];
    
}

#pragma mark - getter/setter

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [CXUserDefaults instance].bgColor;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (QuestionTitleLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[QuestionTitleLabel alloc] initWithInsets:UIEdgeInsetsMake(TitlePaddingRight, TitlePaddingLeft, TitlePaddingRight, TitlePaddingRight)];
        _titleLabel.font = CXSystemFont([CXUserDefaults instance].questionFontSize);
        _titleLabel.textColor = CXTextGrayColor;
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [CXUserDefaults instance].bgColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (CXBaseTableView *)tableView{
    if(!_tableView){
        _tableView = [[CXBaseTableView alloc] initWithFrame:CGRectZero enablePullRefresh:NO];
        _tableView.baseDelegate = self;
        _tableView.backgroundColor = [CXUserDefaults instance].bgColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = YES;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.row;
    if(_baseDelegate && [_baseDelegate respondsToSelector:@selector(selectOption:)]){
        [_baseDelegate selectOption:indexPath.row];
    }
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.2f];
}

- (void)deselect{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID isSingle:_isSingle];
    }
    cell.backgroundColor = [CXUserDefaults instance].bgColor;
    cell.contentView.backgroundColor = [CXUserDefaults instance].bgColor;
//    if(_allowSelect == YES){
//        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    
    [cell updateUIWithIndex:indexPath.row option:[_options objectAtIndex:indexPath.row] isSingle:_isSingle];
    
    //预览模式下显示正确的答案
    if(_showRightAnswer == YES){
        [cell showSingleRightAnswer:indexPath.row answer:_question.answer];
    }
    //练习模式下显示单选正确答案
    if(_showSinglePracticeResult){
        [cell showSinglePracticeResult:indexPath.row selectedIndex:_selectedIndex answer:_question.answer];
    }
    //练习模式下显示多选正确答案
    if(_showMutiPracticeResult){
        [cell showMutiPracticeResult:indexPath.row selectedIndex:_selectedIndexs answer:_question.answer];
    }
    //设置临时选中效果
    if(_showTemporarySelected){
        [cell setTemporarySelected:indexPath.row selectedIndexs:_selectedIndexs];
    }
    return cell;
}

#pragma mark - public method

- (void)updateUIByQuestion:(ExerciseQuestion *)question{
    _question = question;
    _showRightAnswer = NO;
    _showSinglePracticeResult = NO;
    _showMutiPracticeResult = NO;
    _showTemporarySelected = NO;
    _allowSelect = YES;
    
    NSInteger textHeight = [self getTitleHeight:question.title];
        
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    [_titleLeftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    
    _options = [FMDBUtil getOptionsByString:question.option type:question.type];          //获取各个选项
    _isSingle = question.type == 2 ? NO : YES;
    
    [_tableView reloadData];
}

- (void)updateUIByQuestion:(ExerciseQuestion *)question allowSelect:(BOOL)allowSelect{
    _question = question;
    _showRightAnswer = NO;
    _showSinglePracticeResult = NO;
    _showMutiPracticeResult = NO;
    _showTemporarySelected = NO;
    _allowSelect = allowSelect;
    
    NSInteger textHeight = [self getTitleHeight:question.title];
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    [_titleLeftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    
    _options = [FMDBUtil getOptionsByString:question.option type:question.type];          //获取各个选项
    _isSingle = question.type == 2 ? NO : YES;
    
    [_tableView reloadData];
}

- (void)updateUIByQuestion:(ExerciseQuestion *)question showRightAnswer:(BOOL)showRgihtAnswer{
    _question = question;
    _showRightAnswer = showRgihtAnswer;
    _showSinglePracticeResult = NO;
    _showMutiPracticeResult = NO;
    _showTemporarySelected = NO;
    _allowSelect = NO;
    
    NSInteger textHeight = [self getTitleHeight:question.title];
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    [_titleLeftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    
    _options = [FMDBUtil getOptionsByString:question.option type:question.type];          //获取各个选项
    _isSingle = question.type == 2 ? NO : YES;
    
    [_tableView reloadData];
}

- (BOOL)showSinglePracticeAnswer:(NSInteger)selectIndex{
    _showSinglePracticeResult = YES;
    _showMutiPracticeResult = NO;
    _showTemporarySelected = NO;
    _allowSelect = NO;
    _selectedIndex = selectIndex;
    [_tableView reloadData];
    return [FMDBUtil isSingleRightAnswer:selectIndex answer:_question.answer];
}

- (BOOL)showMutiPracticeAnswer:(NSString *)selectIndexs{
    _showSinglePracticeResult = NO;
    _showMutiPracticeResult = YES;
    _showTemporarySelected = NO;
    _allowSelect = NO;
    _selectedIndexs = selectIndexs;
    [_tableView reloadData];
    return [FMDBUtil isMutiRightAnswer:selectIndexs answer:_question.answer];
}


- (void)setTemporarySelected:(NSString *)selectedIndexs{
    _selectedIndexs = selectedIndexs;
    _showTemporarySelected = YES;
    [_tableView reloadData];
}


- (NSInteger)getTitleHeight:(NSString *)text{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    _titleLabel.attributedText = attributedString;
    
    CGSize size = CGSizeMake(CXScreenWidth-15*2 -TitlePaddingLeft-TitlePaddingRight, CGFLOAT_MAX);
    CGRect labelRect = [text boundingRectWithSize:size
                                                    options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:CXSystemFont([CXUserDefaults instance].questionFontSize),NSParagraphStyleAttributeName:paragraphStyle} context:nil] ;
    
    NSInteger textHeight = (int)CGRectGetHeight(labelRect)+1+TitlePaddingRight*2;
    
    return textHeight;
}

@end
