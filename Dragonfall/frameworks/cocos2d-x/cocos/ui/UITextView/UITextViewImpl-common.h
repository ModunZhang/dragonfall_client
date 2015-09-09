//
//  UITextViewImpl-common.h
//  cocos2d_libs
//
//  Created by DannyHe on 9/8/15.
//
//

#ifndef __cocos2d_libs__UITextViewImpl_common__
#define __cocos2d_libs__UITextViewImpl_common__

#include "platform/CCPlatformConfig.h"
#include "UITextViewImpl.h"


NS_CC_BEGIN

namespace ui {
    
    class UITextView;
    
    class UITextViewImplCommon : public UITextViewImpl
    {
    public:
        /**
         * @js NA
         */
        UITextViewImplCommon(UITextView* pTextView);
        /**
         * @js NA
         * @lua NA
         */
        virtual ~UITextViewImplCommon();
        
        virtual bool initWithSize(const Size& size);
        
        virtual void setFont(const char* pFontName, int fontSize);
        virtual void setFontColor(const Color4B& color);
        virtual void setPlaceholderFont(const char* pFontName, int fontSize);
        virtual void setPlaceholderFontColor(const Color4B& color);
        virtual void setInputMode(EditBox::InputMode inputMode);
        virtual void setInputFlag(EditBox::InputFlag inputFlag);
        virtual void setReturnType(EditBox::KeyboardReturnType returnType);
        virtual void setText(const char* pText);
        virtual void setPlaceHolder(const char* pText);
        virtual void setVisible(bool visible);
        
        
        virtual void setMaxLength(int maxLength);
        virtual int  getMaxLength();
        
        virtual const char* getText(void);
        virtual void refreshInactiveText();
        
        virtual void setContentSize(const Size& size);
        
        virtual void setAnchorPoint(const Vec2& anchorPoint){}
        virtual void setPosition(const Vec2& pos) {}
        
        /**
         * @js NA
         * @lua NA
         */
        virtual void draw(Renderer *renderer, const Mat4 &parentTransform, uint32_t parentFlags) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onEnter(void);
        virtual void openKeyboard();
        virtual void closeKeyboard();
        
        virtual void onEndEditing(const std::string& text);
        
        void textViewEditingDidBegin();
        void textViewEditingChanged(const std::string& text);
        void textViewEditingDidEnd(const std::string& text);
        void textViewEditingDidReturn();  //dannyhe
        
        virtual bool isEditing() = 0;
        virtual void createNativeControl(const Rect& frame) = 0;
        virtual void setNativeFont(const char* pFontName, int fontSize) = 0;
        virtual void setNativeFontColor(const Color4B& color) = 0;
        virtual void setNativePlaceholderFont(const char* pFontName, int fontSize) = 0;
        virtual void setNativePlaceholderFontColor(const Color4B& color) = 0;
        virtual void setNativeInputMode(EditBox::InputMode inputMode) = 0;
        virtual void setNativeInputFlag(EditBox::InputFlag inputFlag) = 0;
        virtual void setNativeReturnType(EditBox::KeyboardReturnType returnType) = 0;
        virtual void setNativeText(const char* pText) = 0;
        virtual void setNativePlaceHolder(const char* pText) = 0;
        virtual void setNativeVisible(bool visible) = 0;
        virtual void updateNativeFrame(const Rect& rect) = 0;
        virtual void setNativeContentSize(const Size& size) = 0;
        virtual const char* getNativeDefaultFontName() = 0;
        virtual void nativeOpenKeyboard() = 0;
        virtual void nativeCloseKeyboard() = 0;
        virtual void setNativeMaxLength(int maxLength) {};
        
        
    private:
        void			initInactiveLabels(const Size& size);
        void			setInactiveText(const char* pText);
        void            placeInactiveLabels();
        
        Label* _label;
        Label* _labelPlaceHolder;
        EditBox::InputMode    _textViewInputMode;
        EditBox::InputFlag    _textViewInputFlag;
        EditBox::KeyboardReturnType  _keyboardReturnType;
        
        std::string _text;
        std::string _placeHolder;
        
        Color4B _colText;
        Color4B _colPlaceHolder;
        
        int   _maxLength;
        Size _contentSize;
    };
    
    
}

NS_CC_END

#endif /* defined(__cocos2d_libs__UITextViewImpl_common__) */
