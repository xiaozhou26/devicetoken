#import <Foundation/Foundation.h>
#import <DeviceCheck/DeviceCheck.h>

int main() {
    @autoreleasepool {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        #ifdef TEST_ENV
        // Simulate DeviceCheck behavior in test environment
        NSString *base64Token = @"dGVzdHRva2Vu"; // Example base64 string
        printf("%s\n", [base64Token UTF8String]);
        dispatch_semaphore_signal(sema);
        #else
        // Real DeviceCheck code for production
        DCDevice *device = [DCDevice currentDevice];
        if ([device isSupported]) {
            [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                if (error == nil) {
                    NSString *base64Token = [token base64EncodedStringWithOptions:0];
                    printf("%s\n", [base64Token UTF8String]);
                } else {
                    fprintf(stderr, "Error: %s\n", [[error localizedDescription] UTF8String]);
                }
                dispatch_semaphore_signal(sema);
            }];
        } else {
            printf("unsupported device\n");
            dispatch_semaphore_signal(sema);
        }
        #endif

        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    return 0;
}
