#ifndef __UITextviewIMPLWINRT_H__
#define __UITextviewIMPLWINRT_H__
#include "platform/CCPlatformConfig.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
#include "UITextViewImpl.h"
NS_CC_BEGIN

namespace ui {
    class UITextView;
  
    ref class UITextViewWinRT sealed
    {
    public:
        UITextViewWinRT();
        virtual ~UITextViewWinRT();
    internal:

        UITextViewWinRT(Platform::String^ strPlaceHolder, Platform::String^ strText, int maxLength, EditBox::InputMode inputMode, EditBox::InputFlag inputFlag, Windows::Foundation::EventHandler<Platform::String^>^ receiveHandler);
        void OpenXamlUITextView(Platform::String^ strText);

    private:
        Windows::UI::Xaml::Controls::Control^ CreateUITextView(int maxLength);
        void SetInputScope(Windows::UI::Xaml::Controls::TextBox^ box, EditBox::InputMode inputMode);

        void UITextViewWinRT::SetupTextBox();
        void UITextViewWinRT::SetupPasswordBox();
        void UITextViewWinRT::RemoveTextBox();
        void RemoveControls();
        void QueueText();

        void Done(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
        void Cancel(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
        void Closed(Platform::Object^ sender, Platform::Object^ e);
        void HideKeyboard(Windows::UI::ViewManagement::InputPane^ inputPane, Windows::UI::ViewManagement::InputPaneVisibilityEventArgs^ args);
        void HideFlyout();

        Platform::Agile<Windows::UI::Core::CoreDispatcher> m_dispatcher;
        Platform::Agile<Windows::UI::Xaml::Controls::Panel> m_panel;
        Windows::Foundation::EventHandler<Platform::String^>^ m_receiveHandler;

        Windows::UI::Xaml::Controls::TextBox^ m_textBox;
        Windows::UI::Xaml::Controls::PasswordBox^ m_passwordBox;
        Windows::UI::Xaml::Controls::Flyout^ m_flyout;
        Windows::UI::Xaml::Controls::Button^ m_doneButton;
        Windows::UI::Xaml::Controls::Button^ m_cancelButton;

        Windows::Foundation::EventRegistrationToken m_doneToken;
        Windows::Foundation::EventRegistrationToken m_cancelToken;
        Windows::Foundation::EventRegistrationToken m_closedToken;
        Windows::Foundation::EventRegistrationToken m_hideKeyboardToken;

        Concurrency::critical_section m_criticalSection;

        Platform::String^ m_strText;
        Platform::String^ m_strPlaceholder;
        EditBox::InputMode m_inputMode;
        EditBox::InputFlag m_inputFlag;
        int m_maxLength;
    };

    class CC_GUI_DLL UITextViewImplWinrt : public UITextViewImpl
    {
    public:
        UITextViewImplWinrt(UITextView* pTextView);
        virtual ~UITextViewImplWinrt();
        
        virtual bool initWithSize(const Size& size);
        virtual void setFont(const char* pFontName, int fontSize);
        virtual void setFontColor(const Color4B& color);
        virtual void setPlaceholderFont(const char* pFontName, int fontSize);
        virtual void setPlaceholderFontColor(const Color4B& color);
        virtual void setInputMode(EditBox::InputMode inputMode);
        virtual void setInputFlag(EditBox::InputFlag inputFlag);
        virtual void setMaxLength(int maxLength);
        virtual int  getMaxLength();
        virtual void setReturnType(EditBox::KeyboardReturnType returnType);
        virtual bool isEditing();
        
        virtual void setText(const char* pText);
        virtual const char* getText(void);
        virtual void setPlaceHolder(const char* pText);
        virtual void setPosition(const Vec2& pos);
        virtual void setVisible(bool visible);
        virtual void setContentSize(const Size& size);
        virtual void setAnchorPoint(const Vec2& anchorPoint);
        virtual void draw(cocos2d::Renderer *renderer, cocos2d::Mat4 const &transform, uint32_t flags) override;
        virtual void doAnimationWhenKeyboardMove(float duration, float distance);
        virtual void openKeyboard();
        virtual void closeKeyboard();
        virtual void onEnter(void);
    private:
        Platform::String^ stringToPlatformString(std::string strSrc);
        std::string PlatformStringTostring(Platform::String^ strSrc);
    private:
        
		UITextViewWinRT^ m_textViewWinrt;

        Label* m_pLabel;
        Label* m_pLabelPlaceHolder;
        EditBox::InputMode    m_eEditBoxInputMode;
        EditBox::InputFlag    m_eEditBoxInputFlag;
        EditBox::KeyboardReturnType  m_eKeyboardReturnType;
         
         std::string m_strText;
         std::string m_strPlaceHolder;
         
         Color4B m_colText;
         Color4B m_colPlaceHolder;
         
         int   m_nMaxLength;
         Size m_EditSize;
    };
}

NS_CC_END
#endif //CC_PLATFORM_WINRT
#endif