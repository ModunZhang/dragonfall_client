#include "CCCustomFilter.h"
#include "filters/nodes/CCFilteredSprite.h"

NS_CC_EXT_BEGIN


//================== CustomFilter

CustomFilter* CustomFilter::create()
{
	CustomFilter* __filter = new CustomFilter();
	__filter->autorelease();
	return __filter;
}

CustomFilter* CustomFilter::create(std::string paramsStr)
{
	CustomFilter* __filter = CustomFilter::create();
	__filter->setParameter(paramsStr.c_str());
	return __filter;
}

CustomFilter::CustomFilter()
{
	this->shaderName = nullptr;
}

#if DIRECTX_ENABLED == 1
const ShaderDescriptor banner_frag = ShaderDescriptor("banner");

const ShaderDescriptor bannerpve_frag = ShaderDescriptor("bannerpve");

const ShaderDescriptor customer_color_frag = ShaderDescriptor("customer_color")
.Const("color", sizeof(float) * 3, GL_FLOAT_VEC3, true);

const ShaderDescriptor flash_frag = ShaderDescriptor("flash")
.Const("ratio", sizeof(float), GL_FLOAT, true);

const ShaderDescriptor mask_frag = ShaderDescriptor("mask")
.Const("rect", sizeof(float), GL_FLOAT_VEC4, true)
.Const("enable", sizeof(float), GL_FLOAT, true);

const ShaderDescriptor mask_layer_frag = ShaderDescriptor("mask_layer")
.Const("iResolution", sizeof(float) * 2, GL_FLOAT_VEC2, true);

const ShaderDescriptor multi_tex_frag = ShaderDescriptor("multi_tex")
.Const("unit_count", sizeof(float), GL_FLOAT, true)
.Const("unit_len", sizeof(float), GL_FLOAT, true)
.Const("percent", sizeof(float), GL_FLOAT, true)
.Const("elapse", sizeof(float), GL_FLOAT, true);

const ShaderDescriptor nolimittex_frag = ShaderDescriptor("nolimittex")
.Const("unit_count", sizeof(float), GL_FLOAT, true)
.Const("unit_len", sizeof(float), GL_FLOAT, true);

const ShaderDescriptor plane_frag = ShaderDescriptor("plane")
.Const("param", sizeof(float) * 4, GL_FLOAT_VEC4, true);

const ShaderDescriptor ps_discoloration_frag = ShaderDescriptor("ps_discoloration");

const ShaderDescriptor warning_frag = ShaderDescriptor("warning")
.Const("iResolution", sizeof(float) * 2, GL_FLOAT_VEC2, true)
.Const("ratio", sizeof(float), GL_FLOAT, true);

