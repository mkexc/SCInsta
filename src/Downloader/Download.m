#import "Download.h"
#import "../InstagramHeaders.h"
#import "../Utils.h"

@implementation SCIDownloadDelegate

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Properties
        self.downloadManager = [[SCIDownloadManager alloc] initWithDelegate:(id<SCIDownloadDelegate>)self];
        self.hud = [[JGProgressHUD alloc] init];
    }

    return self;
}
- (void)downloadFileWithURL:(NSURL *)url fileExtension:(NSString *)fileExtension {
    // Show progress gui
    self.hud = [[JGProgressHUD alloc] init];
    self.hud.textLabel.text = @"Downloading";

    [self.hud showInView:topMostController().view];

    NSLog(@"[SCInsta] Download: Will start download for url \"%@\" with file extension: \".%@\"", url, fileExtension);

    // Start download using manager
    [self.downloadManager downloadFileWithURL:url fileExtension:fileExtension];
}

// Delegate methods
- (void)downloadDidStart {
    NSLog(@"[SCInsta] Download: Download started");
}
- (void)downloadDidProgress:(float)progress {
    NSLog(@"[SCInsta] Download: Download progress: %f", progress);

    [self.hud setProgress:progress animated:true];
}
- (void)downloadDidFinishWithError:(NSError *)error {
    // Get rid of downloading gui
    [self.hud dismiss];

    NSLog(@"[SCInsta] Download: Download failed with error: \"%@\"", error);

    [SCIUtils showErrorHUDWithDescription:@"Error, try again later"];
}
- (void)downloadDidFinishWithFileURL:(NSURL *)fileURL {
    [self.hud dismiss];

    NSLog(@"[SCInsta] Download: Download finished with url: \"%@\"", [fileURL absoluteString]);
    NSLog(@"[SCInsta] Download: Displaying save dialog");

    [SCIManager showSaveVC:fileURL];
}

@end