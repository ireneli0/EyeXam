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
#import "JBLineChartFooterView.h"
#import "JBChartInformationView.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface LineChartResultsDisplayViewController()<JBLineChartViewDataSource,JBLineChartViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;

@end

@implementation LineChartResultsDisplayViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    
    self.lineChartView.frame = CGRectMake(0,65, self.view.bounds.size.width, self.view.bounds.size.height-160);
    
    self.lineChartView.backgroundColor = UIColorFromRGB(0xffffff);
    
    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(100, 200, self.view.bounds.size.width - (100 * 2), 20)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    
    NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
    allRecords *firstRecordForCurrentUser = [nakedEyeResultsArray firstObject];
    allRecords *lastRecordForCurrentUser = [nakedEyeResultsArray lastObject];
    
    footerView.leftLabel.text = [NSString stringWithFormat: @"First Test Taken at: %@",firstRecordForCurrentUser.currentTime];
    footerView.leftLabel.textColor = [UIColor blackColor];
    footerView.rightLabel.text = [NSString stringWithFormat: @"Last Test Taken at: %@",lastRecordForCurrentUser.currentTime];
    footerView.rightLabel.textColor = [UIColor blackColor];
    footerView.sectionCount = [nakedEyeResultsArray count];
    self.lineChartView.footerView = footerView;
    
    [self.view addSubview:self.lineChartView];
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height-140, self.view.bounds.size.width/3, 80)];
    [self.informationView setValueAndUnitTextColor:[UIColor blackColor]];
    [self.informationView setTitleTextColor:[UIColor blackColor]];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:[UIColor blackColor]];
    [self.view addSubview:self.informationView];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.userNameLabel.text = self.userName;
    [self.lineChartView setState:JBChartViewStateExpanded];
    [self.lineChartView reloadData];
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView{
    return NO;
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

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0){
        //naked_right
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        if([nakedEyeResultsArray count]==0){
            return 0;
        }
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];

        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        CGFloat nakedPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];

        return nakedPoint;
    }else if (lineIndex ==1){
        //naked_left
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        if([nakedEyeResultsArray count]==0)
            return 0;
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];
        
        NSArray *resultForLeftEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        CGFloat nakedPoint = [[resultForLeftEye objectAtIndex:0] floatValue]/[[resultForLeftEye objectAtIndex:1] floatValue];
        return nakedPoint;
        
    }else if(lineIndex == 2){
        //glasses_right
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        if([withGlassesResultsArray count]==0)
            return 0;
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        CGFloat glassesPoint = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];

        return glassesPoint;
    }
    else{
        //glasses_left
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        if([withGlassesResultsArray count]==0)
            return 0;
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        NSArray *resultForLeftEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        CGFloat glassesPoint = [[resultForLeftEye objectAtIndex:0] floatValue]/[[resultForLeftEye objectAtIndex:1] floatValue];
        return glassesPoint;
    
    }

}

//static condition
//line color
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 ||lineIndex ==1)
        return UIColorFromRGB(0x5CACEE);
    else
        return UIColorFromRGB(0xFFB6C1);
    
}
//line width
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 || lineIndex == 2)
        return 4.0f;
    else
        return 4.0f;
}
//line style
- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 || lineIndex == 2)
        return JBLineChartViewLineStyleDashed;
    else
        return JBLineChartViewLineStyleSolid;
}


//selected condition
//vertical frame color
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 ||lineIndex ==1)
        return UIColorFromRGB(0x4cc552);
    else
        return UIColorFromRGB(0xff0000);

}
//vertical frame width
- (CGFloat)verticalSelectionWidthForLineChartView:(JBLineChartView *)lineChartView{
        return 20.0f;
}
//line color
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex{
    if(lineIndex == 0 ||lineIndex ==1)
        return UIColorFromRGB(0x4cc552);
    else
        return UIColorFromRGB(0xff0000);
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint{
    
    if(lineIndex == 0){
        //naked_right
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];

        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        float nakedRight = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];
        [self.informationView setValueText:[NSString stringWithFormat:@"Right naked eye:%.2f", nakedRight] unitText:@""];
        [self.informationView setHidden:NO animated:YES];

    }else if (lineIndex ==1){
        //naked_left
        NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:horizontalIndex];
        
        NSArray *resultForLeftEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        float nakedLeft = [[resultForLeftEye objectAtIndex:0] floatValue]/[[resultForLeftEye objectAtIndex:1] floatValue];
        [self.informationView setValueText:[NSString stringWithFormat:@"Left naked eye:%.2f", nakedLeft] unitText:@""];
        [self.informationView setHidden:NO animated:YES];
        
    }else if(lineIndex == 2){
        //glasses_right
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        
        NSArray *resultForRightEye = [recordsForCurrentUser.righteyeResult componentsSeparatedByString: @"/"];
        float glassesRight = [[resultForRightEye objectAtIndex:0] floatValue]/[[resultForRightEye objectAtIndex:1] floatValue];
        [self.informationView setValueText:[NSString stringWithFormat:@"Right eye with glasses:%.2f", glassesRight] unitText:@""];
        [self.informationView setHidden:NO animated:YES];
    }
    else if (lineIndex == 3){
        //glasses_left
        NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
        allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:horizontalIndex];
        
        NSArray *resultForLeftEye = [recordsForCurrentUser.lefteyeResult componentsSeparatedByString: @"/"];
        float glassesLeft = [[resultForLeftEye objectAtIndex:0] floatValue]/[[resultForLeftEye objectAtIndex:1] floatValue];
        [self.informationView setValueText:[NSString stringWithFormat:@"Left eye with glasses:%.2f", glassesLeft] unitText:@""];
        [self.informationView setHidden:NO animated:YES];
        
    }else{
        [self.informationView setHidden:NO animated:YES];
    }

}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView{
    [self.informationView setHidden:YES animated:YES];

}


@end
