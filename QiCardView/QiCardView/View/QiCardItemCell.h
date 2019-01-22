//
//  QiCardItemCell.h
//  QiCardView
//
//  Created by QiShare on 2019/1/18.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiCardView.h"
#import "QiDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QiCardItemCell : QiCardViewCell

@property (nonatomic, strong) QiDataModel *cellData;//!< 模型数据
@property (nonatomic, copy) void (^buttonClicked)(UIButton *);//!< 按钮点击回调

@end

NS_ASSUME_NONNULL_END
