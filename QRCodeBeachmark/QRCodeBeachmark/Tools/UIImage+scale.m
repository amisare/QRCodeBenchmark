//
//  UIImage+scale.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/17.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

- (UIImage *)bm_imageScale:(CGFloat)scale {
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)bm_imageScaleWithMaxSize:(CGSize)size {
    CGFloat cgImageWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgImageHeight = CGImageGetHeight(self.CGImage);
    if (cgImageWidth > size.width || cgImageHeight > size.height) {
        float scale = 1.0;
        if (cgImageWidth > size.width) {
            scale = size.width / cgImageWidth;
        }
        else {
            scale = size.height / cgImageHeight;
        }
        return [self bm_imageScale:scale];
    }
    return self;
}

@end
