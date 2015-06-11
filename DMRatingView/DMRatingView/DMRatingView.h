//
//  DMRatingView.h
//  DMRatingView
//
//  Created by Hussain, Shabeer (UK - London) on 11/06/2015.
//  Copyright (c) 2015 Desert Monkey. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface DMRatingView : UIView

@property (nonatomic, strong) IBInspectable UIColor *unselectedColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedColor;
@property (nonatomic, strong) IBInspectable UIImage *iconImage;
@property (nonatomic, assign) IBInspectable NSInteger maxRating;
@property (nonatomic, assign) IBInspectable NSInteger minRating;
@property (nonatomic, assign) IBInspectable NSInteger rating;

@end