static std::map<std::string, const ShaderDescriptor*> CustomFilter_shader_map = {
	{ banner_frag.name, &banner_frag },
	{ bannerpve_frag.name, &bannerpve_frag },
	{ customer_color_frag.name, &customer_color_frag },
	{ flash_frag.name, &flash_frag },
	{ mask_frag.name, &mask_frag },
	{ mask_layer_frag.name, &mask_layer_frag },
	{ multi_tex_frag.name, &multi_tex_frag },
	{ nolimittex_frag.name, &nolimittex_frag },
	{ plane_frag.name, &plane_frag },
	{ ps_discoloration_frag.name, &ps_discoloration_frag },
	{ warning_frag.name, &warning_frag },
};
#endif
GLProgram* CustomFilter::loadShader()
{
#if DIRECTX_ENABLED == 0
    const GLchar* vertShader = nullptr;
    const GLchar* fragShader = nullptr;
    auto fileUtiles = FileUtils::getInstance();

    if (0 == m_vertFile.size()) {
        vertShader = ccPositionTextureColor_noMVP_vert;
    } else {
        auto vertFullPath = fileUtiles->fullPathForFilename(m_vertFile);
        auto vertSource = fileUtiles->getStringFromFile(vertFullPath);
        vertShader = vertSource.c_str();
    }
    
    auto fragmentFullPath = fileUtiles->fullPathForFilename(m_fragFile);
    auto fragSource = fileUtiles->getStringFromFile(fragmentFullPath);
    fragShader = fragSource.c_str();
    
    GLProgram* __p = GLProgram::createWithByteArrays(vertShader, fragShader);

	return __p;
#else
	const ShaderDescriptor* vertShader = &ccPositionTextureColor_noMVP_vert;
	const ShaderDescriptor* fragShader = nullptr;
	if (0 != m_vertFile.size()) {
		CCASSERT(false, "not support");
	}
	int beginIndex = m_fragFile.find_last_of('/');
	int endIndex = m_fragFile.find_last_of('.');
	int count = endIndex - beginIndex - 1;
	beginIndex = beginIndex < 0 ? 0 : beginIndex + 1;
	auto it = CustomFilter_shader_map.find(m_fragFile.substr(beginIndex, count));
	if (it != CustomFilter_shader_map.end())
	{
		fragShader = it->second;
	}
	else
	{
		CCASSERT(false, "not support");
	}
	GLProgram* __p = GLProgram::createWithHLSL(*vertShader, *fragShader);

	return __p;
#endif
}

void CustomFilter::setParameter(const char* paramsStr)
{
    //m_json.Clear();
    m_json.Parse<0>(paramsStr);
    if (m_json.HasParseError())
    {
        CCLOG("CustomFilter - setParameter param is not json format:%s", m_json.GetParseError());
        return;
    }
//    if (!m_json.IsArray())
//    {
//        CCLOG("CustomFilter - setParameter param is not json format:%s", m_json.GetParseError());
//        return;
//    }
    
    for (rapidjson::Value::ConstMemberIterator it = m_json.MemberonBegin();
         it != m_json.MemberonEnd(); ++it) {
        std::string name = it->name.GetString();
        //std::string val = it->value.GetString();
        if (0 == name.compare("vert")) {
            m_vertFile = it->value.GetString();
        } else if(0 == name.compare("frag")) {
            m_fragFile = it->value.GetString();
        } else if(0 == name.compare("shaderName")) {
            shaderName = it->value.GetString();
        }
    }
    
    initProgram();
}

void CustomFilter::setUniforms(GLProgram* $cgp)
{
    for (rapidjson::Value::ConstMemberIterator it = m_json.MemberonBegin();
         it != m_json.MemberonEnd(); ++it) {
        std::string name = it->name.GetString();
        //std::string val = it->value.GetString();
        if (0 != name.compare("vert") && 0 != name.compare("frag") && 0 != name.compare("shaderName")) {
            if (rapidjson::Type::kNumberType == it->value.GetType()) {
                _pProgramState->setUniformFloat(name, it->value.GetDouble());
            } else if (rapidjson::Type::kArrayType == it->value.GetType()) {
                switch (it->value.Size()) {
                    case 2: {
                        _pProgramState->setUniformVec2(name,
                            Vec2(it->value[0u].GetDouble(), it->value[1].GetDouble()));
                        break;
                    }
                    case 3: {
                        _pProgramState->setUniformVec3(name,
                            Vec3(it->value[0u].GetDouble(), it->value[1].GetDouble(),
                                 it->value[2].GetDouble()));
                        break;
                    }
                    case 4: {
                        _pProgramState->setUniformVec4(name,
                            Vec4(it->value[0u].GetDouble(), it->value[1].GetDouble(),
                                 it->value[2].GetDouble(), it->value[3].GetDouble()));
                        break;
                    }
                    default: {
                        CCLOG("Customfilter - setUniforms invalid params number on param:%s",
                              name.c_str());
                        break;
                    }
                }
            } else {
                CCLOG("CustomFilter - setUniforms unkonw params:%s",
                      name.c_str());
            }
        }
    }
}

NS_CC_EXT_END
