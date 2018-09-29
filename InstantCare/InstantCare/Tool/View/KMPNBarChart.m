//
//  KMPNBarChart.m
//  InstantCare
//
//  Created by Frank He on 9/14/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMPNBarChart.h"
#import "PNChartLabel.h"

@interface  KMPNBarChart()
 @property(nonatomic,strong)   NSMutableArray * xChartLabels;
 @property(nonatomic,strong)   NSMutableArray * yChartLabels;
@end

@implementation KMPNBarChart

@synthesize xLabels= _xLabels;

-(NSInteger)timeSecond:(NSString*)time{
    NSArray* array = [time componentsSeparatedByString:@":"];
    NSInteger hour = [array.firstObject intValue];
    NSInteger minute = [array.lastObject intValue];
    
    NSInteger totalSeconds = hour*60*60 + minute*60;

    return totalSeconds;
}

-(void)setXLabels:(NSArray *)xLabels{
    _xLabels = xLabels;
    
    if (self.xChartLabels) {
        [self viewCleanupForCollection:self.xChartLabels];
    }else{
        _xChartLabels = [NSMutableArray new];
    }
    
    _xTimesLabelsWidthDic = [NSMutableDictionary dictionary];
    
    NSInteger chartWidth = self.frame.size.width - self.chartMarginLeft - self.chartMarginRight;
    //self.xLabelWidth = (self.frame.size.width - self.chartMarginLeft - self.chartMarginRight) / [xLabels count];
    
    //计算宽度
    NSInteger durationSeconds = [self timeSecond:self.duration];
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"HH:mm";
    
    for(int i = 0 ;i< xLabels.count ; i++){
        if(i == 0){
            _xTimesLabelsWidthDic[xLabels[i]] = @(0);
        }else{
            
            float preDateSeconds = [self timeSecond:xLabels[i-1]];
            float currentDateSeconds = [self timeSecond:xLabels[i]];
            
            float betweenTimeInterval = currentDateSeconds - preDateSeconds;
            
            if(betweenTimeInterval<0){
                betweenTimeInterval = currentDateSeconds + (24*60*60 - preDateSeconds);
            }
            
            float timePrencent = betweenTimeInterval / durationSeconds;
            
            _xTimesLabelsWidthDic[xLabels[i]] = @(chartWidth * timePrencent);
        }
    }
    
    if (self.showLabel) {
        int labelAddCount = 0;
        for (int index = 0; index < self.xLabels.count; index++) {
            labelAddCount += 1;
            if(index == 0 || index == (self.xLabels.count -1)){
                NSString *labelText = [self.xLabels[index] description];
                //第一个与第二个Xlabel width 宽
                PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, 0, 25, kXLabelHeight)];
                label.font = self.labelFont;
                label.textColor = self.labelTextColor;
                [label setTextAlignment:NSTextAlignmentCenter];
                label.text = labelText;
                //[label sizeToFit];
                CGFloat labelXPosition;
                if (self.rotateForXAxisText){
                    label.transform = CGAffineTransformMakeRotation(M_PI / 4);
                    labelXPosition = (index *  self.xLabelWidth + self.chartMarginLeft + self.xLabelWidth /1.5);
                }
                else{
                    if(index == (self.xLabels.count -1)){
                        labelXPosition = self.frame.size.width - self.chartMarginRight;
                    }else{
                        labelXPosition = self.chartMarginLeft;
                    }
                    
                }
                label.center = CGPointMake(labelXPosition,
                                           self.frame.size.height - kXLabelHeight - self.chartMarginTop + label.frame.size.height /2.0 + self.labelMarginTop);
                labelAddCount = 0;
                [_xChartLabels addObject:label];
                [self addSubview:label];
            }
        }
    }
}

- (void)updateBar
{
    
    //Add bars
    CGFloat chartCavanHeight = self.frame.size.height - self.chartMarginTop - self.chartMarginBottom - kXLabelHeight;
    NSInteger index = 0;
    
    for (NSNumber *valueString in self.yValues) {
        
        PNBar *bar;
        
        if (self.bars.count == self.yValues.count) {
            bar = [self.bars objectAtIndex:index];
        }else{
            CGFloat barWidth;
            CGFloat barXPosition;
            
            if (self.barWidth) {
                barWidth = self.barWidth;
                barXPosition = index *  self.xLabelWidth + self.chartMarginLeft + self.xLabelWidth /2.0 - self.barWidth /2.0;
            }else{
                //barXPosition = index *  _xLabelWidth + _chartMarginLeft + _xLabelWidth * 0.25;
                NSString* xlabelsTime = _xLabels[index];
                CGFloat everyBarWidth = [_xTimesLabelsWidthDic[xlabelsTime] floatValue];
                if (self.showLabel) {
                   // barWidth = self.xLabelWidth;
                    barWidth = everyBarWidth;
                }
                else {
                    barWidth = everyBarWidth;
                }
                
                if(index == 0){
                    barXPosition = self.chartMarginLeft;
                }else{
                    NSString* xlabelsTime = _xLabels[index-1];
                    CGFloat preBarWidth = [_xTimesLabelsWidthDic[xlabelsTime] floatValue];
                    barXPosition = barXPosition + preBarWidth;
                }
            }
            
            bar = [[PNBar alloc] initWithFrame:CGRectMake(barXPosition, //Bar X position
                                                          self.frame.size.height - chartCavanHeight - kXLabelHeight - self.chartMarginBottom + self.chartMarginTop , //Bar Y position
                                                          barWidth, // Bar witdh
                                                          self.showLevelLine ? chartCavanHeight/2.0:chartCavanHeight)]; //Bar height
            
            //Change Bar Radius
            bar.barRadius = self.barRadius;
            
            //Change Bar Background color
            bar.backgroundColor = self.barBackgroundColor;
            //Bar StrokColor First
            if (self.strokeColor) {
                bar.barColor = self.strokeColor;
            }else{
                bar.barColor = [self barColorAtIndex:index];
            }
            
            if (self.labelTextColor) {
                bar.labelTextColor = self.labelTextColor;
            }
            
            // Add gradient
            if (self.isGradientShow) {
                bar.barColorGradientStart = bar.barColor;
            }
            
            //For Click Index
            bar.tag = index;
            
            [self.bars addObject:bar];
            [self addSubview:bar];
        }
        
        //Height Of Bar
        float value = [valueString floatValue];
        float grade =fabsf((float)value / (float)self.yValueMax);
        
        if (isnan(grade)) {
            grade = 0;
        }
        bar.maxDivisor = (float)self.yValueMax;
        bar.grade = grade;
        bar.isShowNumber = self.isShowNumbers;
        CGRect originalFrame = bar.frame;
        NSString *currentNumber =  [NSString stringWithFormat:@"%f",value];
        
        if ([[currentNumber substringToIndex:1] isEqualToString:@"-"] && self.showLevelLine) {
            CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI);
            [bar setTransform:transform];
            originalFrame.origin.y = bar.frame.origin.y + bar.frame.size.height;
            bar.frame = originalFrame;
            bar.isNegative = YES;
            
        }
        index += 1;
    }
}

- (UIColor *)barColorAtIndex:(NSUInteger)index
{
    if ([self.strokeColors count] == [self.yValues count]) {
        return self.strokeColors[index];
    }
    else {
        return self.strokeColor;
    }
}

- (void)viewCleanupForCollection:(NSMutableArray *)array
{
    if (array.count) {
        [array makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [array removeAllObjects];
    }
}

@end
