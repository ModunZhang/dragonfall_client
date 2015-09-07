/****************************************************************************
 Copyright (c) 2013      Zynga Inc.
 Copyright (c) 2013-2015 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#ifndef _CCLabelTextFormatter_h_
#define _CCLabelTextFormatter_h_

/// @cond DO_NOT_SHOW

#include "platform/CCPlatformMacros.h"
 //dannyhe
#include "2d/CCFontAtlas.h"
#include "math/Vec2.h"
#include "math/CCGeometry.h"
 //end
NS_CC_BEGIN

class Label;
//dannyhe
class labelUtil;
struct LetterInfo_
{
    FontLetterDefinition def;
    Vec2 position;
    Size  contentSize;
    int   atlasIndex;
};
struct Status
{
    Status()
    {
        is_width_max = false;
        is_height_max = false;
        is_cut = false;
    }
    bool is_width_max;
    bool is_height_max;
    bool is_cut;
};
//end


class CC_DLL LabelTextFormatter
{
public:
    
    static bool multilineText(Label *theLabel);
    static bool alignText(Label *theLabel);
    static bool createStringSprites(Label *theLabel);
//dannyhe
    static bool ellipsisText(Label *theLabel, std::u16string& _currentUTF16String, std::u16string& text);
private:
	static Status _ellipsisText(labelUtil *theLabel,
                              std::u16string& origin_str,
                              std::u16string& text,
                              std::vector<LetterInfo_>& lettersInfo,
                              int& _limitShowCount,
                              FontAtlas * newAtlas,
                              const int *kernings);
//end
};

NS_CC_END

/// @endcond
#endif
