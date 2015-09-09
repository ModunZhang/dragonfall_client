//
//  UITextView.h
//  cocos2d_libs
//
//  Created by DannyHe on 9/8/15.
//
//

#ifndef __cocos2d_libs__UITextView__
#define __cocos2d_libs__UITextView__

#include "base/CCIMEDelegate.h"
#include "ui/GUIDefine.h"
#include "ui/UIButton.h"
#include "ui/UIScale9Sprite.h"
//depends on editbox
#include "../UIEditBox/UIEditBox.h"

NS_CC_BEGIN

/**
 * @addtogroup ui
 * @{
 */
namespace ui {
    
    class UITextView;
    class UITextViewImpl;
    
    
    
    class CC_GUI_DLL UITextViewDelegate
    {
    public:
        virtual ~UITextViewDelegate() {};
        
        /**
         * This method is called when an textView gains focus after keyboard is shown.
         * @param editBox The textView object that generated the event.
         */
        virtual void textViewEditingDidBegin(UITextView* textView) {};
        
        
        /**
         * This method is called when an edit box loses focus after keyboard is hidden.
         * @param editBox The textView object that generated the event.
         */
        virtual void textViewEditingDidEnd(UITextView* textView) {};
        
        /**
         * This method is called when the textView text was changed.
         * @param textView The textView object that generated the event.
         * @param text The new text.
         */
        virtual void textViewTextChanged(UITextView* textView, const std::string& text) {};
        
        /**
         * This method is called when the return button was pressed or the outside area of keyboard was touched.
         * @param textView The textView object that generated the event.
         */
        virtual void textViewReturn(UITextView* textView) = 0;
        
    };

    
    /**
     * @brief Class for UITextView.
     *
     * You can use this widget to gather small amounts of text from the user.
     *
     */
    
