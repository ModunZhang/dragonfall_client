//
//  UITextViewImpl-common.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 9/8/15.
//
//

#include "UITextViewImpl-common.h"

#define kLabelZOrder  9999

#include "UITextView.h"
#include "base/CCDirector.h"
#include "2d/CCLabel.h"
#include "ui/UIHelper.h"

#define CC_TEXT_VIEW_PADDING 10

NS_CC_BEGIN

namespace ui {
    
    UITextViewImplCommon::UITextViewImplCommon(UITextView* pTextView)
    : UITextViewImpl(pTextView)
    , _label(nullptr)
    , _labelPlaceHolder(nullptr)
    , _textViewInputMode(EditBox::InputMode::SINGLE_LINE)
    , _textViewInputFlag(EditBox::InputFlag::INTIAL_CAPS_ALL_CHARACTERS)
    , _keyboardReturnType(EditBox::KeyboardReturnType::DEFAULT)
    , _colText(Color3B::WHITE)
    , _colPlaceHolder(Color3B::GRAY)
    , _maxLength(-1)
    {
    }
    
    UITextViewImplCommon::~UITextViewImplCommon()
    {
    }
    
    
    bool UITextViewImplCommon::initWithSize(const Size& size)
    {
        do
        {
            
            Rect rect = Rect(0, 0, size.width, size.height);
            
            this->createNativeControl(rect);
            
            initInactiveLabels(size);
            setContentSize(size);
            
            return true;
        }while (0);
        
        return false;
    }
    
    void UITextViewImplCommon::initInactiveLabels(const Size& size)
    {
        const char* pDefaultFontName = this->getNativeDefaultFontName();
        
        _label = Label::create();
        _label->setAnchorPoint(Vec2(0, 1));
        _label->setColor(Color3B::WHITE);
        _label->setVisible(false);
        _textView->addChild(_label, kLabelZOrder);
        
        _labelPlaceHolder = Label::create();
        // align the text vertically center
        _labelPlaceHolder->setAnchorPoint(Vec2(0, 1));
        _labelPlaceHolder->setColor(Color3B::GRAY);
        _textView->addChild(_labelPlaceHolder, kLabelZOrder);
        
        setPlaceholderFont(pDefaultFontName, size.height*2/3);
    }
    
    void UITextViewImplCommon::placeInactiveLabels()
    {
        _label->setPosition(Vec2(CC_TEXT_VIEW_PADDING*2, _contentSize.height - CC_TEXT_VIEW_PADDING));
        _labelPlaceHolder->setPosition(Vec2(CC_TEXT_VIEW_PADDING*2, _contentSize.height - CC_TEXT_VIEW_PADDING));
    }
    
    void UITextViewImplCommon::setInactiveText(const char* pText)
    {
        if(EditBox::InputFlag::PASSWORD == _textViewInputFlag)
        {
            std::string passwordString;
            for(int i = 0; i < strlen(pText); ++i)
                passwordString.append("\u25CF");
            _label->setString(passwordString.c_str());
        }
        else
        {
            _label->setString(pText);
        }
        _label->setEllipsisEabled(true);
        // Clip the text width to fit to the text box
        Size contentSize = _textView->getContentSize();
        float fMaxWidth = contentSize.width - CC_TEXT_VIEW_PADDING * 4;
        float fMaxHeight = contentSize.height - CC_TEXT_VIEW_PADDING;
        _label->setDimensions(fMaxWidth,fMaxHeight);
    }
    
    void UITextViewImplCommon::setFont(const char* pFontName, int fontSize)
    {
        this->setNativeFont(pFontName, fontSize);
        
        if(strlen(pFontName) > 0)
        {
            _label->setSystemFontName(pFontName);
        }
        if(fontSize > 0)
        {
            _label->setSystemFontSize(fontSize);
        }
        //dannyhe
        setPlaceholderFont(pFontName,fontSize);
    }
    
