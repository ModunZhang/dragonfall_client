//
//  UITextViewImpl-ios.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 9/8/15.
//
//

#include "UITextViewImpl-ios.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#define kLabelZOrder  9999

#include "extensions/ExtensionMacros.h"
#include "UITextView.h"
#include "base/CCDirector.h"
#include "2d/CCLabel.h"
#import "platform/ios/CCEAGLView-ios.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CC_TEXT_VIEW_PADDING 10

#define getTextViewImplIOS() ((cocos2d::ui::UITextViewImplIOS *)dtextView_)

@interface UICustomUITextView : UITextView
{
}
@end

//maybe not work!!
@implementation UICustomUITextView

@end

@interface UITextViewImplIOS_objc : NSObject <UITextViewDelegate>
{
    UICustomUITextView* textView_;
    void* dtextView_;
    BOOL editState_;
}

@property(nonatomic, retain) UITextView* textView;
@property(nonatomic, readonly, getter = isEditState) BOOL editState;
@property(nonatomic, assign) void* dtextView;

-(id) initWithFrame: (CGRect) frameRect textView: (void*) dtextView;
-(void) doAnimationWhenKeyboardMoveWithDuration:(float)duration distance:(float)distance;
-(void) setPosition:(CGPoint) pos;
-(void) setContentSize:(CGSize) size;
-(void) visit;
-(void) openKeyboard;
-(void) closeKeyboard;
@end

@implementation UITextViewImplIOS_objc

@synthesize textView = textView_;
@synthesize editState = editState_;
@synthesize dtextView = dtextView_;

-(id) initWithFrame:(CGRect)frameRect textView:(void *)dtextView
{
    self = [super init];
    if (self)
    {
        editState_ = NO;
        self.textView = [[UICustomUITextView alloc]initWithFrame:frameRect];
        
        [self.textView setTextColor:[UIColor whiteColor]];
        textView_.font = [UIFont systemFontOfSize:10]; //TODO need to delete hard code here.
        //debug frame of textview
#if (COCOS2D_DEBUG>0)
        textView_.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.2];
#else
        textView_.backgroundColor = [UIColor clearColor];
#endif
        textView_.delegate = self;
        textView_.hidden = true;
        [textView_ setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textView_ setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        textView_.returnKeyType = UIReturnKeyDefault;
        self.dtextView = dtextView;
    }
    return self;
}

-(void) doAnimationWhenKeyboardMoveWithDuration:(float)duration distance:(float)distance
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview doAnimationWhenKeyboardMoveWithDuration:duration distance:distance];
}

-(void) setPosition:(CGPoint) pos
{
    CGRect frame = [textView_ frame];
    frame.origin = pos;
    [textView_ setFrame:frame];
}

-(void) setContentSize:(CGSize) size
{
    size.width -= CC_TEXT_VIEW_PADDING;
    size.height -= CC_TEXT_VIEW_PADDING;
    CGRect frame = [textView_ frame];
    frame.size = size;
    [textView_ setFrame:frame];
}

-(void) visit
{
    
}

-(void) openKeyboard
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview addSubview:textView_];
    [textView_ becomeFirstResponder];
}

-(void) closeKeyboard
{
    [textView_ resignFirstResponder];
    [textView_ removeFromSuperview];
}

-(void)animationSelector
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview doAnimationWhenAnotherEditBeClicked];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    // CCLOG("textViewShouldBeginEditing...");
    editState_ = YES;
    
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    if ([eaglview isKeyboardShown])
    {
        [self performSelector:@selector(animationSelector) withObject:nil afterDelay:0.0f];
    }
    getTextViewImplIOS()->textViewEditingDidBegin();
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
     CCLOG("textViewShouldEndEditing...");
     editState_ = NO;
    const char* inputText = [textView.text UTF8String];
    getTextViewImplIOS()->textViewEditingDidEnd(inputText);
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (getTextViewImplIOS()->getMaxLength() < 0)
    {
        return YES;
    }
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    return newLength <= getTextViewImplIOS()->getMaxLength();
}

- (void)textViewDidChange:(UITextView *)textView{
    
    const char* inputText = [textView.text UTF8String];
    getTextViewImplIOS()->textViewEditingChanged(inputText);
}
@end

//MARK:CPP


NS_CC_BEGIN

