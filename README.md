>前言：因项目中需求，需要做一个卡片式控件。故QiCardView诞生了。

首先，先来看一下QiCardView的效果图：

![](https://upload-images.jianshu.io/upload_images/3407530-cf1ca493e8def639.gif?imageMogr2/auto-orient/strip)

从命名来看，QiCardView，顾名思义，是一个可定制的卡片式UI控件。
从设计来看，QiCardView仿照UITableView的设计，支持cell复用，节省了资源。

话不多说，先来看下整体架构~

### 一、QiCardView整体架构设计

架构层面仿照了`UITableView`的设计，采用了cell复用策略。
在此基础上，融入了一些手势操作，更加富有交互性。

上架构图：

![](https://upload-images.jianshu.io/upload_images/3407530-2a025b627b9d3a5b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

两个主类分别为`QiCardView`与`QiCardViewCell`。（仿照`UITableView`+`UITableViewCell`的设计）

- **`QiCardView`** 下有两个代理：`QiCardViewDataSource`、`QiCardViewDelegate`。（与UITableView的代理方法类似）
- **`QiCardViewCell`** 下有一个代理：`QiCardViewCellDelegate`。（这个代理可以不关心，主要目的是辅助QiCardView里的一些处理逻辑）

### 二、如何自定义使用QiCardView？

Cell自定义很简单，只要新建一个类（例如：`QiCardViewItemCell`）继承自`QiCardViewCell`即可。

在Controller中，基本使用上几乎与`UITableView`类似。

- 初始化`CardView`方法：

在上Demo之前，先介绍几个可以自定义的配置属性：

属性| 类型 | 介绍
-----|-----|-----
visibleCount | NSInteger | 卡片Cell可见数量(默认3)。因为有复用策略，所以即实际创建的Cell数量。
lineSpacing | CGFloat | 行间距(默认10.0，可自行计算scale比例来做间距)
interitemSpacing | CGFloat | 列间距(默认10.0，可自行计算scale比例来做间距)
maxAngle | CGFloat | 侧滑最大角度(默认15°)。值约小越容易划出，越大约不好划出。
maxRemoveDistance | CGFloat | 最大移除距离(默认屏幕的1/4)，滑动距离不够时归位。
isAlpha | CGFloat | cell是否需要渐变透明度。（默认YES）

```initCardView
- (void)initViews {
    
    _cardView = [[QiCardView alloc] initWithFrame:CGRectMake(25.0, 150.0, self.view.frame.size.width - 50.0, 420.0)];
    _cardView.backgroundColor = [UIColor lightGrayColor];//!< 为了指出carddView的区域，指明背景色
    _cardView.dataSource = self;
    _cardView.delegate = self;
    _cardView.visibleCount = 4;
    _cardView.lineSpacing = 15.0;
    _cardView.interitemSpacing = 10.0;
    _cardView.maxAngle = 10.0;
    _cardView.isAlpha = YES;
    _cardView.maxRemoveDistance = 100.0;
    _cardView.layer.cornerRadius = 10.0;
    [_cardView registerClass:[QiCardItemCell class] forCellReuseIdentifier:qiCardCellId];
    [self.view addSubview:_cardView];
}
```
- 数据源：`QiCardViewDataSource`：
首先controller要遵守协议：`<QiCardViewDataSource>`

```QiCardViewDataSource
#pragma mark - QiCardViewDataSource

- (QiCardItemCell *)cardView:(QiCardView *)cardView cellForRowAtIndex:(NSInteger)index {
    
    QiCardItemCell *cell = [cardView dequeueReusableCellWithIdentifier:qiCardCellId];
    cell.cellData = _cellItems[index];
    //...

    return cell;
}

- (NSInteger)numberOfCountInCardView:(UITableView *)cardView {
    return _cellItems.count;
}
```

- 代理：`QiCardViewDelegate`：
还是首先controller需要遵守协议：`<QiCardViewDelegate>`。

```QiCardViewDelegate
#pragma mark - QiCardViewDelegate

- (void)cardView:(QiCardView *)cardView didRemoveLastCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    [cardView reloadDataAnimated:YES];
}

- (void)cardView:(QiCardView *)cardView didRemoveCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    NSLog(@"didRemoveCell forRowAtIndex = %ld", index);
}

- (void)cardView:(QiCardView *)cardView didDisplayCell:(QiCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    
    NSLog(@"didDisplayCell forRowAtIndex = %ld", index);
}

- (void)cardView:(QiCardView *)cardView didMoveCell:(QiCardViewCell *)cell forMovePoint:(CGPoint)point {
    NSLog(@"move point = %@", NSStringFromCGPoint(point));
}
```

### 三、QiCardView的技术点

#### 3.1 QiCardViewCell复用策略实现

1. 注册Cell：
两种方式：`registerNib`、`registerClass`。 很简单。

```register
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
```

2. 获取缓存Cell策略：
先看缓存池中是否有相同ID（`identifier`）的Cell，有的话，直接返回Cell。
若缓存池中没有，那么就`new`一个新的Cell啦~
```dequeue
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
```

3. 当cell走`DidRemoveFromSuperView`方法时，把cell加入缓存池。
```demo313
- (void)cardViewCellDidRemoveFromSuperView:(QiCardViewCell *)cell {

    //...    

    [self.reusableCells addObject:cell];

    //...
}
```

#### 3.2 cell重叠透明度渐变的实现

1. 首先声明了一个静态变量：`moveCount`来记录翻卡次数。（以便将cell的index与卡片的index逻辑关联）
```demo33
static int moveCount = 0;//!< 记录翻页次数
```

2. 逻辑：每个CardCell 在 “remove from super view” 的时候 moveCount+1。

```QiCardViewCellDelagate
#pragma mark - QiCardViewCellDelagate

- (void)cardViewCellDidRemoveFromSuperView:(QiCardViewCell *)cell {
    
    moveCount++;
    
    //....
}
```

3. 逻辑：在reload方法中，需要将moveCount置`0`。（很好理解，reload时，moveCount需要重新开始计算）
```reloadDataAnimated
- (void)reloadDataAnimated:(BOOL)animated {
    
    moveCount = 0;//!< 渐变需要
    
   //...
}
```

4. 关键逻辑：在每次更新布局时，设置每个Cell的渐变值（即`alpha`）
```updateLayoutVisibleCellsWithAnimated
/** 更新布局（动画） */
- (void)updateLayoutVisibleCellsWithAnimated:(BOOL)animated {
    
    //...

    if (_isAlpha) {
        BOOL isTopCell = (i == _currentIndex - moveCount);
        if (isTopCell) {//!< 如果是最上面的Cell就透明度为1
            cell.alpha = 1.0;
         } else {
            cell.alpha = (i + 1.9) * 1.0/self.visibleCells.count;
        }
    }

    //...

}
```

#### 3.3 手势操作实现

这部分主要是手势+动画。
细节比较多，小而杂。
详细逻辑，请见[源码](https://github.com/QiShare/QiCardView)。

```panGestureRecognizer
#define Qi_SNAPSHOTVIEW_TAG 999
#define Qi_DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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
```

四、未来可能优化的点

- 设计层面：如果将手势操作融入QiCardView中，将QiCardViewCell变成纯粹的Cell，会不会更好。（思考中）
- 应用层面：目前只支持一个ID的Cell重用，未来渴望拓展成多个ID的Cell都可重用。（PS：因为只存了一个ID，后续考虑存数组，以及对应的Cell缓存池数组。以此猜测UITableView的内部实现。）
