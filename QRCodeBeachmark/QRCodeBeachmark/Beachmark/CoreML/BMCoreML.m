//
//  BMCoreML.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "BMCoreML.h"
#import <UIKit/UIKit.h>
#import "BMFileUtils.h"
#import <Vision/Vision.h>
#import "UIImage+scale.h"

@implementation BMCoreML

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block {
    
    int total = [BMFileUtils totalImagesCount];
    __block int count = 0;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
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
            
            NSTimeInterval tick = [[NSDate date] timeIntervalSince1970];
            VNDetectBarcodesRequest *request = [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                
                NSTimeInterval tock = [[NSDate date] timeIntervalSince1970];
                
                NSMutableArray *beachmark = [NSMutableArray new];
                [beachmark addObject:[@"# CoreML " stringByAppendingString:imageName]];
                [beachmark addObject:[@"milliseconds = " stringByAppendingString:@((tock - tick) * 1000).stringValue]];
                
                if (error == nil && [request.results count]) {
                    for (VNBarcodeObservation * result in request.results) {
                        if ([result symbology] == VNBarcodeSymbologyQR) {
                            NSString *message = [@"message = " stringByAppendingString:[result payloadStringValue]];
                            message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                            [beachmark addObject:message];

                            NSMutableArray *bboxArray = [NSMutableArray new];
                            [bboxArray addObject:@(result.topLeft.x * image.size.width / scale)];
                            [bboxArray addObject:@(result.topLeft.y * image.size.height / scale)];
                            [bboxArray addObject:@(result.topRight.x * image.size.width / scale)];
                            [bboxArray addObject:@(result.topRight.y * image.size.height / scale)];
                            [bboxArray addObject:@(result.bottomRight.x * image.size.width / scale)];
                            [bboxArray addObject:@(result.bottomRight.y * image.size.height / scale)];
                            [bboxArray addObject:@(result.bottomLeft.x * image.size.width / scale)];
                            [bboxArray addObject:@(result.bottomLeft.y * image.size.height / scale)];
                            NSString *bboxString = [bboxArray componentsJoinedByString:@" "];
                            [beachmark addObject:bboxString];
                        }
                    }
                }
                
                NSString *beachmarkString = [beachmark componentsJoinedByString:@"\n"];
                NSString *beachmarkFileName = [[imageName componentsSeparatedByString:@"."][0] stringByAppendingString:@".txt"];
                NSString *beachmarkFilePath = [BMFileUtils saveBeachmarkFileWithResultPath:[BMFileUtils resultsCoreMLPath] imageCategory:imageCategory beachmarkFileName:beachmarkFileName beanchmarkData:beachmarkString];
                
                count += 1;
                block(total, count, imagePath, beachmarkFilePath);
                
                dispatch_semaphore_signal(sema);
            }];
            
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            [handler performRequests:@[request] error:nil];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    }];
}

@end
