//
//  QiCardCell.h
//  QiShare
//
//  Created by QiShare on 2018/12/23.
//  Copyright © 2018 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QiCardViewCell;

@protocol QiCardViewCellDelagate <NSObject>

@optional
- (void)cardViewCellDidRemoveFromSuperView:(QiCardViewCell *)cell;
- (void)cardViewCellDidMoveFromSuperView:(QiCardViewCell*)cell forMovePoint:(CGPoint)point;

@end


typedef NS_ENUM(NSInteger,QiCardCellSwipeDirection) {
    QiCardCellSwipeDirectionLeft = 0,
    QiCardCellSwipeDirectionRight,
};


@interface QiCardViewCell : UIView

@property (nonatomic, strong) UIView *contentView;//!< 内容视图
@property (nonatomic, copy) NSString *reuseIdentifier;//!< 重用标识

@property (nonatomic, assign) CGFloat maxAngle;
@property (nonatomic, assign) CGFloat maxRemoveDistance;
@property (nonatomic, weak) id<QiCardViewCellDelagate> cell_delegate;

/*!
 @brief 初始化方法
 @param reuseIdentifier 复用id
 @return self
 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

/*!
 @brief 移除cell
 @param direction 移除方向
 */
- (void)removeFromSuperviewSwipe:(QiCardCellSwipeDirection)direction;

@end
