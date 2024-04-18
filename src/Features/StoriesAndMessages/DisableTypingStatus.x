#import "../../InstagramHeaders.h"
#import "../../Manager.h"

%hook IGDirectTypingStatusService
- (id)initWithUserPK:(id)arg1
realtimeMessageDispatcher:(id)arg2
realtimeStatusQuerier:(id)arg3
featureSetProvider:(id)arg4
logger:(id)arg5
directPrivacySettings:(id)arg6
launcherSet:(id)arg7
timerCreationBlock:(id)arg8 {
    if ([BHIManager noTypingStatus]) {
        NSLog(@"[BHInsta] Prevented typing status from being sent");

        return nil;
    } else {
        return %orig;
    }
}
%end

%hook IGDirectRealtimeTypingStatusSender
- (id)initWithRealtimeStatusQuerier:(id)arg1 realtimeMessageDispatcher:(id)arg2 {
    if ([BHIManager noTypingStatus]) {
        NSLog(@"[BHInsta] Prevented typing status from being sent");

        return nil;
    } else {
        return %orig;
    }
}
%end