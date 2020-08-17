//
//  BMQuirc.m
//  QRCodeBeachmark
//
//  Created by 顾海军 on 2020/8/17.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/objdetect.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "BMQuirc.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import "UIImage+scale.h"

#import <Quirc/Quirc.h>

using namespace cv;

@implementation BMQuirc

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
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
            
            quirc *detector = quirc_new();
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            Mat mat;
            UIImageToMat(image, mat);
            cv::cvtColor(mat, mat, COLOR_RGB2GRAY);
            int width = mat.cols, height = mat.rows;
            quirc_resize(detector, width, height);
            uint8_t *raw_data = quirc_begin(detector, &width, &height);;
            std::memcpy(raw_data, mat.data, width * height * sizeof(uint8_t));
            quirc_end(detector);
            int results = quirc_count(detector);
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# Quirc " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            for (int i = 0; i < results; i++) {
                struct quirc_code code;
                struct quirc_data data;
                quirc_extract(detector, i, &code);
                if( quirc_decode(&code,&data) == QUIRC_SUCCESS )  {
                    NSString *message = [NSString stringWithUTF8String:(const char*)data.payload];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:[@"message = " stringByAppendingString:message]];
                    
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    for( int i = 0; i < 4; i ++ ) {
                        [bboxArray addObject:@(code.corners[i].x / scale).stringValue];
                        [bboxArray addObject:@(code.corners[i].y / scale).stringValue];
                    }
                    NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                    [beachmark addObject:bboxString];
                }
            }
            
            mat.release();
            quirc_destroy(detector);
            
            NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
            NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
            NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsQuircPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
            
            count += 1;
            block(total, count, imagePath, beachmarkFilePath);
        }
    }];
}

@end
