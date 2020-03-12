//
//  AppDelegate.m
//  facebook
//
//  Created by xixi on 2020/3/12.
//  Copyright © 2020 xixi. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey] ];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation ]; // Add any custom logic here.
    return handled;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


-(void)facebookLogin{
    FBSDKAccessToken *cur_asscessToken =[FBSDKAccessToken currentAccessToken];
    UIViewController *viewController = [[UIViewController alloc] init];
    if(cur_asscessToken){//已经登录了
        NSLog(@"facebookLogin cur_asscessToken=%@",cur_asscessToken.userID);
        [self getUserInfoWithResult:cur_asscessToken.userID];
    }else{//拉起facebook 授权
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        NSArray<NSString*>*permissions =@[@"public_profile"];
        [loginManager logInWithPermissions:permissions fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"loginManager error=%@",error);
            } else if (result.isCancelled) {
                NSLog(@"loginManager 1 result=%@",result);
            } else {
                NSLog(@"loginManager 2 result=%@",result.token.userID);
                //result.token.userID
                [self getUserInfoWithResult:result.token.userID];
            }
        }];
    }
}

- (void)getUserInfoWithResult:(NSString *)userId
{
    NSDictionary*params= @{@"fields":@"id,name,picture"};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:userId
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSLog(@"FBSDKGraphRequest = %@",result);
        NSDictionary *resultDict = (NSDictionary *)result;
        NSString *userName = resultDict[@"name"];
        NSString *url = resultDict[@"picture"][@"data"][@"url"];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:userId forKey:@"facebook_id"];
        [dictionary setValue:userName forKey:@"facebook_name"];
        [dictionary setValue:url forKey:@"facebook_photo"];
    }];
}

-(void)shareFacebook:(NSDictionary*)dic{
    
    NSString *head_url =@"http://basefile.updrips.com/040878404B5255_1570985004454_79ca5cea-4800-4108-bc01-3589fff65ba0";
    NSURL *temp_url = [NSURL URLWithString:head_url];
    NSData *temp_image_data =[NSData dataWithContentsOfURL:temp_url];
//    [dic setValue:@"shareMessengerWithImageData" forKey:@"method"];[dic setValue:temp_image_data forKey:@"imageData"];
    [dic setValue:@"shareMessengerWithImageUrl" forKey:@"method"];[dic setValue:head_url forKey:@"imageUrl"];
    NSString *method = [dic objectForKey:@"method"];
    UIImage *image =nil;
    UIViewController *viewController = [[UIViewController alloc] init];
    if([method isEqualToString:@"shareMessengerWithImageData"]){//二进制图片分享
        NSURL *imageBase64 = [NSURL URLWithString:[dic objectForKey:@"imageData"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageBase64];
        image = [UIImage imageWithData:imageData];
        UIImage *shareImage = image;
        NSArray *activityItems = @[shareImage];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = nil;
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            NSLog(@"activityType: %@,\ncompleted: %d,\nreturnedItems:%@,\nactivityError:%@",activityType,completed,returnedItems,activityError);
        };
        [viewController presentViewController:activityVC animated:YES completion:nil];
    }else if([method isEqualToString:@"shareMessengerWithImageUrl"]){//图片链接分享
        NSString *imageUrl = [dic objectForKey:@"imageUrl"];
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *image_data =[NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:image_data];
        UIImage *shareImage = image;
        NSArray *activityItems = @[shareImage];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = nil;
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            NSLog(@"activityType: %@,\ncompleted: %d,\nreturnedItems:%@,\nactivityError:%@",activityType,completed,returnedItems,activityError);
        };
        [viewController presentViewController:activityVC animated:YES completion:nil];
    }
}



@end
