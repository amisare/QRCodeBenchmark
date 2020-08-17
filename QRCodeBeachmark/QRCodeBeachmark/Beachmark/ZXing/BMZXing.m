//
//  BMZXing.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMZXing.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <ZXingObjC/ZXingObjC.h>
#import <ZXingObjC/ZXMultiDetector.h>
#import "UIImage+scale.h"

@implementation BMZXing

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
            
            ZXQRCodeMultiReader *scanner = [ZXQRCodeMultiReader new];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
            ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
            ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
            NSError *error;
            ZXDecodeHints *hints = [ZXDecodeHints new];
            hints.tryHarder = true;
            NSArray<ZXResult *> *results = [scanner decodeMultiple:bitmap hints:hints error:&error];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# ZXing " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            if ([results count] && error == NULL) {
                for (ZXResult *result in results) {
                    // skip incorrect result
                    if ([result.resultPoints count] != 4) {
                        continue;
                    }
                    NSString *message = [@"message = " stringByAppendingString:[result text]];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    for (ZXQRCodeFinderPattern *v in result.resultPoints) {
                        [bboxArray addObject:[@(v.x / scale) stringValue]];
                        [bboxArray addObject:[@(v.y / scale) stringValue]];
                    }
                    NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                    [beachmark addObject:bboxString];
                }
            }
            
            NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
            NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
            NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsZXingPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
            
            count += 1;
            block(total, count, imagePath, beachmarkFilePath);
        }
    }];
}

@end
