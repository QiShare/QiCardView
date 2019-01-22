//
//  QiDataModel.h
//  QiCardView
//
//  Created by QiShare on 2019/1/18.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QiDataModel : NSObject

@property (nonatomic, copy) NSString *name;//!< 框架名
@property (nonatomic, copy) NSString *brief;//!< 框架简介
@property (nonatomic, copy) NSString *discription;//!< 框架详细介绍
@property (nonatomic, copy) NSString *logo;//!< logo
@property (nonatomic, copy) NSString *backgroundImage;//!< 占位背景图
@property (nonatomic, copy) NSString *backgroundColor;//!< 背景颜色
@property (nonatomic, copy) NSString *url;//!< url

- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
