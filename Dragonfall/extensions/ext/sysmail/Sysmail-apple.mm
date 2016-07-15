//
//  Sysmail.m
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#import "Sysmail.h"
#import <Foundation/Foundation.h>
#import <messageUI/messageUI.h>
@interface sysmail : NSObject <MFMailComposeViewControllerDelegate>
@property(assign,nonatomic)int lua_function_ref;
@property(retain,nonatomic)MFMailComposeViewController *mailCompose;

-(BOOL)sendMail:(NSArray *)to
   ccRecipients:(NSArray *)cc
        subject:(NSString*)subject
           body:(NSString*)body;
-(instancetype)initWithLuaFunctionRef:(int)ref_id;
@end

@implementation MFMailComposeViewController (rotate)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
@end

@implementation sysmail
@synthesize lua_function_ref;
@synthesize mailCompose;
-(instancetype)initWithLuaFunctionRef:(int)ref_id
{
    self = [super init];
    if (self)
    {
        self.lua_function_ref = ref_id;
    }
    return self;
}

-(BOOL)sendMail:(NSArray *)to
   ccRecipients:(NSArray *)cc
        subject:(NSString *)subject
           body:(NSString *)body
{
    if(!CanSenMail())
    {
        NSLog(@"can not send mail");
        return NO;
    }
    else
    {
        MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
        self.mailCompose = mailPicker;
        [mailPicker release];
        [mailPicker setMailComposeDelegate:self];
        [mailPicker setToRecipients:to];
        [mailPicker setCcRecipients:cc];
        [mailPicker setSubject:subject];
        [mailPicker setMessageBody:body isHTML:NO];
        [[[[UIApplication sharedApplication]keyWindow] rootViewController]presentModalViewController:mailPicker animated:YES];
    }
    return YES;
}

extern void OnSendMailEnd(int function_id,std::string event);

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    if (self.lua_function_ref > 0)
    {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                OnSendMailEnd(self.lua_function_ref,"Canceled");
                break;
            case MFMailComposeResultSaved:
                OnSendMailEnd(self.lua_function_ref,"Saved");
                break;
            case MFMailComposeResultSent:
                OnSendMailEnd(self.lua_function_ref,"Sent");
                break;
            case MFMailComposeResultFailed:
                OnSendMailEnd(self.lua_function_ref,"Failed");
                break;
            default:
                break;
        }
    }
    [controller dismissModalViewControllerAnimated:YES];
    self.mailCompose = nil;
}
@end

static sysmail* g_instance_mail = NULL;

bool SendMail(std::vector<std::string> to,std::string subject,std::string body,int lua_function_ref)
{
    if(to.size() == 0) return false;
    NSMutableArray * toArray = [[[NSMutableArray alloc]init]autorelease];
    [toArray addObject:[NSString stringWithUTF8String:to[0].c_str()]];
    
    NSMutableArray * ccArray = [[[NSMutableArray alloc]init]autorelease];
    for (size_t index = 1; index < to.size(); index ++) {
        [ccArray addObject:[NSString stringWithUTF8String:to[index].c_str()]];
    }
    if (g_instance_mail == NULL) {
        g_instance_mail = [[sysmail alloc]initWithLuaFunctionRef:lua_function_ref];
        return [g_instance_mail sendMail:toArray
                            ccRecipients:ccArray
                                 subject:[NSString stringWithUTF8String:subject.c_str()]
                                    body:[NSString stringWithUTF8String:body.c_str()]];
    }
    else
    {
        g_instance_mail.lua_function_ref = lua_function_ref;
        return [g_instance_mail sendMail:toArray
                            ccRecipients:ccArray
                                 subject:[NSString stringWithUTF8String:subject.c_str()]
                                    body:[NSString stringWithUTF8String:body.c_str()]];
    }
}

bool CanSenMail(){
    return [MFMailComposeViewController canSendMail];
}