namespace ui {
    
UITextViewImpl* __createSystemTextView(UITextView* pTextView)
{
    return new UITextViewImplIOS(pTextView);
}

UITextViewImplIOS::UITextViewImplIOS(UITextView* pTextView)
: UITextViewImplCommon(pTextView)
,_systemControl(nullptr)
, _anchorPoint(Vec2(0.5f, 0.5f))
{
    
}

UITextViewImplIOS::~UITextViewImplIOS()
{
    [_systemControl release];
    _systemControl = nil;
}

void UITextViewImplIOS::createNativeControl(const Rect& frame)
{
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    
    Rect rect(0, 0, frame.size.width * glview->getScaleX(), frame.size.height * glview->getScaleY());
    
    float factor = cocos2d::Director::getInstance()->getContentScaleFactor();
    
    rect.size.width /= factor;
    rect.size.height /= factor;
    
    _systemControl = [[UITextViewImplIOS_objc alloc] initWithFrame:CGRectMake(rect.origin.x,
                                                                             rect.origin.y,
                                                                             rect.size.width,
                                                                             rect.size.height)
                                                          textView:this];
    
}

bool UITextViewImplIOS::isEditing()
{
    return [_systemControl isEditState] ? true : false;
}

void UITextViewImplIOS::doAnimationWhenKeyboardMove(float duration, float distance)
{
    if ([_systemControl isEditState] || distance < 0.0f)
    {
        [_systemControl doAnimationWhenKeyboardMoveWithDuration:duration distance:distance];
    }
}

void UITextViewImplIOS::setNativeFont(const char* pFontName, int fontSize)
{
    UIFont* textFont = constructFont(pFontName, fontSize);
    if(textFont != nil) {
        [_systemControl.textView setFont:textFont];
    }
}

void UITextViewImplIOS::setNativeFontColor(const Color4B& color)
{
    _systemControl.textView.textColor = [UIColor colorWithRed:color.r / 255.0f
                                                         green:color.g / 255.0f
                                                          blue:color.b / 255.0f
                                                         alpha:color.a / 255.f];
    
}

void UITextViewImplIOS::setNativePlaceholderFont(const char* pFontName, int fontSize)
{
    //TODO::
}

void UITextViewImplIOS::setNativePlaceholderFontColor(const Color4B& color)
{
    //TODO::
}

void UITextViewImplIOS::setNativeInputMode(EditBox::InputMode inputMode)
{
    switch (inputMode)
    {
        case EditBox::InputMode::EMAIL_ADDRESS:
            _systemControl.textView.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case EditBox::InputMode::NUMERIC:
            _systemControl.textView.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case EditBox::InputMode::PHONE_NUMBER:
            _systemControl.textView.keyboardType = UIKeyboardTypePhonePad;
            break;
        case EditBox::InputMode::URL:
            _systemControl.textView.keyboardType = UIKeyboardTypeURL;
            break;
        case EditBox::InputMode::DECIMAL:
            _systemControl.textView.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case EditBox::InputMode::SINGLE_LINE:
            _systemControl.textView.keyboardType = UIKeyboardTypeDefault;
            break;
        case EditBox::InputMode::ASCII_CAPABLE: //dannyhe
            _systemControl.textView.keyboardType = UIKeyboardTypeASCIICapable;
            break;
        default:
            _systemControl.textView.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

void UITextViewImplIOS::setNativeInputFlag(EditBox::InputFlag inputFlag)
{
    switch (inputFlag)
    {
        case EditBox::InputFlag::PASSWORD:
            _systemControl.textView.secureTextEntry = YES;
            break;
        case EditBox::InputFlag::INITIAL_CAPS_WORD:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
            break;
        case EditBox::InputFlag::INITIAL_CAPS_SENTENCE:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            break;
        case EditBox::InputFlag::INTIAL_CAPS_ALL_CHARACTERS:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            break;
        case EditBox::InputFlag::SENSITIVE:
            _systemControl.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            break;
        default:
            break;
    }
}

extern NSString* removeSiriString(NSString* str);
    
const char*  UITextViewImplIOS::getText(void)
{
    return [removeSiriString(_systemControl.textView.text) UTF8String];
}


void UITextViewImplIOS::setNativeReturnType(EditBox::KeyboardReturnType returnType)
{
    switch (returnType) {
        case EditBox::KeyboardReturnType::DEFAULT:
            _systemControl.textView.returnKeyType = UIReturnKeyDefault;
            break;
        case EditBox::KeyboardReturnType::DONE:
            _systemControl.textView.returnKeyType = UIReturnKeyDone;
            break;
        case EditBox::KeyboardReturnType::SEND:
            _systemControl.textView.returnKeyType = UIReturnKeySend;
            break;
        case EditBox::KeyboardReturnType::SEARCH:
            _systemControl.textView.returnKeyType = UIReturnKeySearch;
            break;
        case EditBox::KeyboardReturnType::GO:
            _systemControl.textView.returnKeyType = UIReturnKeyGo;
            break;
        default:
            _systemControl.textView.returnKeyType = UIReturnKeyDefault;
            break;
    }
}

void UITextViewImplIOS::setNativeText(const char* pText)
{
    NSString* nsText =[NSString stringWithUTF8String:pText];
    if ([nsText compare:_systemControl.textView.text] != NSOrderedSame)
    {
        _systemControl.textView.text = nsText;
    }
}

void UITextViewImplIOS::setNativePlaceHolder(const char* pText)
{
//        _systemControl.textView.placeholder = [NSString stringWithUTF8String:pText];
    
}

void UITextViewImplIOS::setNativeVisible(bool visible)
{
    _systemControl.textView.hidden = !visible;
}

void UITextViewImplIOS::updateNativeFrame(const Rect& rect)
{
    //no-op
}

void UITextViewImplIOS::setNativeContentSize(const Size& size)
{
    auto director = cocos2d::Director::getInstance();
    auto glview = director->getOpenGLView();
    CCEAGLView *eaglview = static_cast<CCEAGLView *>(glview->getEAGLView());
    float factor = eaglview.contentScaleFactor;
    
    [_systemControl setContentSize:CGSizeMake(size.width / factor, size.height / factor)];
}

const char* UITextViewImplIOS::getNativeDefaultFontName()
{
    const char* pDefaultFontName = [[_systemControl.textView.font fontName] UTF8String];
    return pDefaultFontName;
}

void UITextViewImplIOS::nativeOpenKeyboard()
{
    _systemControl.textView.hidden = NO;
    [_systemControl openKeyboard];
}

void UITextViewImplIOS::nativeCloseKeyboard()
{
    [_systemControl closeKeyboard];
}

UIFont* UITextViewImplIOS::constructFont(const char *fontName, int fontSize)
{
    CCASSERT(fontName != nullptr, "fontName can't be nullptr");
    CCEAGLView *eaglview = static_cast<CCEAGLView *>(cocos2d::Director::getInstance()->getOpenGLView()->getEAGLView());
    float retinaFactor = eaglview.contentScaleFactor;
    NSString * fntName = [NSString stringWithUTF8String:fontName];
    
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    float scaleFactor = glview->getScaleX();
    
    if (fontSize == -1)
    {
        fontSize = [_systemControl.textView frame].size.height*2/3;
    }
    else
    {
        fontSize = fontSize * scaleFactor / retinaFactor;
    }
    
    UIFont *textFont = nil;
    if (strlen(fontName) > 0)
    {
        textFont = [UIFont fontWithName:fntName size:fontSize];
    }
    else
    {
        textFont = [UIFont systemFontOfSize:fontSize];
    }
    return textFont;
}

void UITextViewImplIOS::setPosition(const Vec2& pos)
{
    _position = pos;
    adjustTextViewPosition();
}

void UITextViewImplIOS::setAnchorPoint(const Vec2& anchorPoint)
{
    CCLOG("[Edit text] anchor point = (%f, %f)", anchorPoint.x, anchorPoint.y);
    _anchorPoint = anchorPoint;
    setPosition(_position);
}

void UITextViewImplIOS::updatePosition(float dt)
{
    if (nullptr != _systemControl) {
        this->adjustTextViewPosition();
    }
}

static CGPoint convertDesignCoordToScreenCoord(const Vec2& designCoord)
{
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) glview->getEAGLView();
    
    float viewH = (float)[eaglview getHeight];
    
    Vec2 visiblePos = Vec2(designCoord.x * glview->getScaleX(), designCoord.y * glview->getScaleY());
    Vec2 screenGLPos = visiblePos + glview->getViewPortRect().origin;
    
    CGPoint screenPos = CGPointMake(screenGLPos.x, viewH - screenGLPos.y);
    
    float factor = eaglview.contentScaleFactor;
    screenPos.x = screenPos.x / factor;
    screenPos.y = screenPos.y / factor;
    
    CCLOGINFO("[EditBox] pos x = %f, y = %f", screenGLPos.x, screenGLPos.y);
    return screenPos;
}


void UITextViewImplIOS::adjustTextViewPosition()
{
    Size contentSize = _textView->getContentSize();
    Rect rect = Rect(0, 0, contentSize.width, contentSize.height);
    rect = RectApplyAffineTransform(rect, _textView->nodeToWorldTransform());
    
    Vec2 designCoord = Vec2(rect.origin.x+CC_TEXT_VIEW_PADDING, rect.origin.y + rect.size.height - CC_TEXT_VIEW_PADDING);
    [_systemControl setPosition:convertDesignCoordToScreenCoord(designCoord)];
}
    
}

NS_CC_END



#endif /* #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) */