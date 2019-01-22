//
//  QiCardItemCell.m
//  QiCardView
//
//  Created by QiShare on 2019/1/18.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "QiCardItemCell.h"

@interface QiCardItemCell()

@property (nonatomic, strong) UIView *container;//!< 容器
@property (nonatomic, strong) UIImageView *backgroundImageView;//!< 上背景占位图
@property (nonatomic, strong) UIImageView *logoImageView;//!< logo视图
@property (nonatomic, strong) UILabel *nameLabel;//!< 名称标签
@property (nonatomic, strong) UILabel *briefLabel;//!< 简介标签
@property (nonatomic, strong) UILabel *discriptionLabel;//!< 详细介绍标签
@property (nonatomic, strong) UIButton *button;//!< 点击按钮

@end


@implementation QiCardItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        _container = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _container.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_container];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_container addSubview:_backgroundImageView];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_container addSubview:_logoImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:18.0];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor blackColor];
        [_container addSubview:_nameLabel];
        
        _briefLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _briefLabel.font = [UIFont systemFontOfSize:16.0];
        _briefLabel.textAlignment = NSTextAlignmentCenter;
        _briefLabel.textColor = [UIColor grayColor];
        [_container addSubview:_briefLabel];
        
        _discriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discriptionLabel.font = [UIFont systemFontOfSize:14.0];
        _discriptionLabel.textAlignment = NSTextAlignmentCenter;
        _discriptionLabel.textColor = [UIColor lightGrayColor];
        _discriptionLabel.numberOfLines = 0;
        [_container addSubview:_discriptionLabel];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor orangeColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _button.titleLabel.textColor = [UIColor whiteColor];
        [_button setTitle:@"点击查看" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_container addSubview:_button];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    _container.frame = self.contentView.bounds;
    
    _backgroundImageView.frame = CGRectMake(.0, .0, _container.frame.size.width, 120.0);
    _backgroundImageView.layer.cornerRadius = 5.0;
    _backgroundImageView.layer.masksToBounds = YES;
    
    _logoImageView.frame = CGRectMake(_container.frame.size.width / 2 - 52.0, 62.0, 104.0, 104.0);
    _logoImageView.layer.cornerRadius = _logoImageView.frame.size.width / 2;
    _logoImageView.layer.masksToBounds = NO;
    
    _nameLabel.frame = CGRectMake(.0, _logoImageView.frame.origin.y + _logoImageView.frame.size.height + 20.0, _container.frame.size.width, 25.0);
    
    _briefLabel.frame = CGRectMake(.0, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + 10.0, _container.frame.size.width, 22.0);
    
    _button.frame = CGRectMake(_container.frame.size.width / 2 - 80.0, _container.frame.size.height - 76.0, 160.0, 46.0);
    _button.layer.cornerRadius = _button.frame.size.height / 2;
    
    _discriptionLabel.frame = CGRectMake(20.0, _briefLabel.frame.origin.y + _briefLabel.frame.size.height + 10.0, _container.frame.size.width - 40.0, _container.frame.size.height - _briefLabel.frame.origin.y - _briefLabel.frame.size.height - _button.frame.size.height - 50.0);
}


- (void)setCellData:(QiDataModel *)cellData {
    
    _backgroundImageView.image = [UIImage imageNamed:cellData.backgroundImage];
    _logoImageView.image = [UIImage imageNamed:cellData.logo];
    _nameLabel.text = cellData.name;
    _briefLabel.text = cellData.brief;
    _discriptionLabel.text = cellData.discription;
}

- (void)buttonClicked:(UIButton *)sender {
    
    if (_buttonClicked) {
        _buttonClicked(sender);
    }
}

@end
