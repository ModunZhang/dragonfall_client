#include "platform/CCPlatformConfig.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)

#include "UITextViewImpl-winrt.h"
#include "UITextView.h"
#include "CCGLViewImpl-winrt.h"
#include "base/CCScriptSupport.h"
#include "base/ccUTF8.h"
#include "2d/CCLabel.h"
#include "CCWinRTUtils.h"

using namespace Platform;
using namespace Concurrency;
using namespace Windows::System;
using namespace Windows::System::Threading;
using namespace Windows::UI::Core;
using namespace Windows::UI::Input;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::Foundation;
using namespace Windows::UI::ViewManagement;

NS_CC_BEGIN

namespace ui {
	UITextViewWinRT::UITextViewWinRT()
	{

	}

	UITextViewWinRT::~UITextViewWinRT()
	{

	}

	UITextViewWinRT::UITextViewWinRT(Platform::String^ strPlaceHolder, Platform::String^ strText, int maxLength, EditBox::InputMode inputMode, EditBox::InputFlag inputFlag, Windows::Foundation::EventHandler<Platform::String^>^ receiveHandler)
	{
		m_dispatcher = cocos2d::GLViewImpl::sharedOpenGLView()->getDispatcher();
		m_panel = cocos2d::GLViewImpl::sharedOpenGLView()->getPanel();
		m_strText = strText;
		m_strPlaceholder = strPlaceHolder;
		m_inputMode = inputMode;
		m_inputFlag = inputFlag;
		m_receiveHandler = receiveHandler;
		m_maxLength = maxLength;
	}
	void UITextViewWinRT::OpenXamlUITextView(Platform::String^ strText)
	{
		if (m_dispatcher.Get() == nullptr || m_panel.Get() == nullptr)
		{
			return;
		}

		// must create XAML element on main UI thread
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this, strText]()
		{
			critical_section::scoped_lock lock(m_criticalSection);
			m_strText = strText;
			auto item = findXamlElement(m_panel.Get(), "cocos2d_editbox");
			if (item != nullptr)
			{
				Controls::Button^ button = dynamic_cast<Controls::Button^>(item);
				if (button)
				{
					m_flyout = dynamic_cast<Flyout^>(button->Flyout);
					if (m_flyout)
					{
						SetupTextBox();
						auto doneButton = findXamlElement(m_flyout->Content, "cocos2d_editbox_done");
						if (doneButton != nullptr)
						{
							m_doneButton = dynamic_cast<Controls::Button^>(doneButton);
							m_doneToken = m_doneButton->Click += ref new RoutedEventHandler(this, &UITextViewWinRT::Done);
						}

						auto cancelButton = findXamlElement(m_flyout->Content, "cocos2d_editbox_cancel");
						if (cancelButton != nullptr)
						{
							m_cancelButton = dynamic_cast<Controls::Button^>(cancelButton);
							m_cancelToken = m_cancelButton->Click += ref new RoutedEventHandler(this, &UITextViewWinRT::Cancel);
						}
					}
				}

				if (m_flyout)
				{
					auto inputPane = InputPane::GetForCurrentView();
					m_hideKeyboardToken = inputPane->Hiding += ref new TypedEventHandler<InputPane^, InputPaneVisibilityEventArgs^>(this, &UITextViewWinRT::HideKeyboard);

					m_closedToken = m_flyout->Closed += ref new EventHandler<Platform::Object^>(this, &UITextViewWinRT::Closed);
					m_flyout->ShowAt(m_panel.Get());
				}
			}
		}));
	}

	void UITextViewWinRT::Closed(Platform::Object^ sender, Platform::Object^ e)
	{
		critical_section::scoped_lock lock(m_criticalSection);
		RemoveControls();
	}

	void UITextViewWinRT::Done(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
	{
		QueueText();
		HideFlyout();
	}

	void UITextViewWinRT::Cancel(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
	{
		HideFlyout();
	}

	void UITextViewWinRT::HideKeyboard(Windows::UI::ViewManagement::InputPane^ inputPane, Windows::UI::ViewManagement::InputPaneVisibilityEventArgs^ args)
	{
		// we don't want to hide the flyout when the user hide the keyboard
		//HideFlyout();
	}

	void UITextViewWinRT::HideFlyout()
	{
		critical_section::scoped_lock lock(m_criticalSection);
		if (m_flyout)
		{
			m_flyout->Hide();
		}
	}

	void UITextViewWinRT::RemoveControls()
	{
		if (m_dispatcher.Get() && m_panel.Get())
		{
			// run on main UI thread
			m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this]()
			{
				critical_section::scoped_lock lock(m_criticalSection);

				if (m_doneButton != nullptr)
				{
					m_doneButton->Click -= m_doneToken;
					m_doneButton = nullptr;
				}

				if (m_cancelButton != nullptr)
				{
					m_cancelButton->Click -= m_cancelToken;
					m_cancelButton = nullptr;
				}

				m_textBox = nullptr;
				m_passwordBox = nullptr;

				if (m_flyout != nullptr)
				{
					m_flyout->Closed -= m_closedToken;
					m_flyout = nullptr;
				}

				auto inputPane = InputPane::GetForCurrentView();
				inputPane->Hiding -= m_hideKeyboardToken;
			}));
		}
	}

	void UITextViewWinRT::RemoveTextBox()
	{
		auto g = findXamlElement(m_flyout->Content, "cocos2d_editbox_grid");
		auto grid = dynamic_cast<Grid^>(g);
		auto box = findXamlElement(m_flyout->Content, "cocos2d_editbox_textbox");

		if (box)
		{
			removeXamlElement(grid, box);
		}
	}

	void UITextViewWinRT::SetupTextBox()
	{
		RemoveTextBox();
		m_textBox = ref new TextBox;
		m_textBox->Text = m_strText;
		m_textBox->Name = "cocos2d_editbox_textbox";
		m_textBox->MinWidth = 200;
		m_textBox->PlaceholderText = m_strPlaceholder;
		m_textBox->Select(m_textBox->Text->Length(), 0);
		m_textBox->MaxLength = m_maxLength < 0 ? 0 : m_maxLength;
		m_textBox->Height = 100;
		m_textBox->Width = m_panel->ActualWidth;
		m_textBox->TextWrapping = Windows::UI::Xaml::TextWrapping::Wrap;
		m_textBox->AcceptsReturn = true;
		SetInputScope(m_textBox, m_inputMode);
		auto g = findXamlElement(m_flyout->Content, "cocos2d_editbox_grid");
		auto grid = dynamic_cast<Grid^>(g);
		grid->Children->InsertAt(0, m_textBox);
	}

	void UITextViewWinRT::SetInputScope(TextBox^ box, EditBox::InputMode inputMode)
	{
		// TextBox.SetInputScope
		InputScope^ inputScope = ref new InputScope();
		InputScopeName^ name = ref new InputScopeName();

		switch (inputMode)
		{
		case EditBox::InputMode::ANY:
			name->NameValue = InputScopeNameValue::Default;
			break;
		case EditBox::InputMode::EMAIL_ADDRESS:
			name->NameValue = InputScopeNameValue::EmailSmtpAddress;
			break;
		case EditBox::InputMode::NUMERIC:
			name->NameValue = InputScopeNameValue::Number;
			break;
		case EditBox::InputMode::PHONE_NUMBER:
			name->NameValue = InputScopeNameValue::TelephoneNumber;
			break;
		case EditBox::InputMode::URL:
			name->NameValue = InputScopeNameValue::Url;
			break;
		case EditBox::InputMode::DECIMAL:
			name->NameValue = InputScopeNameValue::Number;
			break;
		case EditBox::InputMode::SINGLE_LINE:
			name->NameValue = InputScopeNameValue::Default;
			break;
		default:
			name->NameValue = InputScopeNameValue::Default;
			break;
		}

		box->InputScope = nullptr;
		inputScope->Names->Append(name);
		box->InputScope = inputScope;
	}

	void UITextViewWinRT::QueueText()
	{
		critical_section::scoped_lock lock(m_criticalSection);
		if ((m_passwordBox == nullptr) && (m_textBox == nullptr))
		{
			return;
		}

		m_strText = m_inputFlag == EditBox::InputFlag::PASSWORD ? m_passwordBox->Password : m_textBox->Text;
		std::shared_ptr<cocos2d::InputEvent> e(new UIEditBoxEvent(this, m_strText, m_receiveHandler));
		cocos2d::GLViewImpl::sharedOpenGLView()->QueueEvent(e);
	}
