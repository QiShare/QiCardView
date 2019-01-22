//
//  QiCardView.h
//  QiShare
//
//  Created by QiShare on 2018/12/23.
//  Copyright © 2018 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiCardViewCell.h"

@class QiCardView;

@protocol QiCardViewDataSource<NSObject>

@required
- (NSInteger)numberOfCountInCardView:(QiCardView *)cardView;
- (QiCardViewCell *)cardView:(QiCardView *)cardView cellForRowAtIndex:(NSInteger)index;

@end


@protocol QiCardViewDelegate<NSObject>
@optional

- (void)cardView:(QiCardView *)cardView didRemoveCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index;
- (void)cardView:(QiCardView *)cardView didRemoveLastCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index;
- (void)cardView:(QiCardView *)cardView didDisplayCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index;
- (void)cardView:(QiCardView *)cardView didMoveCell:(QiCardViewCell *)cell forMovePoint:(CGPoint)point;

@end


@interface QiCardView : UIView

@property (nonatomic, readonly) NSArray<__kindof QiCardViewCell *> *visibleCells;//!< 当前可视cells
@property (nonatomic, readonly) NSInteger currentFirstIndex;//!< 当前显示最上层索引
@property (nonatomic, weak) id<QiCardViewDataSource> dataSource;//!< 数据源
@property (nonatomic, weak) id<QiCardViewDelegate> delegate;//!< 代理
@property (nonatomic, assign) NSInteger visibleCount;//!< 卡片可见数量(默认3)
@property (nonatomic, assign) CGFloat lineSpacing;//!< 行间距(默认10.0，可自行计算scale比例来做间距)
@property (nonatomic, assign) CGFloat interitemSpacing;//!< 列间距(默认10.0，可自行计算scale比例来做间距)
@property (nonatomic, assign) CGFloat maxAngle;//!< 侧滑最大角度(默认15°)
@property (nonatomic, assign) CGFloat maxRemoveDistance;//!< 最大移除距离(默认屏幕的1/4)
@property (nonatomic, assign) BOOL isAlpha;//!< cardCell是否需要透明度（默认YES）

//! 重载数据
- (void)reloadData;
- (void)reloadDataAnimated:(BOOL)animated;

//! 注册cell
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

//! 获取缓存cell
- (__kindof QiCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

//! 获取index对应的cell
- (nullable __kindof QiCardViewCell *)cellForRowAtIndex:(NSInteger)index;

//! 获取cell对应的index
- (NSInteger)indexForCell:(QiCardViewCell *)cell;

//! 移除最上层cell
- (void)removeTopCardViewFromSwipe:(QiCardCellSwipeDirection)direction;

@end
