//
//  QiCardView.m
//  QiShare
//
//  Created by QiShare on 2018/12/23.
//  Copyright © 2018 QiShare. All rights reserved.
//

#import "QiCardView.h"

static CGFloat const Qi_DefaultAnimationDuration = 0.25f;

static int moveCount = 0;//!< 记录翻页次数

@interface QiCardView() <QiCardViewCellDelagate>

/** 注册cell相关 */
@property (nonatomic, strong) UINib *nib;
@property (nonatomic, copy) Class cellClass;
@property (nonatomic, copy) NSString *identifier;//!< 复用ID

@property (nonatomic, strong) UIView *containerView;//!< cell容器
@property (nonatomic, assign) NSInteger currentIndex;//!< 当前索引(已显示的最大索引)
@property (nonatomic, strong) NSArray<__kindof QiCardViewCell *> *visibleCells;//!< 当前可视cells
@property (nonatomic, strong) NSMutableArray<__kindof QiCardViewCell *> *reusableCells;//!< 重用卡片数组

@end

@implementation QiCardView

- (UIView *)containerView {
    
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_containerView];
    }
    
    return _containerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configCardView];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configCardView];
}

//! 配置CardView
- (void)configCardView {
    
    _visibleCount      = 3;
    _lineSpacing       = 10.0;
    _interitemSpacing  = 10.0;
    _maxAngle          = 15;
    _maxRemoveDistance = [UIScreen mainScreen].bounds.size.width / 4.0;
    _reusableCells     = [NSMutableArray array];
    _isAlpha = YES;
}

- (void)reloadData {
    [self reloadDataAnimated:NO];
}

- (void)reloadDataAnimated:(BOOL)animated {
    
    moveCount = 0;//!< 渐变需要
    
    self.currentIndex = 0;
    [self.reusableCells removeAllObjects];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger maxCount = [self.dataSource numberOfCountInCardView:self];
    NSInteger showNumber = MIN(maxCount, self.visibleCount);
    for (int i = 0; i < showNumber; i++) {
        [self createCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

/** 创建新的cell */
- (void)createCardViewCellWithIndex:(NSInteger)index {
    
    QiCardViewCell *cell = [self.dataSource cardView:self cellForRowAtIndex:index];
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    cell.maxRemoveDistance = self.maxRemoveDistance;
    cell.maxAngle = self.maxAngle;
    cell.cell_delegate = self;
    cell.userInteractionEnabled = NO;
    NSInteger showCount = self.visibleCount - 1;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - (showCount * self.interitemSpacing);
    cell.frame = CGRectMake(0, 0, width, height);
    [self.containerView insertSubview:cell atIndex:0];
    [self.containerView layoutIfNeeded];
    self.currentIndex = index;
    
    CGFloat minWidth = self.frame.size.width - 2 * self.lineSpacing * showCount;
    CGFloat minHeight = self.frame.size.height - 2 * self.interitemSpacing * showCount;
    CGFloat minWScale = minWidth / self.frame.size.width;
    CGFloat minHScale = minHeight / self.frame.size.height;
    CGFloat yOffset = (self.interitemSpacing / minHScale) * 2 *showCount;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(minWScale, minHScale);
    CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, yOffset);
    cell.transform = transform;
}

/** 更新布局（动画） */
- (void)updateLayoutVisibleCellsWithAnimated:(BOOL)animated {
    
    NSInteger showCount = self.visibleCount - 1;
    CGFloat minWidth = self.frame.size.width - 2 * self.lineSpacing * showCount;
    CGFloat minHeight = self.frame.size.height - 2 * self.interitemSpacing * showCount;
    CGFloat minWScale = minWidth / self.frame.size.width;
    CGFloat minHScale = minHeight / self.frame.size.height;
    CGFloat itemWScale = (1.0 - minWScale) / showCount;
    CGFloat itemHScale = (1.0 - minHScale) / showCount;
    NSInteger count = self.visibleCells.count;
    
    for (NSInteger i = 0; i < count; i ++) {
        // 计算出最终效果的transform
        NSInteger showIndex = count - i - 1;
        CGFloat wScale = 1.0 - showIndex * itemWScale;
        CGFloat hScale = 1.0 - showIndex * itemHScale;
        CGFloat y = (self.interitemSpacing / hScale) * 2 * showIndex;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(wScale, hScale);
        CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, y);
        // 获取当前要显示的的cells
        QiCardViewCell *cell = self.visibleCells[i];
        // 判断是不是当前显示的最后一个(最上层显示)
        BOOL isVisbleLast = (i == (count - 1));
        if (isVisbleLast) {
            cell.userInteractionEnabled = YES;
            if ([self.delegate respondsToSelector:@selector(cardView:didDisplayCell:forRowAtIndex:)]) {
                [self.delegate cardView:self didDisplayCell:cell forRowAtIndex:(self.currentIndex-i)];
            }
        }
        
        if (animated) {
            [self updateConstraintsCell:cell transform:transform];
        } else {
            cell.transform = transform;
        }
        
//        NSLog(@"i = %ld", (long)i);
//        NSLog(@"currentIndex = %ld", (long)_currentIndex);
//        NSLog(@"moveCount = %d", moveCount);
//        NSLog(@"visibleCells.count = %lu", (unsigned long)self.visibleCells.count);
        
        if (_isAlpha) {
            BOOL isTopCell = (i == _currentIndex - moveCount);
            if (isTopCell) {//!< 如果是最上面的Cell就透明度为1
                cell.alpha = 1.0;
            } else {
                cell.alpha = (i + 1.9) * 1.0/self.visibleCells.count;
            }
        }
    }
}

- (void)updateConstraintsCell:(QiCardViewCell*)cell transform:(CGAffineTransform)transform {
    [UIView animateWithDuration:Qi_DefaultAnimationDuration animations:^{
        cell.transform = transform;
    } completion:nil];
}

/** 当前最上层索引 */
- (NSInteger)currentFirstIndex {
    return self.currentIndex - self.visibleCells.count + 1;
}

/** 数据源索引转换为对应的显示索引 */
- (NSInteger)visibleIndexAtIndex:(NSInteger)index {
    NSInteger visibleIndex = index - self.currentFirstIndex;
    return visibleIndex;
}

/** 可视cells */
- (NSArray<QiCardViewCell *> *)visibleCells {
    return self.containerView.subviews;
}

/** 注册cell方法一：Nib */
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    self.nib = nib;
    self.identifier = identifier;
}

