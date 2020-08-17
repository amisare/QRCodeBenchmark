//
//  BMMLKit.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMMLKit.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <MLKitVision/MLKitVision.h>
#import <MLKitBarcodeScanning/MLKitBarcodeScanning.h>
#import "UIImage+scale.h"

@implementation BMMLKit

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [BMFileUtils enumerateAllImagesUsingBlock:^(NSString *imagePath, NSString *imageCategory, NSString *imageName) {
        
        @autoreleasepool {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            // scale size
            image = [image bm_imageScaleWithMaxSize:CGSizeMake(768, 1008)];
            
            MLKBarcodeScannerOptions *options = [[MLKBarcodeScannerOptions alloc] initWithFormats: MLKBarcodeFormatQRCode];
            MLKBarcodeScanner *barcodeScanner = [MLKBarcodeScanner barcodeScannerWithOptions:options];
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
            [barcodeScanner processImage:visionImage completion:^(NSArray<MLKBarcode *> * _Nullable results, NSError * _Nullable error) {
                NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
                
                NSMutableArray *beachmark = [NSMutableArray new];
                [beachmark addObject:[@"# MLKit " stringByAppendingString:imageName]];
                [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
                
                if (error == nil && [results count]) {
                    for (MLKBarcode * result in results) {
                        NSString *message = [@"message = " stringByAppendingString:[result rawValue]];
                        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                        [beachmark addObject:message];
                        
                        NSMutableArray *bboxArray = [NSMutableArray new];
                        for (NSValue *p in result.cornerPoints) {
                            CGPoint point = [p CGPointValue];
                            [bboxArray addObject:[@(point.x) stringValue]];
                            [bboxArray addObject:[@(point.y) stringValue]];
                        }
                        NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                        [beachmark addObject:bboxString];
                    }
                }
                
                NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
                NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
                NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsMLKitPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
                
                count += 1;
                block(total, count, imagePath, beachmarkFilePath);
                
                dispatch_semaphore_signal(sema);
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    }];
}

@end
