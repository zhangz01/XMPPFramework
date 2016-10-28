#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

typedef NS_ENUM(NSInteger, XMPPMessageChatState) {
    XMPPMessageChatStateDone = 0,
    XMPPMessageChatStateComposing = 1,
    XMPPMessageChatStatePaused = 2,
    XMPPMessageChatStateInactive = 3,
    XMPPMessageChatStateGone = 4,
    XMPPMessageChatStateSending = 10,
    XMPPMessageChatStateError = -1
};


@interface XMPPMessage (XEP_0085)

- (NSString *)chatState;

- (BOOL)hasChatState;

- (BOOL)hasActiveChatState;
- (BOOL)hasComposingChatState;
- (BOOL)hasPausedChatState;
- (BOOL)hasInactiveChatState;
- (BOOL)hasGoneChatState;
- (BOOL)hasSendingChatState;
- (BOOL)hasErrorChatState;

- (void)addActiveChatState;
- (void)addComposingChatState;
- (void)addPausedChatState;
- (void)addInactiveChatState;
- (void)addGoneChatState;
- (void)addSendingChatState;
- (void)addErrorChatState;
@end
