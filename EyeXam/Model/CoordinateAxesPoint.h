//
//  CoordinateAxesPoint.h
//  EyeXam
//
//  Created by Yi on 2015-03-03.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoordinateAxesPoint : NSObject
@property (nonatomic) float accX;
@property (nonatomic) float accY;
@property (nonatomic) float accZ;

@property (nonatomic) float gyroX;
@property (nonatomic) float gyroY;
@property (nonatomic) float gyroZ;

@property (nonatomic) float magX;
@property (nonatomic) float magY;
@property (nonatomic) float magZ;


@end
