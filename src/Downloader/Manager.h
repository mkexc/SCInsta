#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol SCIDownloadDelegate <NSObject>

// Methods
- (void)downloadDidStart;
- (void)downloadDidProgress:(float)progress;
- (void)downloadDidFinishWithError:(NSError *)error;
- (void)downloadDidFinishWithFileURL:(NSURL *)fileURL;

@end

@interface SCIDownloadManager : NSObject <NSURLSessionDownloadDelegate>

// Properties
@property (nonatomic, weak) id<SCIDownloadDelegate> delegate;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSString *fileExtension;

// Methods
- (instancetype)initWithDelegate:(id<SCIDownloadDelegate>)downloadDelegate;

- (void)downloadFileWithURL:(NSURL *)url fileExtension:(NSString *)fileExtension;
- (NSURL *)moveFileToCacheDir:(NSURL *)oldPath;

@end