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
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            // scale size
            CGFloat cgImageWidth = CGImageGetWidth(image.CGImage);
            CGFloat cgImageHeight = CGImageGetHeight(image.CGImage);
            if (cgImageWidth > 756 || cgImageHeight > 1008) {
                float scale = 1.0;
                if (cgImageWidth > 756) {
                    scale = 756.0 / cgImageWidth;
                }
                else {
                    scale = 1008.0 / cgImageHeight;
                }
                image = [image bm_imageScale:scale];
            }
            
            CIContext * context = [CIContext contextWithOptions:nil];
            NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
            CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:param];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            NSArray * results = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# CIDetector " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@(tock - tick).stringValue]];
            
            if ([results count]) {
                for (CIQRCodeFeature * result in results) {
                    NSString *message = [@"message = " stringByAppendingString:[result messageString]];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    [bboxArray addObject:@(result.topLeft.x)];
                    [bboxArray addObject:@(result.topLeft.y)];
                    [bboxArray addObject:@(result.topRight.x)];
                    [bboxArray addObject:@(result.topRight.y)];
                    [bboxArray addObject:@(result.bottomRight.x)];
                    [bboxArray addObject:@(result.bottomRight.y)];
                    [bboxArray addObject:@(result.bottomLeft.x)];
                    [bboxArray addObject:@(result.bottomLeft.y)];
                    
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
