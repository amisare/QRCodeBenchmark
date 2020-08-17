//
//  BMCIDetector.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMCIDetector.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+scale.h"

@implementation BMCIDetector

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block{
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    [BMFileUtils enumerateAllImagesUsingBlock:^(NSString *imagePath, NSString *imageCategory, NSString *imageName) {
        
        @autoreleasepool {
            UIImage *imageOrigin = [UIImage imageWithContentsOfFile:imagePath];
            __block UIImage *image = imageOrigin;
            __block CGFloat scale = 1.0;
            // scale size
            [imageOrigin bm_imageScaleWithMaxSize:CGSizeMake(768, 1008) complete:^(UIImage *_image, CGFloat _scale) {
                image = _image;
                scale = _scale;
            }];
            
            CIContext * context = [CIContext contextWithOptions:nil];
            NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
            CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:param];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            NSArray * results = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# CIDetector " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            if ([results count]) {
                for (CIQRCodeFeature * result in results) {
                    NSString *message = [@"message = " stringByAppendingString:[result messageString]];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    [bboxArray addObject:@(result.topLeft.x / scale)];
                    [bboxArray addObject:@(result.topLeft.y / scale)];
                    [bboxArray addObject:@(result.topRight.x / scale)];
                    [bboxArray addObject:@(result.topRight.y / scale)];
                    [bboxArray addObject:@(result.bottomRight.x / scale)];
                    [bboxArray addObject:@(result.bottomRight.y / scale)];
                    [bboxArray addObject:@(result.bottomLeft.x / scale)];
                    [bboxArray addObject:@(result.bottomLeft.y / scale)];
                    NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                    [beachmark addObject:bboxString];
                }
            }
            
            NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
            NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
            NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsCIDetectorPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
            
            count += 1;
            block(total, count, imagePath, beachmarkFilePath);
        }
    }];
}

@end
