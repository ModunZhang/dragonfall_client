//
//  UITextViewImpl-ios.h
//  cocos2d_libs
//
//  Created by DannyHe on 9/8/15.
//
//

#ifndef __cocos2d_libs__UITextViewImpl_ios__
#define __cocos2d_libs__UITextViewImpl_ios__

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include "UITextViewImpl-common.h"

@class UITextViewImplIOS_objc;
@class UIFont;

NS_CC_BEGIN

namespace ui {
    
    class UITextView;
    
    class UITextViewImplIOS : public UITextViewImplCommon
    {
    public:
        /**
         * @js NA
         */
        UITextViewImplIOS(UITextView* pTextView);
        /**
         * @js NA
         * @lua NA
         */
        virtual ~UITextViewImplIOS();
        virtual void setPosition(const Vec2& pos) override;
        virtual void setAnchorPoint(const Vec2& anchorPoint) override;
        virtual void updatePosition(float dt) override;
        
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
        virtual void setNativeContentSize(const Size& size) override;
        virtual const char* getNativeDefaultFontName() override;
        virtual void nativeOpenKeyboard() override;
        virtual void nativeCloseKeyboard() override;
        
        //need to remove siri text
        virtual const char* getText(void)override;
        
        virtual void doAnimationWhenKeyboardMove(float duration, float distance);
    private:
        UIFont*         constructFont(const char* fontName, int fontSize);
        void			adjustTextViewPosition();
        
        UITextViewImplIOS_objc* _systemControl;
        Vec2         _position;
        Vec2         _anchorPoint;
    };
    
    
}

NS_CC_END

#endif

#endif /* defined(__cocos2d_libs__UITextViewImpl_ios__) */
