#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Manager.h"
#import "../../modules/JGProgressHUD/JGProgressHUD.h"

@interface SCIDownloadDelegate : NSObject

@property (nonatomic, strong) SCIDownloadManager *downloadManager;
@property (nonatomic, strong) JGProgressHUD *hud;

- (void)downloadFileWithURL:(NSURL *)url fileExtension:(NSString *)fileExtension;

@end