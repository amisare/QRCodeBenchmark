//
//  UIImage+scale.h
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/17.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scale)

- (void)bm_imageScaleWithMaxSize:(CGSize)size complete:(void (^)(UIImage *scaledImage, CGFloat scale))complete;

@end