    class CC_GUI_DLL UITextView
    : public Widget
    , public IMEDelegate
    {
    public:
        /**
         * create a text view with size.
         * @return An autorelease pointer of EditBox, you don't need to release it only if you retain it again.
         */
        static UITextView* create(const Size& size,
                               Scale9Sprite* normalSprite,
                               Scale9Sprite* pressedSprite = nullptr,
                               Scale9Sprite* disabledSprite = nullptr);
        
        
        /**
         * create a text view with size.
         * @return An autorelease pointer of EditBox, you don't need to release it only if you retain it again.
         */
        static UITextView* create(const Size& size,
                               const std::string& normal9SpriteBg,
                               TextureResType texType = TextureResType::LOCAL);
        
        /**
         * Constructor.
         * @js ctor
         * @lua new
         */
        UITextView(void);
        
        /**
         * Destructor.
         * @js NA
         * @lua NA
         */
        virtual ~UITextView(void);
        
        /**
         * Init text view with specified size. This method should be invoked right after constructor.
         * @param size The size of text view.
         * @param normal9SpriteBg  background image of text view.
         * @param texType the resource type, the default value is TextureResType::LOCAL
         * @return Whether initialization is successfully or not.
         */
        bool initWithSizeAndBackgroundSprite(const Size& size,
                                             const std::string& normal9SpriteBg,
                                             TextureResType texType = TextureResType::LOCAL);
        
        
        /**
         * Init text view with specified size. This method should be invoked right after constructor.
         * @param size The size of text view.
         * @param normal9SpriteBg  background image of text view.
         * @return Whether initialization is successfully or not.
         */
        bool initWithSizeAndBackgroundSprite(const Size& size, Scale9Sprite* normal9SpriteBg);
        
        /**
         * Gets/Sets the delegate for text view.
         * @lua NA
         */
        void setDelegate(UITextViewDelegate* delegate);
        
        /**
         * Gets/Sets the rectTrackedNode for text view. the text view will appear above the node
         *
         */
        void setRectTrackedNode(Node * node){
            _rectTrackedNode = node;
        };
        
        Node * getRectTrackedNode(){
            return _rectTrackedNode;
        };
        
        /**
         * @js NA
         * @lua NA
         */
        UITextViewDelegate* getDelegate();
        
#if CC_ENABLE_SCRIPT_BINDING
        /**
         * Registers a script function that will be called for EditBox events.
         *
         * This handler will be removed automatically after onExit() called.
         * @code
         * -- lua sample
         * local function textViewEventHandler(eventType)
         *     if eventType == "began" then
         *         -- triggered when an text view gains focus after keyboard is shown
         *     elseif eventType == "ended" then
         *         -- triggered when an text view loses focus after keyboard is hidden.
         *     elseif eventType == "changed" then
         *         -- triggered when the text view text was changed.
         *     elseif eventType == "return" then
         *         -- triggered when the return button was pressed
         *     end
         * end
         *
         * local textview = UITextView:create(Size(...), Scale9Sprite:create(...))
         * textview:registerScriptTextViewHandler(textViewEventHandler)
         * @endcode
         *
         * @param handler A number that indicates a lua function.
         * @js NA
         * @lua NA
         */
        void registerScriptTextViewHandler(int handler);
        
        /**
         * Unregisters a script function that will be called for UITextView events.
         * @js NA
         * @lua NA
         */
        void unregisterScriptTextViewHandler(void);
        /**
         * get a script Handler
         * @js NA
         * @lua NA
         */
        int  getScriptTextViewHandler(void){ return _scriptTextViewHandler ;}
        
#endif // #if CC_ENABLE_SCRIPT_BINDING
        
        /**
         * Set the text entered in the text view.
         * @param pText The given text.
         */
        void setText(const char* pText);
        
        /**
         * Get the text entered in the text view.
         * @return The text entered in the text view.
         */
        const char* getText(void);
        
        /**
         * Set the font. Only system font is allowed.
         * @param pFontName The font name.
         * @param fontSize The font size.
         */
        void setFont(const char* pFontName, int fontSize);
        
        /**
         * Set the font name. Only system font is allowed.
         * @param pFontName The font name.
         */
        void setFontName(const char* pFontName);
        
        /**
         * Set the font size.
         * @param fontSize The font size.
         */
        void setFontSize(int fontSize);
        
        /**
         * Set the font color of the widget's text.
         */
        void setFontColor(const Color3B& color);
        void setFontColor(const Color4B& color);
        
        /**
         * Set the placeholder's font. Only system font is allowed.
         * @param pFontName The font name.
         * @param fontSize The font size.
         */
        void setPlaceholderFont(const char* pFontName, int fontSize);
        
        /**
         * Set the placeholder's font name. only system font is allowed.
         * @param pFontName The font name.
         */
        void setPlaceholderFontName(const char* pFontName);
        
        /**
         * Set the placeholder's font size.
         * @param fontSize The font size.
         */
        void setPlaceholderFontSize(int fontSize);
        
        /**
         * Set the font color of the placeholder text when the text view is empty.
         */
        void setPlaceholderFontColor(const Color3B& color);
        
        /**
         * Set the font color of the placeholder text when the text view is empty.
         */
        void setPlaceholderFontColor(const Color4B& color);
        
        /**
         * Set a text in the text view that acts as a placeholder when an
         * text view is empty.
         * @param pText The given text.
         */
        void setPlaceHolder(const char* pText);
        
        /**
         * Get a text in the text view that acts as a placeholder when an
         * text view is empty.
         */
        const char* getPlaceHolder(void);
        
        /**
         * Set the input mode of the text view.
         * @param inputMode One of the EditBox::InputMode constants.
         */
        void setInputMode(EditBox::InputMode inputMode);
        
        /**
         * Sets the maximum input length of the text view.
         * Setting this value enables multiline input mode by default.
         * Available on Android, iOS and Windows Phone.
         *
         * @param maxLength The maximum length.
         */
        void setMaxLength(int maxLength);
        
        /**
         * Gets the maximum input length of the text view.
         *
         * @return Maximum input length.
         */
        int getMaxLength();
        
        /**
         * Set the input flags that are to be applied to the text view.
         * @param inputFlag One of the EditBox::InputFlag constants.
         */
        void setInputFlag(EditBox::InputFlag inputFlag);
        
        /**
         * Set the return type that are to be applied to the text view.
         * @param returnType One of the EditBox::KeyboardReturnType constants.
         */
        void setReturnType(EditBox::KeyboardReturnType returnType);
        
        /* override functions */
        virtual void setPosition(const Vec2& pos) override;
        virtual void setVisible(bool visible) override;
        virtual void setContentSize(const Size& size) override;
        virtual void setAnchorPoint(const Vec2& anchorPoint) override;
        
        /**
         * Returns the "class name" of widget.
         */
        virtual std::string getDescription() const override;
        
        /**
         * @js NA
         * @lua NA
         */
        virtual void draw(Renderer *renderer, const Mat4 &parentTransform, uint32_t parentFlags) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onEnter(void) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onExit(void) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardWillShow(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardDidShow(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardWillHide(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardDidHide(IMEKeyboardNotificationInfo& info) override;
        
        /* callback funtions
         * @js NA
         * @lua NA
         */
        void touchDownAction(Ref *sender, TouchEventType controlEvent);
        
    protected:
        virtual void adaptRenderers() override;
        
        void updatePosition(float dt);
        UITextViewImpl*      _textViewImpl;
        UITextViewDelegate*  _delegate;
        
        EditBox::InputMode    _textViewInputMode;
        EditBox::InputFlag    _textViewInputFlag;
        EditBox::KeyboardReturnType  _keyboardReturnType;
        
        Scale9Sprite *_backgroundSprite;
        std::string _text;
        std::string _placeHolder;
        
        std::string _fontName;
        std::string _placeholderFontName;
        
        int _fontSize;
        int _placeholderFontSize;
        
        Color4B _colText;
        Color4B _colPlaceHolder;
        
        int   _maxLength;
        float _adjustHeight;
        
        Node * _rectTrackedNode;
#if CC_ENABLE_SCRIPT_BINDING
        int   _scriptTextViewHandler;
#endif
    };
}

// end of ui group
/// @}
NS_CC_END

#endif /* defined(__cocos2d_libs__UITextView__) */