    void UITextViewImplCommon::setFontColor(const Color4B& color)
    {
        this->setNativeFontColor(color);
        
        _label->setTextColor(color);
    }
    
    void UITextViewImplCommon::setPlaceholderFont(const char* pFontName, int fontSize)
    {
        this->setNativePlaceholderFont(pFontName, fontSize);
        
        if( strlen(pFontName) > 0)
        {
            _labelPlaceHolder->setSystemFontName(pFontName);
        }
        if(fontSize > 0)
        {
            _labelPlaceHolder->setSystemFontSize(fontSize);
        }
    }
    
    void UITextViewImplCommon::setPlaceholderFontColor(const Color4B &color)
    {
        this->setNativePlaceholderFontColor(color);
        
        _labelPlaceHolder->setTextColor(color);
    }
    
    void UITextViewImplCommon::setInputMode(EditBox::InputMode inputMode)
    {
        _textViewInputMode = inputMode;
        this->setNativeInputMode(inputMode);
    }
    
    void UITextViewImplCommon::setMaxLength(int maxLength)
    {
        _maxLength = maxLength;
        this->setNativeMaxLength(maxLength);
    }
    
    int UITextViewImplCommon::getMaxLength()
    {
        return _maxLength;
    }
    
    void UITextViewImplCommon::setInputFlag(EditBox::InputFlag inputFlag)
    {
        _textViewInputFlag = inputFlag;
        this->setNativeInputFlag(inputFlag);
    }
    
    void UITextViewImplCommon::setReturnType(EditBox::KeyboardReturnType returnType)
    {
        _keyboardReturnType = returnType;
        this->setNativeReturnType(returnType);
    }
    
    void UITextViewImplCommon::refreshInactiveText()
    {
        setInactiveText(_text.c_str());
        if(_text.size() == 0)
        {
            _label->setVisible(false);
            _labelPlaceHolder->setVisible(true);
        }
        else
        {
            _label->setVisible(true);
            _labelPlaceHolder->setVisible(false);
        }
    }
    
    void UITextViewImplCommon::setText(const char* text)
    {
        this->setNativeText(text);
        _text = text;
        refreshInactiveText();
    }
    
    const char*  UITextViewImplCommon::getText(void)
    {
        return _text.c_str();
    }
    
    void UITextViewImplCommon::setPlaceHolder(const char* pText)
    {
        if (pText != NULL)
        {
            _placeHolder = pText;
            if (_placeHolder.length() > 0 && _text.length() == 0)
            {
                _labelPlaceHolder->setVisible(true);
            }
            
            _labelPlaceHolder->setString(_placeHolder.c_str());
            Size labelSize = _labelPlaceHolder->getContentSize();
            _labelPlaceHolder->setDimensions(_textView->getContentSize().width,0);
            
            this->setNativePlaceHolder(pText);
        }
    }
    
    
    void UITextViewImplCommon::setVisible(bool visible)
    {
        this->setNativeVisible(visible);
    }
    
    void UITextViewImplCommon::setContentSize(const Size& size)
    {
        _contentSize = size;
        CCLOG("[Edit text] content size = (%f, %f)", size.width, size.height);
        placeInactiveLabels();
        
        auto director = cocos2d::Director::getInstance();
        auto glview = director->getOpenGLView();
        Size  controlSize = Size(size.width * glview->getScaleX(),size.height * glview->getScaleY());
        
        this->setNativeContentSize(controlSize);
        
    }
    
    void UITextViewImplCommon::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
    {
        if(flags)
        {
            auto rect = ui::Helper::convertBoundingBoxToScreen(_textView);
            this->updateNativeFrame(rect);
        }
    }
    
    void UITextViewImplCommon::onEnter(void)
    {
        const char* pText = getText();
        if (pText) {
            setInactiveText(pText);
        }
    }
    
    void UITextViewImplCommon::openKeyboard()
    {
        _label->setVisible(false);
        _labelPlaceHolder->setVisible(false);
        
        this->nativeOpenKeyboard();
    }
    
