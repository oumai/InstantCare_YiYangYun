//
//  KMPictureCarouselView.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/30.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMPictureCarouselView.h"

@interface KMPictureCarouselView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSUInteger imagesCount;
@property (nonatomic, assign) CGFloat timeInterval;
@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation KMPictureCarouselView

- (instancetype)initWithImages:(NSArray *)images
                         width:(CGFloat)width
                        height:(CGFloat)height
                  timeInterval:(CGFloat)timeInterval
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, width, height);
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        for (int i = 0; i < images.count; i++) {
			CGFloat imageX = i * width;
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, -64, width, height)];
			imageView.image = images[i];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.scrollView addSubview:imageView];
        }

        [self addSubview:self.scrollView];
        self.scrollView.contentSize = CGSizeMake(width*images.count, 0);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;

        // 添加单击事件
        UITapGestureRecognizer *sigleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                            action:@selector(handleTapGesture:)];
        sigleTapRecognizer.numberOfTapsRequired = 1;
        [self.scrollView addGestureRecognizer:sigleTapRecognizer];

        self.imagesCount = images.count;
        self.timeInterval = timeInterval;

        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.numberOfPages = self.imagesCount;
        self.pageControl.currentPage = 0;
        self.pageControl.center = CGPointMake(width/2.0, height - 30);
        [self addSubview:self.pageControl];

        [self addTimer];
    }

    return self;
}

- (void)handleTapGesture:( UITapGestureRecognizer *)tapRecognizer
{
    if ([self.delegate respondsToSelector:@selector(BannerViewDidClicked:)]) {
        [self.delegate BannerViewDidClicked:self.currentPage];
    }
}

- (void)nextImage
{
    int page = (int)self.pageControl.currentPage;
    if (page == self.imagesCount - 1) {
        page = 0;
    } else {
        page++;
    }

    self.currentPage = page;

    CGFloat x = page * self.frame.size.width;
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.3];
    //动画的内容
    self.scrollView.contentOffset = CGPointMake(x, 0);
    //动画结束
    [UIView commitAnimations];
}

// scrollview滚动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollviewW =  scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    int page = (x + scrollviewW / 2) /  scrollviewW;
    self.currentPage = page;
    self.pageControl.currentPage = page;
}

// 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

/**
 *  开启定时器
 */
- (void)addTimer
{
    if (self.timeInterval > 0.001) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                      target:self
                                                    selector:@selector(nextImage)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

/**
 *  关闭定时器
 */
- (void)removeTimer
{
    [self.timer invalidate];
}


@end
