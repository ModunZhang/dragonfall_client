//
//  UITextViewImpl-android.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 9/9/15.
//
//

#include "UITextViewImpl-android.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "UITextView.h"
#include <jni.h>
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "2d/CCLabel.h"
#include "base/ccUTF8.h"
#include "math/Vec2.h"
#include "ui/UIHelper.h"
#include "base/CCDirector.h"
#include "platform/CCFileUtils.h" //dannyhe
NS_CC_BEGIN


namespace ui {

#define  LOGD(...)  __android_log_print(ANDROID_LOG_ERROR,"UITextViewImpl",__VA_ARGS__)
static void textViewEditingDidBegin(int index);
static void textViewEditingChanged(int index, const std::string& text);
static void textViewEditingDidEnd(int index, const std::string& text);
static void textViewEditingDidReturn(int index);

extern "C"{
    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxEditBoxHelper_textViewEditingDidBegin(JNIEnv *env, jclass, jint index) {
        textViewEditingDidBegin(index);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxEditBoxHelper_textViewEditingChanged(JNIEnv *env, jclass, jint index, jstring text) {
        std::string textString = StringUtils::getStringUTFCharsJNI(env,text);
        textViewEditingChanged(index, textString);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxEditBoxHelper_textViewEditingDidEnd(JNIEnv *env, jclass, jint index, jstring text) {
        std::string textString = StringUtils::getStringUTFCharsJNI(env,text);
        textViewEditingDidEnd(index, textString);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxEditBoxHelper_textViewEditingDidReturn(JNIEnv *env, jclass, jint index) {
        textViewEditingDidReturn(index);
    }
}

static std::unordered_map<int, UITextViewImplAndroid*> s_allTextViewBoxs;


UITextViewImpl* __createSystemTextView(UITextView* pTextView)
{
    return new UITextViewImplAndroid(pTextView);
}


UITextViewImplAndroid::UITextViewImplAndroid(UITextView* pTextView)
: UITextViewImplCommon(pTextView)
, _textViewIndex(-1)
{
}

UITextViewImplAndroid::~UITextViewImplAndroid()
{
    s_allTextViewBoxs.erase(_textViewIndex);
    removeEditBoxJNI(_textViewIndex);
}

void UITextViewImplAndroid::createNativeControl(const Rect& frame)
{
    auto director = cocos2d::Director::getInstance();
    auto glView = director->getOpenGLView();
    auto frameSize = glView->getFrameSize();
    
    auto winSize = director->getWinSize();
    auto leftBottom = _textView->convertToWorldSpace(Point::ZERO);
    
    auto contentSize = frame.size;
    auto rightTop = _textView->convertToWorldSpace(Point(contentSize.width, contentSize.height));
    
    auto uiLeft = frameSize.width / 2 + (leftBottom.x - winSize.width / 2 ) * glView->getScaleX();
    auto uiTop = frameSize.height /2 - (rightTop.y - winSize.height / 2) * glView->getScaleY();
    auto uiWidth = (rightTop.x - leftBottom.x) * glView->getScaleX();
    auto uiHeight = (rightTop.y - leftBottom.y) * glView->getScaleY();
    LOGD("scaleX = %f", glView->getScaleX());
    _textViewIndex = addEditBoxJNI(uiLeft, uiTop, uiWidth, uiHeight, glView->getScaleX());
    s_allTextViewBoxs[_textViewIndex] = this;
}

void UITextViewImplAndroid::setNativeFont(const char* pFontName, int fontSize)
{
    auto director = cocos2d::Director::getInstance();
    auto glView = director->getOpenGLView();
    auto fileUtils = FileUtils::getInstance();
    if(fileUtils->isFileExist(pFontName))
    {   
        std::string reallyFontName("");
        reallyFontName = fileUtils->fullPathForFilename(pFontName);
        setFontEditBoxJNI(_textViewIndex, reallyFontName.c_str(), fontSize * glView->getScaleX());
    }
    else
    {
        setFontEditBoxJNI(_textViewIndex, pFontName, fontSize * glView->getScaleX());
    }
}

void UITextViewImplAndroid::setNativeFontColor(const Color4B& color)
{
    setFontColorEditBoxJNI(_textViewIndex, color.r, color.g, color.b, color.a);
}

void UITextViewImplAndroid::setNativePlaceholderFont(const char* pFontName, int fontSize)
{
    CCLOG("Wraning! You can't change Andriod Hint fontName and fontSize");
}

void UITextViewImplAndroid::setNativePlaceholderFontColor(const Color4B& color)
{
    setPlaceHolderTextColorEditBoxJNI(_textViewIndex, color.r, color.g, color.b, color.a);
}

void UITextViewImplAndroid::setNativeInputMode(EditBox::InputMode inputMode)
{
    setInputModeEditBoxJNI(_textViewIndex, static_cast<int>(inputMode));
    setMultilineEnabledJNI(_textViewIndex,true);
}

void UITextViewImplAndroid::setNativeMaxLength(int maxLength)
{
    setMaxLengthJNI(_textViewIndex, maxLength);
}


void UITextViewImplAndroid::setNativeInputFlag(EditBox::InputFlag inputFlag)
{
    setInputFlagEditBoxJNI(_textViewIndex, static_cast<int>(inputFlag));
}

void UITextViewImplAndroid::setNativeReturnType(EditBox::KeyboardReturnType returnType)
{
    setReturnTypeEditBoxJNI(_textViewIndex, static_cast<int>(returnType));
}

bool UITextViewImplAndroid::isEditing()
{
    return false;
}

void UITextViewImplAndroid::setNativeText(const char* pText)
{
    setTextEditBoxJNI(_textViewIndex, pText);
}

void UITextViewImplAndroid::setNativePlaceHolder(const char* pText)
{
    setPlaceHolderTextEditBoxJNI(_textViewIndex, pText);
}


void UITextViewImplAndroid::setNativeVisible(bool visible)
{ // don't need to be implemented on android platform.
    setVisibleEditBoxJNI(_textViewIndex, visible);
}

void UITextViewImplAndroid::updateNativeFrame(const Rect& rect)
{

    setEditBoxViewRectJNI(_textViewIndex, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

void UITextViewImplAndroid::nativeOpenKeyboard()
{
    //it will also open up the soft keyboard
    setVisibleEditBoxJNI(_textViewIndex,true);
}


void UITextViewImplAndroid::nativeCloseKeyboard()
{
    closeEditBoxKeyboardJNI(_textViewIndex);
}

void textViewEditingDidBegin(int index)
{
    auto it = s_allTextViewBoxs.find(index);
    if (it != s_allTextViewBoxs.end())
    {
        s_allTextViewBoxs[index]->textViewEditingDidBegin();
    }
}
void textViewEditingChanged(int index, const std::string& text)
{
    auto it = s_allTextViewBoxs.find(index);
    if (it != s_allTextViewBoxs.end())
    {
        s_allTextViewBoxs[index]->textViewEditingChanged(text);
    }
}

void textViewEditingDidEnd(int index, const std::string& text)
{
    auto it = s_allTextViewBoxs.find(index);
    if (it != s_allTextViewBoxs.end())
    {
        s_allTextViewBoxs[index]->textViewEditingDidEnd(text);
    }
}

void textViewEditingDidReturn(int index)
{
    auto it = s_allTextViewBoxs.find(index);
    if (it != s_allTextViewBoxs.end())
    {
        s_allTextViewBoxs[index]->textViewEditingDidReturn();
    }
}

const char* UITextViewImplAndroid::getNativeDefaultFontName()
{
    return "";
}

} //end of ui namespace

NS_CC_END

#endif /* #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) */