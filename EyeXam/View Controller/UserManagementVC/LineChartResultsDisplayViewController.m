//
//  LineChartResultsDisplayViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "LineChartResultsDisplayViewController.h"
#import "JBChartView.h"
#import "JBLineChartView.h"
#import "DatabaseInstance.h"
#import "allRecords.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface LineChartResultsDisplayViewController()<JBLineChartViewDataSource,JBLineChartViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) JBLineChartView *lineChartView;
@end

@implementation LineChartResultsDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameLabel.text = self.userName;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;

    self.lineChartView.frame = CGRectMake(100,100,800,500);
    self.lineChartView.backgroundColor = UIColorFromRGB(0xb7e3e4);
    [self.lineChartView reloadData];
    [self.view addSubview:self.lineChartView];

}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView{
    return 4;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 || lineIndex == 1)
        //naked eye
        return [[[DatabaseInstance getSharedInstance]getNakedEyeRecordsForSelectedUser:self.userName] count];
    else
        //with Glasses
        return [[[DatabaseInstance getSharedInstance]getWithGlassesRecordsForSelectedUser:self.userName]count];
    
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if(lineIndex == 0){
        //naked_right
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];

        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        CGFloat nakedPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];

        return nakedPoint;
    }else if (lineIndex ==1){
        //naked_left
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];
        
        NSArray *resultForRightEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        CGFloat nakedPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];
        return nakedPoint;
        
    }else if(lineIndex == 2){
        //glasses_right
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        CGFloat glassesPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];

        return glassesPoint;
    }
    else{
        //glasses_left
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        NSArray *resultForRightEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        CGFloat glassesPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];
        return glassesPoint;
    
    }
    return 0;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 ||lineIndex ==1)
        return UIColorFromRGB(0x4cc552);
    else
        return UIColorFromRGB(0xff0000);
    
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    if(lineIndex == 0 || lineIndex == 2)
        return 2.0f;
    else
        return 6.0f;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    if(lineIndex == 0 || lineIndex == 2)
        return JBLineChartViewLineStyleDashed;
    else
        return JBLineChartViewLineStyleSolid;
}




@end
