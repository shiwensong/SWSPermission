//
//  ViewController.m
//  Permission_demo
//
//  Created by NetClue on 16/3/30.
//  Copyright © 2016年 Shiwensong. All rights reserved.
//

#import "ViewController.h"
#import "SWSPermission.h"


@interface ViewController ()


@end

@implementation ViewController
- (IBAction)chooseImage:(UIButton *)sender {
    [[SWSPermission sharePermission] showPhotoWithVC:self withBlock:^(UIImage *image) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    

//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 300, 500)];
//    [self.view addSubview:imageView];
//    imageView.layer.cornerRadius = 5.0;
//    imageView.layer.masksToBounds = YES;
//    imageView.backgroundColor = [UIColor yellowColor];
//    
//    Permission *permission = [Permission sharePermission];
//    permission.canEidit = YES;
//    [permission showPhotoWithVC:self withBlock:^(UIImage *image) {
//        
//        imageView.image = image;
//        
//    }];
    
    
    
    SWSPermission *permission = [SWSPermission sharePermission];
    SystemPhotoValues *value = [[SystemPhotoValues alloc] init];
    value.image = [UIImage imageNamed:@"微博首1页"];
//    value.error = @"失败";
    value.success = @"成功";
    [permission saveLibrayToImage:value backBlcok:^(BOOL flag, id info) {
        if (flag == YES) {
            NSLog(@"成功1 === info == %@",info);

        }else{
            NSLog(@"失败 === info == %@",info);
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