/** 注册cell方法二：Class */
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    self.cellClass = cellClass;
    self.identifier = identifier;
}

/** 获取缓存cell */
- (__kindof QiCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    for (QiCardViewCell *cell in self.reusableCells) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            [self.reusableCells removeObject:cell];
            
            return cell;
        }
    }
    if (self.nib) {
        QiCardViewCell *cell = [[self.nib instantiateWithOwner:nil options:nil] lastObject];
        cell.reuseIdentifier = identifier;
        
        return cell;
    } else if (self.cellClass) { // 注册class
        QiCardViewCell *cell = [[self.cellClass alloc] initWithReuseIdentifier:identifier];
        cell.reuseIdentifier = identifier;
        
        return cell;
    }
    return nil;
}

/** 获取index对应的cell */
- (nullable __kindof QiCardViewCell *)cellForRowAtIndex:(NSInteger)index {
    NSInteger visibleIndex = [self visibleIndexAtIndex:index];
    QiCardViewCell *cell = [self.visibleCells objectAtIndex:visibleIndex];
    
    return cell;
}

/** 获取cell对应的index */
- (NSInteger)indexForCell:(QiCardViewCell *)cell {
    NSInteger visibleIndex = [self.visibleCells indexOfObject:cell];
    
    return (self.currentIndex - visibleIndex);
}

/** 移除最上层cell */
- (void)removeTopCardViewFromSwipe:(QiCardCellSwipeDirection)direction {
    if(self.visibleCells.count == 0) return;
    QiCardViewCell *topcell = [self.visibleCells lastObject];
    [topcell removeFromSuperviewSwipe:direction];
}


#pragma mark - QiCardViewCellDelagate

- (void)cardViewCellDidRemoveFromSuperView:(QiCardViewCell *)cell {
    
    moveCount++;
    
    // 当cell被移除时重新刷新视图
    [self.reusableCells addObject:cell];
    
    // 通知代理 移除了当前cell
    if ([self.delegate respondsToSelector:@selector(cardView:didRemoveCell:forRowAtIndex:)]) {
        [self.delegate cardView:self didRemoveCell:cell forRowAtIndex:self.currentFirstIndex - 1];
    }
    
    NSInteger count = [self.dataSource numberOfCountInCardView:self];
    // 移除后的卡片是最后一张(没有更多)
    if(self.visibleCells.count == 0) { // 只有最后一张卡片的时候
        moveCount = 0;
        if ([self.delegate respondsToSelector:@selector(cardView:didRemoveLastCell:forRowAtIndex:)]) {
            [self.delegate cardView:self didRemoveLastCell:cell forRowAtIndex:self.currentIndex];
        }
        return;
    }
    // 当前数据源还有数据 继续创建cell
    if (self.currentIndex < count - 1) {
        [self createCardViewCellWithIndex:(self.currentIndex + 1)];
    }
    // 更新布局
    [self updateLayoutVisibleCellsWithAnimated:YES];
}

- (void)cardViewCellDidMoveFromSuperView:(QiCardViewCell *)cell forMovePoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(cardView:didMoveCell:forMovePoint:)]) {
        [self.delegate cardView:self didMoveCell:cell forMovePoint:point];
    }
}

- (void)didMoveToSuperview {
    [self reloadData];
}

//- (void)didMoveToWindow {
//    [self reloadData];
//}

@end
