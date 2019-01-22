//
//  ViewController.m
//  QiCardView
//
//  Created by QiShare on 2019/1/18.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "ViewController.h"
#import "QiCardView.h"
#import "QiCardItemCell.h"
#import "QiDataModel.h"
#import <SafariServices/SafariServices.h>

static NSString * const qiCardCellId = @"QiCardCellId";

@interface ViewController ()<QiCardViewDataSource, QiCardViewDelegate>

@property (nonatomic, copy) NSArray<QiDataModel *> *cellItems;//!< 数据模型数据
@property (nonatomic, strong) QiCardView *cardView;//!< 主角：QiCardView

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initCellDatas];
    [self initViews];
}

//! 初始化Views
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


#pragma mark - QiCardViewDataSource

- (QiCardItemCell *)cardView:(QiCardView *)cardView cellForRowAtIndex:(NSInteger)index {
    
    QiCardItemCell *cell = [cardView dequeueReusableCellWithIdentifier:qiCardCellId];
    cell.cellData = _cellItems[index];
    cell.layer.cornerRadius = 10.0;
    cell.layer.masksToBounds = YES;
    cell.buttonClicked = ^(UIButton *sender) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.cellItems[index].url]];
        [self presentViewController:safariVC animated:YES completion:nil];
    };
    return cell;
}

- (NSInteger)numberOfCountInCardView:(UITableView *)cardView {
    return _cellItems.count;
}


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
//    NSLog(@"move point = %@", NSStringFromCGPoint(point));
}


#pragma mark - 初始化Cell数据

//! 初始化模型数据
- (void)initCellDatas {
    
    _cellItems = @[
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"SpriteJS",
                                                      @"brief": @"跨平台的2D绘图对象模型库",
                                                      @"discription": @"能够支持web、node、桌面应用和微信小程序的图形绘制和实现各种动画效果",
                                                      @"logo": @"open_spritejs_logo",
                                                      @"backgroundImage": @"open_spritejs",
                                                      @"backgroundColor": @"#3FD5A0",
                                                      @"url": @"http://spritejs.org"
                                                      }],
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"ThinkJS",
                                                      @"brief": @"一款面向未来开发的Node.js框架",
                                                      @"discription": @"整合了大量的项目最佳实践，让企业级开发变得如此简单、高效。从3.0开始，框架底层基于Koa2.x实现，兼容Koa的所有功能",
                                                      @"logo": @"open_thinkjs_logo",
                                                      @"backgroundImage": @"open_thinkjs",
                                                      @"backgroundColor": @"#3CC1FC",
                                                      @"url": @"https://thinkjs.org"
                                                      }],
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"SpriteJS-2",
                                                      @"brief": @"跨平台的2D绘图对象模型库",
                                                      @"discription": @"能够支持web、node、桌面应用和微信小程序的图形绘制和实现各种动画效果",
                                                      @"logo": @"open_spritejs_logo",
                                                      @"backgroundImage": @"open_spritejs",
                                                      @"backgroundColor": @"#3FD5A0",
                                                      @"url": @"http://spritejs.org"
                                                      }],
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"ThinkJS-2",
                                                      @"brief": @"一款面向未来开发的Node.js框架",
                                                      @"discription": @"整合了大量的项目最佳实践，让企业级开发变得如此简单、高效。从3.0开始，框架底层基于Koa2.x实现，兼容Koa的所有功能",
                                                      @"logo": @"open_thinkjs_logo",
                                                      @"backgroundImage": @"open_thinkjs",
                                                      @"backgroundColor": @"#3CC1FC",
                                                      @"url": @"https://thinkjs.org"
                                                      }],
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"SpriteJS-3",
                                                      @"brief": @"跨平台的2D绘图对象模型库",
                                                      @"discription": @"能够支持web、node、桌面应用和微信小程序的图形绘制和实现各种动画效果",
                                                      @"logo": @"open_spritejs_logo",
                                                      @"backgroundImage": @"open_spritejs",
                                                      @"backgroundColor": @"#3FD5A0",
                                                      @"url": @"http://spritejs.org"
                                                      }],
                   [[QiDataModel alloc] initWithDic:@{
                                                      @"name": @"ThinkJS-3",
                                                      @"brief": @"一款面向未来开发的Node.js框架",
                                                      @"discription": @"整合了大量的项目最佳实践，让企业级开发变得如此简单、高效。从3.0开始，框架底层基于Koa2.x实现，兼容Koa的所有功能",
                                                      @"logo": @"open_thinkjs_logo",
                                                      @"backgroundImage": @"open_thinkjs",
                                                      @"backgroundColor": @"#3CC1FC",
                                                      @"url": @"https://thinkjs.org"
                                                      }]
                   ];
}


@end
