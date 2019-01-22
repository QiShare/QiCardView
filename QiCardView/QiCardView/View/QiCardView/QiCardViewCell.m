//
//  QiCardCell.m
//  QiShare
//
//  Created by QiShare on 2018/12/23.
//  Copyright © 2018 QiShare. All rights reserved.
//

#import "QiCardViewCell.h"

#define Qi_SNAPSHOTVIEW_TAG 999
#define Qi_DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

static CGFloat const Qi_DefaultDuration = 0.25f;
static CGFloat const Qi_SpringDuration = 0.5f;
static CGFloat const Qi_SpringWithDamping = 0.5f;
static CGFloat const Qi_SpringVelocity = 0.8f;

@interface QiCardViewCell()

@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation QiCardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super init];
    
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self setupView];
    }
    
    return self;
}

- (void)addCellSnapshotView {
    
    [self removeCellSnapshotView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
    snapshotView.tag = Qi_SNAPSHOTVIEW_TAG;
    snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:snapshotView];
    [self bringSubviewToFront:snapshotView];
}

- (void)removeCellSnapshotView {
    
    UIView *snapshotView = [self viewWithTag:Qi_SNAPSHOTVIEW_TAG];
    
    if (snapshotView) {
        [snapshotView removeFromSuperview];
    }
}

- (void)setupView {
    
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
    }
    self.contentView.clipsToBounds = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:pan];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.currentPoint = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint movePoint = [pan translationInView:pan.view];
            self.currentPoint = CGPointMake(self.currentPoint.x + movePoint.x , self.currentPoint.y + movePoint.y);
            
            CGFloat moveScale = self.currentPoint.x / self.maxRemoveDistance;
            if (ABS(moveScale) > 1.0) {
                moveScale = (moveScale > 0) ? 1.0 : -1.0;
            }
            CGFloat angle = Qi_DEGREES_TO_RADIANS(self.maxAngle) * moveScale;
            CGAffineTransform transRotation = CGAffineTransformMakeRotation(angle);
            self.transform = CGAffineTransformTranslate(transRotation, self.currentPoint.x, self.currentPoint.y);
            
            if (self.cell_delegate && [self.cell_delegate respondsToSelector:@selector(cardViewCellDidMoveFromSuperView:forMovePoint:)]) {
                [self.cell_delegate cardViewCellDidMoveFromSuperView:self forMovePoint:self.currentPoint];
            }
            [pan setTranslation:CGPointZero inView:pan.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self didPanStateEnded];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self restoreCellLocation];
            break;
        default:
            break;
    }
}

// 手势结束操作（不考虑上下位移）
- (void)didPanStateEnded {
    // 右滑移除
    if (self.currentPoint.x > self.maxRemoveDistance) {
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperview];
        
        CGFloat endCenterX = [UIScreen mainScreen].bounds.size.width/2 + self.frame.size.width * 1.5;
        [UIView animateWithDuration:Qi_DefaultDuration animations:^{
            CGPoint center = self.center;
            center.x = endCenterX;
            snapshotView.center = center;
        } completion:^(BOOL finished) {
            [snapshotView removeFromSuperview];
        }];
    }
    // 左滑移除
    else if (self.currentPoint.x < -self.maxRemoveDistance) {
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperview];
        
        CGFloat endCenterX = -([UIScreen mainScreen].bounds.size.width/2 + self.frame.size.width);
        [UIView animateWithDuration:Qi_DefaultDuration animations:^{
            CGPoint center = self.center;
            center.x = endCenterX;
            snapshotView.center = center;
        } completion:^(BOOL finished) {
            [snapshotView removeFromSuperview];
        }];
    }
    // 滑动距离不够归位
    else {
        [self restoreCellLocation];
    }
}

// 还原卡片位置
- (void)restoreCellLocation {
    
    [UIView animateWithDuration:Qi_SpringDuration delay:0
         usingSpringWithDamping:Qi_SpringWithDamping
          initialSpringVelocity:Qi_SpringVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

// 卡片移除处理
- (void)didCellRemoveFromSuperview {
    
    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
    if ([self.cell_delegate respondsToSelector:@selector(cardViewCellDidRemoveFromSuperView:)]) {
        [self.cell_delegate cardViewCellDidRemoveFromSuperView:self];
    }
}

- (void)removeFromSuperviewSwipe:(QiCardCellSwipeDirection)direction {
    
    switch (direction) {
        case QiCardCellSwipeDirectionLeft: {
            [self removeFromSuperviewLeft];
        }
            break;
        case QiCardCellSwipeDirectionRight: {
            [self removeFromSuperviewRight];
        }
            break;
        default:
            break;
    }
}

// 向左边移除动画
- (void)removeFromSuperviewLeft {
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperview];
    
    CGAffineTransform transRotation = CGAffineTransformMakeRotation(-Qi_DEGREES_TO_RADIANS(self.maxAngle));
    CGAffineTransform transform = CGAffineTransformTranslate(transRotation, 0, self.frame.size.height/4.0);
    CGFloat endCenterX = -([UIScreen mainScreen].bounds.size.width/2 + self.frame.size.width);
    [UIView animateWithDuration:Qi_DefaultDuration animations:^{
        CGPoint center = self.center;
        center.x = endCenterX;
        snapshotView.center = center;
        snapshotView.transform = transform;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
    }];
}

// 向右边移除动画
- (void)removeFromSuperviewRight {
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = self.frame;
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperview];
    
    CGAffineTransform transRotation = CGAffineTransformMakeRotation(Qi_DEGREES_TO_RADIANS(self.maxAngle));
    CGAffineTransform transform = CGAffineTransformTranslate(transRotation, 0, self.frame.size.height/4.0);
    CGFloat endCenterX = [UIScreen mainScreen].bounds.size.width/2 + self.frame.size.width * 1.5;
    [UIView animateWithDuration:Qi_DefaultDuration animations:^{
        CGPoint center = self.center;
        center.x = endCenterX;
        snapshotView.center = center;
        snapshotView.transform = transform;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
    }];
}

@end
