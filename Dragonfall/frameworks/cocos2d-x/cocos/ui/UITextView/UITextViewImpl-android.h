//
//  UITextViewImpl-android.h
//  cocos2d_libs
//
//  Created by DannyHe on 9/9/15.
//
//

#ifndef __cocos2d_libs__UITextViewImpl_android__
#define __cocos2d_libs__UITextViewImpl_android__
#include "platform/CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "UITextViewImpl-common.h"


NS_CC_BEGIN

class Label;

namespace ui {

class UITextView;

class UITextViewImplAndroid : public UITextViewImplCommon
{
public:
    /**
     * @js NA
     */
    UITextViewImplAndroid(UITextView* pTextView);
    /**
     * @js NA
     * @lua NA
     */
    virtual ~UITextViewImplAndroid();
    

    virtual bool isEditing() override;
    virtual void createNativeControl(const Rect& frame) override;
    virtual void setNativeFont(const char* pFontName, int fontSize) override;
    virtual void setNativeFontColor(const Color4B& color) override;
    virtual void setNativePlaceholderFont(const char* pFontName, int fontSize) override;
    virtual void setNativePlaceholderFontColor(const Color4B& color) override;
    virtual void setNativeInputMode(EditBox::InputMode inputMode) override;
    virtual void setNativeInputFlag(EditBox::InputFlag inputFlag) override;
    virtual void setNativeReturnType(EditBox::KeyboardReturnType returnType)override;
    virtual void setNativeText(const char* pText) override;
    virtual void setNativePlaceHolder(const char* pText) override;
    virtual void setNativeVisible(bool visible) override;
    virtual void updateNativeFrame(const Rect& rect) override;
    virtual void setNativeContentSize(const Size& size) override {};
    virtual const char* getNativeDefaultFontName() override;
    virtual void nativeOpenKeyboard() override;
    virtual void nativeCloseKeyboard() override;
    virtual void setNativeMaxLength(int maxLength);

    
private:
    virtual void doAnimationWhenKeyboardMove(float duration, float distance)override {}

    int _textViewIndex;
};


}

NS_CC_END


#endif /* #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) */
#endif /* defined(__cocos2d_libs__UITextViewImpl_android__) */
