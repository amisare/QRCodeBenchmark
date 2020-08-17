//
//  BMOpenCV.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMOpenCV.h"
#import <UIKit/UIKit.h>
#import <opencv2/objdetect.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "BMFileUtils.h"
#import "UIImage+scale.h"

using namespace cv;

@implementation BMOpenCV

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    [BMFileUtils enumerateAllImagesUsingBlock:^(NSString *imagePath, NSString *imageCategory, NSString *imageName) {
        
        @autoreleasepool {
            cv::QRCodeDetector scanner = cv::QRCodeDetector();
            
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            // scale size
            image = [image bm_imageScaleWithMaxSize:CGSizeMake(768, 1008)];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            Mat mat;
            UIImageToMat(image, mat);
            Mat bbox;
            std::string msg = scanner.detectAndDecode(mat, bbox);
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# OpenCV " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            if (msg.length() != 0) {
                NSString *message = [NSString stringWithUTF8String:msg.c_str()];
                message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                [beachmark addObject:[@"message = " stringByAppendingString:message]];
                NSMutableArray *bboxArray = [NSMutableArray new];
                for( int j = 0; j < bbox.rows; j ++ ) {
                    for (int i = 0; i < 2; i ++ ) {
                        [bboxArray addObject:@(bbox.at<float>(j,i)).stringValue];
                    }
                }
                NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                [beachmark addObject:bboxString];
            }
            
            NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
            NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
            NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsOpenCVPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
            
            count += 1;
            block(total, count, imagePath, beachmarkFilePath);
        }
    }];
}

@end