//UITextViewImplWinrt
	UITextViewImpl* __createSystemTextView(UITextView* pTextView)
	{
		return new UITextViewImplWinrt(pTextView);
	}
	
	UITextViewImplWinrt::UITextViewImplWinrt(UITextView* pEditText)
		: UITextViewImpl(pEditText)
		, m_pLabel(NULL)
		, m_pLabelPlaceHolder(NULL)
		, m_eEditBoxInputMode(EditBox::InputMode::SINGLE_LINE)
		, m_eEditBoxInputFlag(EditBox::InputFlag::INTIAL_CAPS_ALL_CHARACTERS)
		, m_eKeyboardReturnType(EditBox::KeyboardReturnType::DEFAULT)
		, m_colText(Color3B::WHITE)
		, m_colPlaceHolder(Color3B::GRAY)
		, m_nMaxLength(-1)
	{

	}

	UITextViewImplWinrt::~UITextViewImplWinrt()
	{

	}
	void UITextViewImplWinrt::openKeyboard()
	{
		if (_delegate != NULL)
		{
			_delegate->textViewEditingDidBegin(_textView);
		}
#if CC_ENABLE_SCRIPT_BINDING
		UITextView* pTextView = this->getTextView();
		if (NULL != pTextView && 0 != pTextView->getScriptTextViewHandler())
		{
			CommonScriptData data(pTextView->getScriptTextViewHandler(), "began", pTextView);
			ScriptEvent event(kCommonEvent, (void*)&data);
			ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
		}
#endif
		std::string placeHolder = m_pLabelPlaceHolder->getString();
		if (placeHolder.length() == 0)
			placeHolder = "Enter value";

		char pText[100] = { 0 };
		std::string text = getText();
		if (text.length())
			strncpy(pText, text.c_str(), 100);


		if (!m_textViewWinrt)
		{
			Windows::Foundation::EventHandler<Platform::String^>^ receiveHandler = ref new Windows::Foundation::EventHandler<Platform::String^>(
				[this](Platform::Object^ sender, Platform::String^ arg)
			{
				setText(PlatformStringTostring(arg).c_str());
				if (_delegate != NULL) {
					_delegate->textViewTextChanged(_textView, getText());
					_delegate->textViewEditingDidEnd(_textView);
					_delegate->textViewReturn(_textView);
				}
			});
			m_textViewWinrt = ref new UITextViewWinRT(stringToPlatformString(placeHolder), stringToPlatformString(getText()), m_nMaxLength, m_eEditBoxInputMode, m_eEditBoxInputFlag, receiveHandler);
		}

		m_textViewWinrt->OpenXamlUITextView(stringToPlatformString(getText()));
	}

	bool UITextViewImplWinrt::initWithSize(const Size& size)
	{
		//! int fontSize = getFontSizeAccordingHeightJni(size.height-12);
		m_pLabel = Label::createWithSystemFont("", "", size.height - 12);
		// align the text vertically center
		m_pLabel->setAnchorPoint(Vec2(0.0f, 0.5f));
		m_pLabel->setPosition(Vec2(5.0, size.height / 2.0f));
		m_pLabel->setTextColor(m_colText);
		_textView->addChild(m_pLabel);

		m_pLabelPlaceHolder = Label::createWithSystemFont("", "", size.height - 12);
		// align the text vertically center
		m_pLabelPlaceHolder->setAnchorPoint(Vec2(0.0f, 0.5f));
		m_pLabelPlaceHolder->setPosition(Vec2(5.0f, size.height / 2.0f));
		m_pLabelPlaceHolder->setVisible(false);
		m_pLabelPlaceHolder->setTextColor(m_colPlaceHolder);
		_textView->addChild(m_pLabelPlaceHolder);

		m_EditSize = size;
		return true;
	}

	void UITextViewImplWinrt::setFont(const char* pFontName, int fontSize)
	{
		if (m_pLabel != NULL)
		{
			if (strlen(pFontName) > 0)
			{
				m_pLabel->setSystemFontName(pFontName);
			}
			if (fontSize > 0)
			{
				m_pLabel->setSystemFontSize(fontSize);
			}
		}

		if (m_pLabelPlaceHolder != NULL) {
			if (strlen(pFontName) > 0)
			{
				m_pLabelPlaceHolder->setSystemFontName(pFontName);
			}
			if (fontSize > 0)
			{
				m_pLabelPlaceHolder->setSystemFontSize(fontSize);
			}
		}
	}

	void UITextViewImplWinrt::setFontColor(const Color4B& color)
	{
		m_colText = color;
		m_pLabel->setTextColor(color);
	}

	void UITextViewImplWinrt::setPlaceholderFont(const char* pFontName, int fontSize)
	{
		if (m_pLabelPlaceHolder != NULL)
		{
			if (strlen(pFontName) > 0)
			{
				m_pLabelPlaceHolder->setSystemFontName(pFontName);
			}
			if (fontSize > 0)
			{
				m_pLabelPlaceHolder->setSystemFontSize(fontSize);
			}
		}
	}

	void UITextViewImplWinrt::setPlaceholderFontColor(const Color4B& color)
	{
		m_colPlaceHolder = color;
		m_pLabelPlaceHolder->setTextColor(color);
	}

	void UITextViewImplWinrt::setInputMode(EditBox::InputMode inputMode)
	{
		m_eEditBoxInputMode = inputMode;
	}

	void UITextViewImplWinrt::setInputFlag(EditBox::InputFlag inputFlag)
	{
		m_eEditBoxInputFlag = inputFlag;
	}

	void UITextViewImplWinrt::setMaxLength(int maxLength)
	{
		m_nMaxLength = maxLength;
	}

	int UITextViewImplWinrt::getMaxLength()
	{
		return m_nMaxLength;
	}

	void UITextViewImplWinrt::setReturnType(EditBox::KeyboardReturnType returnType)
	{
		m_eKeyboardReturnType = returnType;
	}

	bool UITextViewImplWinrt::isEditing()
	{
		return false;
	}

	void UITextViewImplWinrt::setText(const char* pText)
	{
		if (pText != NULL)
		{
			m_strText = pText;

			if (m_strText.length() > 0)
			{
				m_pLabelPlaceHolder->setVisible(false);

				std::string strToShow;

				if (EditBox::InputFlag::PASSWORD == m_eEditBoxInputFlag)
				{
					long length = StringUtils::getCharacterCountInUTF8String(m_strText);
					for (long i = 0; i < length; i++)
					{
						strToShow.append("*");
					}
				}
				else
				{
					strToShow = m_strText;
				}
				m_pLabel->setString(strToShow.c_str());
				// Clip the text width to fit to the text view 
				m_pLabel->setEllipsisEabled(true);
				Size contentSize = _textView->getContentSize();
				float fMaxWidth = contentSize.width - 5.0 * 2;
				float fMaxHeight = contentSize.height - 5.0;
				m_pLabel->setDimensions(fMaxWidth, fMaxHeight);
			}
			else
			{
				m_pLabelPlaceHolder->setVisible(true);
				m_pLabel->setString("");
			}

		}
	}

	const char* UITextViewImplWinrt::getText(void)
	{
		return m_strText.c_str();
	}

	void UITextViewImplWinrt::setPlaceHolder(const char* pText)
	{
		if (pText != NULL)
		{
			m_strPlaceHolder = pText;
			if (m_strPlaceHolder.length() > 0 && m_strText.length() == 0)
			{
				m_pLabelPlaceHolder->setVisible(true);
			}

			m_pLabelPlaceHolder->setString(m_strPlaceHolder.c_str());
		}
	}

	void UITextViewImplWinrt::setPosition(const Vec2& pos)
	{

	}

	void UITextViewImplWinrt::setVisible(bool visible)
	{

	}

	void UITextViewImplWinrt::setContentSize(const Size& size)
	{

	}

	void UITextViewImplWinrt::setAnchorPoint(const Vec2& anchorPoint)
	{

	}

	void UITextViewImplWinrt::draw(cocos2d::Renderer *renderer, cocos2d::Mat4 const &transform, uint32_t flags)
	{

	}

	void UITextViewImplWinrt::doAnimationWhenKeyboardMove(float duration, float distance)
	{

	}

	void UITextViewImplWinrt::closeKeyboard()
	{

	}

	void UITextViewImplWinrt::onEnter(void)
	{

	}

	Platform::String^ UITextViewImplWinrt::stringToPlatformString(std::string strSrc)
	{
		// to wide char
		int nStrLen = MultiByteToWideChar(CP_UTF8, 0, strSrc.c_str(), -1, NULL, 0);
		wchar_t* pWStr = new wchar_t[nStrLen + 1];
		memset(pWStr, 0, nStrLen + 1);
		MultiByteToWideChar(CP_UTF8, 0, strSrc.c_str(), -1, pWStr, nStrLen);
		Platform::String^ strDst = ref new Platform::String(pWStr);
		delete[] pWStr;
		return strDst;
	}

	std::string UITextViewImplWinrt::PlatformStringTostring(Platform::String^ strSrc)
	{
		const wchar_t* pWStr = strSrc->Data();
		int nStrLen = WideCharToMultiByte(CP_UTF8, 0, pWStr, -1, NULL, 0, NULL, NULL);
		char* pStr = new char[nStrLen + 1];
		memset(pStr, 0, nStrLen + 1);
		WideCharToMultiByte(CP_UTF8, 0, pWStr, -1, pStr, nStrLen, NULL, NULL);;

		std::string strDst = std::string(pStr);

		delete[] pStr;
		return strDst;
	}

}
NS_CC_END
#endif //CC_PLATFORM_WINRT