    void UITextViewImplCommon::closeKeyboard()
    {
        this->nativeCloseKeyboard();
    }
    
    void UITextViewImplCommon::onEndEditing(const std::string& text)
    {
        this->setNativeVisible(false);
        
        if(text.size() == 0)
        {
            _label->setVisible(false);
            _labelPlaceHolder->setVisible(true);
        }
        else
        {
            _label->setVisible(true);
            _labelPlaceHolder->setVisible(false);
            setInactiveText(text.c_str());
        }
    }
    
    void UITextViewImplCommon::textViewEditingDidBegin()
    {
        // LOGD("textFieldShouldBeginEditing...");
        cocos2d::ui::UITextViewDelegate *pDelegate = _textView->getDelegate();
        
        if (pDelegate != nullptr)
        {
            pDelegate->textViewEditingDidBegin(_textView);
        }
        
#if CC_ENABLE_SCRIPT_BINDING
        if (NULL != _textView && 0 != _textView->getScriptTextViewHandler())
        {
            cocos2d::CommonScriptData data(_textView->getScriptTextViewHandler(), "began", _textView);
            cocos2d::ScriptEvent event(cocos2d::kCommonEvent, (void *)&data);
            cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
        }
#endif
    }
    
    void UITextViewImplCommon::textViewEditingDidEnd(const std::string& text)
    {
        // LOGD("textFieldShouldEndEditing...");
        _text = text;
        this->refreshInactiveText();
        
        cocos2d::ui::UITextViewDelegate *pDelegate = _textView->getDelegate();
        if (pDelegate != nullptr)
        {
            pDelegate->textViewEditingDidEnd(_textView);
            pDelegate->textViewReturn(_textView);
        }
        
#if CC_ENABLE_SCRIPT_BINDING
        if (_textView != nullptr && 0 != _textView->getScriptTextViewHandler())
        {
            cocos2d::CommonScriptData data(_textView->getScriptTextViewHandler(), "ended", _textView);
            cocos2d::ScriptEvent event(cocos2d::kCommonEvent, (void *)&data);
            cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
            //dannyhe ios not
#if CC_TARGET_PLATFORM != CC_PLATFORM_IOS && CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID
            memset(data.eventName, 0, sizeof(data.eventName));
            strncpy(data.eventName, "return", sizeof(data.eventName));
            event.data = (void *)&data;
            cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
#endif
            //end
        }
#endif
        
        if (_textView != nullptr)
        {
            this->onEndEditing(text);
        }
    }
    
    void UITextViewImplCommon::textViewEditingChanged(const std::string& text)
    {
        // LOGD("editBoxTextChanged...");
        cocos2d::ui::UITextViewDelegate *pDelegate = _textView->getDelegate();
        _text = text;
        if (pDelegate != nullptr)
        {
            pDelegate->textViewTextChanged(_textView, text);
        }
        
#if CC_ENABLE_SCRIPT_BINDING
        if (NULL != _textView && 0 != _textView->getScriptTextViewHandler())
        {
            cocos2d::CommonScriptData data(_textView->getScriptTextViewHandler(), "changed", _textView);
            cocos2d::ScriptEvent event(cocos2d::kCommonEvent, (void *)&data);
            cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
        }
#endif
    }
    //dannyhe
    void UITextViewImplCommon::textViewEditingDidReturn()
    {
        cocos2d::ui::UITextViewDelegate *pDelegate = _textView->getDelegate();
        if (pDelegate != nullptr)
        {
            pDelegate->textViewReturn(_textView);
        }
#if CC_ENABLE_SCRIPT_BINDING
        if (_textView != nullptr && 0 != _textView->getScriptTextViewHandler())
        {
            cocos2d::CommonScriptData data(_textView->getScriptTextViewHandler(), "return", _textView);
            cocos2d::ScriptEvent event(cocos2d::kCommonEvent, (void *)&data);
            cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
        }
#endif
    }
    //end
}

NS_CC_END