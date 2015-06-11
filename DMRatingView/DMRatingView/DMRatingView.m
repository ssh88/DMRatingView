//
//  DMRatingView.m
//  DMRatingView
//
//  Created by Hussain, Shabeer (UK - London) on 11/06/2015.
//  Copyright (c) 2015 Desert Monkey. All rights reserved.
//

#import "DMRatingView.h"

@interface DMRatingView ()

@property (nonatomic, strong) CALayer *fillLayer; //background fill layer
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, assign) CGFloat segmentWidth;//the width per segment

@end

@implementation DMRatingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    [self setupGestures];
    [self applyStyling];
}

#pragma mark - Styling

- (void) applyStyling
{
    self.backgroundColor = [UIColor clearColor];
    
    //default styling
    self.unselectedColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:150.0f/255.0f alpha:0.6f];
    self.selectedColor = [UIColor colorWithRed:243.0f/255.0f green:219.0f/255.0f blue:69.0f/255.0f alpha:1.0f];
    
    //default image
    self.iconImage = [UIImage imageNamed:@"star"];
}

#pragma mark - Gestures
- (void) setupGestures
{
    //add pan gesture to handle swipes
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didUpdateGesture:)];
    [self addGestureRecognizer:panGesture];
    
    //add tap gesture so users can also tap the area they want to fill
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didUpdateGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void) didUpdateGesture:(UIGestureRecognizer *)tapGesture
{
    //get the location of the users gesture to calculate the rating
    CGPoint location = [tapGesture locationInView:self];
    [self calculateRatingFromGesturePosition:location.x];
}


#pragma mark - Segments
/*
 * Method used for debugging
 * draws vertical lines to show boundry of each segment
 */
- (void) drawSegments
{
    for (NSInteger index = 1; index < self.maxRating; index++)
    {
        CALayer *line = [CALayer new];
        line.frame = CGRectMake(self.segmentWidth * index, 0, 1, self.frame.size.height);
        line.borderColor = self.selectedColor.CGColor;
        line.borderWidth = 2;
        [self.layer addSublayer:line];
    }
}

#pragma mark - Icons
/*
 * Creates the icons to represent the current rating
 */
- (void) createIcons
{
    //first remove any old icons
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    
    //reset array
    self.icons = nil;
    
    //mustable array to hold created icons
    NSMutableArray *mutableIcons = [NSMutableArray array];
    
    for (NSInteger index = 0; index < self.maxRating; index++)
    {
        //create each icon with the same width as the segmentWith
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(self.segmentWidth * index, 0, self.segmentWidth, self.frame.size.height)];
        //set content mode to aspect fit
        icon.contentMode = UIViewContentModeScaleAspectFit;
        //set rending mode to template so we can tint image
        icon.image = [self.iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        //set image tint to unselected colour
        icon.tintColor = self.unselectedColor;
        
        //finally add the icon image view to the view and to array
        [self addSubview:icon];
        [mutableIcons addObject:icon];
        
    }
    
    //set the icons array to use the created icons
    self.icons = [NSArray arrayWithArray:mutableIcons];
}

- (void)setIconImage:(UIImage *)iconImage
{
    _iconImage = iconImage;
    
    //update all icons with new image
    for (UIImageView *icon in self.icons)
    {
        icon.image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    //update the fill colour
    [self updateIconFill];
}


/*
 * Updates the colour of the icons to be selected or unselected
 * based on the current rating
 */
- (void) updateIconFill
{
    [self.icons enumerateObjectsUsingBlock:^(UIImageView *icon, NSUInteger idx, BOOL *stop)
     {
         //if the index is not greater than the current rating, we set it as selected
         if (idx < self.rating)
         {
             icon.tintColor = self.selectedColor;
         }
         else
         {
             icon.tintColor = self.unselectedColor;
         }
         
     }];
}

#pragma mark - Colours
- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    
    //update fill once colour is changed
    [self updateIconFill];
}

- (void) setUnselectedColor:(UIColor *)unselectedColor
{
    _unselectedColor = unselectedColor;
    
    //update fill once colour is changed
    [self updateIconFill];
}

#pragma mark - Rating
- (void)setMaxRating:(NSInteger)maxRating
{
    _maxRating = maxRating;
    
    //calculate the width 1 segment represents
    _segmentWidth = self.frame.size.width / self.maxRating;
    
    //create the icons now that the number of segments (maxRating) has been set
    [self createIcons];
    
    //uncomment this method for debuging
    //[self drawSegments];
}

- (void)setMinRating:(NSInteger)minRating
{
    _minRating = minRating;
    
    //select the min amount of rating
    [self calculateRatingFromGesturePosition:(self.minRating * self.segmentWidth)];
}

- (void)setRating:(NSInteger)rating
{
    //adjust the rating if it exceeds either boundary
    if (rating > self.maxRating)
    {
        rating = self.maxRating;
    }
    else if (rating < self.minRating)
    {
        rating = self.minRating;
    }
    
    _rating = rating;
    
    //update the UI to fill in the icons based on the rating
    [self updateIconFill];
    
    //uncomment this line to fill background
    //[self fillBackground];
}

- (void) calculateRatingFromGesturePosition:(CGFloat)xPos
{
    //get the  fill area as a percentage
    CGFloat fillPercentage = xPos/self.frame.size.width * 100;
    
    //calculate the number of filled segments rounded to the nearest whole number
    self.rating = (NSInteger)ceil((fillPercentage/100) * self.maxRating);
}

#pragma mark - Background Fill
/*
 * If called this method will fill the background
 * in proportion to the current rating
 */
- (void) fillBackground
{
    if (!self.fillLayer)
    {
        //create the background fill layer
        self.fillLayer = [CALayer layer];
        [self.layer insertSublayer:self.fillLayer atIndex:0];
        self.fillLayer.backgroundColor = self.selectedColor.CGColor;
    }
    
    //calculate the new width of the filled area
    CGFloat filledWidth = self.rating * self.segmentWidth;
    
    //apply fill
    self.fillLayer.frame = CGRectMake(0, 0,filledWidth, self.frame.size.height);
}


@end
