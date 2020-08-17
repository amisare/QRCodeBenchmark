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
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            // scale size
            image = [image bm_imageScaleWithMaxSize:CGSizeMake(768, 1008)];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
            ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
            ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
            NSArray<ZXResult *> *results = [[ZXQRCodeMultiReader alloc] decodeMultiple:bitmap error:nil];
            NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
            
            
            NSMutableArray *beachmark = [NSMutableArray new];
            [beachmark addObject:[@"# ZXing " stringByAppendingString:imageName]];
            [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
            
            if ([results count]) {
                for (ZXResult *result in results) {
                    NSString *message = [@"message = " stringByAppendingString:[result text]];
                    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [beachmark addObject:message];
                    NSMutableArray *bboxArray = [NSMutableArray new];
                    for (id v in result.resultPoints) {
                        [bboxArray addObject:[v stringValue]];
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
