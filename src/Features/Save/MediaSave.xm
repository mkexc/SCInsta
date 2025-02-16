#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Utils.h"
#import "../../Downloader/Download.h"

// Download images
%hook IGFeedPhotoView
%property (nonatomic, strong) JGProgressHUD *hud;

%new - (void)printGestureRecognizersForView:(UIView *)view {
    NSArray<UIGestureRecognizer *> *gestureRecognizers = view.gestureRecognizers;
    if (gestureRecognizers.count > 0) {
        NSLog(@"Gesture recognizers for view %@:", view);
        for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers) {
            NSLog(@"- %@", gestureRecognizer);
        }
    }

    for (UIView *subview in view.subviews) {
        [self printGestureRecognizersForView:subview];
    }
}

- (void)didMoveToWindow {
    %orig;

    // Create new long press gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;

    [self addGestureRecognizer:longPress];
    NSLog(@"[SCInsta Test] added gesture recognizer");

    [self printGestureRecognizersForView:self];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {

        IGPhoto *photo = nil;

        // Get photo instance
        if ([self.delegate isKindOfClass:%c(IGFeedItemPhotoCell)]) {
            IGFeedItemPhotoCellConfiguration *_configuration = MSHookIvar<IGFeedItemPhotoCellConfiguration *>(self.delegate, "_configuration");

            photo = MSHookIvar<IGPhoto *>(_configuration, "_photo");
        }
        else if ([self.delegate isKindOfClass:%c(IGFeedItemPagePhotoCell)]) {
            IGFeedItemPagePhotoCell *pagePhotoCell = self.delegate;

            photo = pagePhotoCell.pagePhotoPost.photo;
        }

        if (!photo) {
            [SCIUtils showErrorHUDWithDescription:@"Could not extract photo data from post"];

            return;
        }

        // Get highest quality photo link
        NSURL *photoURL = [photo imageURLForWidth:100000.00];
        if (!photoURL) {
            [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from post"];
            
            return;
        }

        // Send photo url to downloader
        SCIDownloadDelegate *downloadDelegate = [[SCIDownloadDelegate alloc] init];
        [downloadDelegate downloadFileWithURL:photoURL fileExtension:@"png"];

    }
}

%end

/////////////////////////////////////////////////////////////////////////////


// Download photos
/* %hook IGFeedPhotoView
%property (nonatomic, strong) JGProgressHUD *hud;
- (id)initWithFrame:(CGRect)arg1 {
    id orig = %orig;
    if ([SCIManager getPref:@"dw_videos"]) {
        [orig addHandleLongPress];
    }
    return orig;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if  ([self.delegate isKindOfClass:%c(IGFeedItemPhotoCell)]) {
            IGFeedItemPhotoCell *currentCell = self.delegate;
            UIImage *currentImage = [currentCell mediaCellCurrentlyDisplayedImage];

            NSLog(@"[SCInsta] Save media: Displaying save dialog");

            [SCIManager showSaveVC:currentImage];
        } else if ([self.delegate isKindOfClass:%c(IGFeedItemPagePhotoCell)]) {
            NSLog(@"[SCInsta] Save media: Preparing alert");

            IGFeedItemPagePhotoCell *currentCell = self.delegate;
            IGPostItem *currentPost = [currentCell post];

            NSSet <NSString *> *knownImageURLIdentifiers = [currentPost.photo valueForKey:@"_knownImageURLIdentifiers"];
            NSArray *knownImageURLIdentifiersArray = [knownImageURLIdentifiers allObjects];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SCInsta Downloader" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

            for (int i = 0; i < [knownImageURLIdentifiersArray count]; i++) {
                [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Download Image: Link %d (%@)", i + 1, i == 0 ? @"HD" : @"SD"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    SCIDownload *dwManager = [[SCIDownload alloc] init];
                    [dwManager downloadFileWithURL:[NSURL URLWithString:[knownImageURLIdentifiersArray objectAtIndex:i]]];
                    [dwManager setDelegate:self];

                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";

                    [self.hud showInView:topMostController().view];
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [SCIUtils prepareAlertPopoverIfNeeded:alert inView:self];

            NSLog(@"[SCInsta] Save media: Displaying alert");

            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [SCIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", NSUUID.UUID.UUIDString]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];

    [self.hud dismiss];

    NSLog(@"[SCInsta] Save media: Displaying save dialog");

    [SCIManager showSaveVC:newFilePath];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end
 */

// Download videos
/* %hook IGModernFeedVideoCell
%property (nonatomic, strong) JGProgressHUD *hud;
- (id)initWithFrame:(CGRect)arg1 {
    id orig = %orig;
    if ([SCIManager getPref:@"dw_videos"]) {
        [orig addHandleLongPress];
    }
    return orig;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SCInsta Downloader" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([self.delegate isKindOfClass:%c(IGPageMediaView)]) {
            NSLog(@"[SCInsta] Save media: Preparing alert");
            
            IGPageMediaView *mediaDelegate = self.delegate;
            IGPostItem *currentPost = [mediaDelegate currentMediaItem];
            NSArray *videoURLArray = [currentPost.video.allVideoURLs allObjects];
            
            for (int i = 0; i < [videoURLArray count]; i++) {
                [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Download Video: Link %d (%@)", i + 1, i == 0 ? @"HD" : @"SD"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    // [[[HgetPref:@"dw_videos"WithProgress alloc] init] checkPermissionToPhotosAndDownloadURL:[videoURLArray objectAtIndex:i] appendExtension:nil mediaType:Video toAlbum:@"Instagram" view:self];
                    SCIDownload *dwManager = [[SCIDownload alloc] init];
                    [dwManager downloadFileWithURL:[videoURLArray objectAtIndex:i]];
                    [dwManager setDelegate:self];

                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";

                    [self.hud showInView:topMostController().view];
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [SCIUtils prepareAlertPopoverIfNeeded:alert inView:self];

            NSLog(@"[SCInsta] Save media: Displaying alert");

            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
        else if ([self.delegate isKindOfClass:%c(IGFeedSectionController)]) {
            NSLog(@"[SCInsta] Save media: Preparing alert");

            NSArray *videoURLArray = [self.post.video.allVideoURLs allObjects];
            
            for (int i = 0; i < [videoURLArray count]; i++) {
                [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Download Video: Link %d (%@)", i + 1, i == 0 ? @"HD" : @"SD"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    // [[[HgetPref:@"dw_videos"WithProgress alloc] init] checkPermissionToPhotosAndDownloadURL:[videoURLArray objectAtIndex:i] appendExtension:nil mediaType:Video toAlbum:@"Instagram" view:self];
                    SCIDownload *dwManager = [[SCIDownload alloc] init];
                    [dwManager downloadFileWithURL:[videoURLArray objectAtIndex:i]];
                    [dwManager setDelegate:self];

                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    
                    [self.hud showInView:topMostController().view];
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [SCIUtils prepareAlertPopoverIfNeeded:alert inView:self];

            NSLog(@"[SCInsta] Save media: Displaying alert");

            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [SCIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", NSUUID.UUID.UUIDString]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];

    [self.hud dismiss];
    
    NSLog(@"[SCInsta] Save media: Displaying save dialog");

    [SCIManager showSaveVC:newFilePath];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end */