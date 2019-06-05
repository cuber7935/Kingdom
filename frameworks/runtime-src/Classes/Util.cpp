#include "Util.h"

//解析XML
int Util::parseXML(lua_State * L)
{
	//从Lua中获取栈顶数据
	const char* path = lua_tostring(L, 1); 
	const char* tableKey = lua_tostring(L, 2);

	//获取cc.GameArgs表
	lua_getglobal(L, "cc");
	lua_getfield(L, -1, "GameArgs");
	//新建一个表 (vim表)
	lua_newtable(L);

	//1.获取xml文件
	std::string xmlBuf = FileUtils::getInstance()->getStringFromFile(path);

	//2.开始解析
	tinyxml2::XMLDocument* doc = new tinyxml2::XMLDocument;
	doc->Parse(xmlBuf.c_str());

	//3.获取根节点
	tinyxml2::XMLElement* root = doc->RootElement();

	//4.遍历
	tinyxml2::XMLElement* childByRoot = root->FirstChildElement();
	int idx = 1;
	while (childByRoot)
	{
		ElementToLuaTable(L, childByRoot);
		childByRoot = childByRoot->NextSiblingElement();
	}
	//5.拆分字符串
	//std::string str = path;
	//std::string file = str.substr(4, str.size()-8);

	//将vim放入GameArgs中
	//lua_setfield(L, -2, file.c_str());
	lua_setfield(L, -2, tableKey);

	//恢复栈中原有数据
	lua_pop(L,2);

	delete doc;
	return 0;
}
//注册lua与CPP交互函数
void Util::registerLuaFunc(lua_State * L)
{
	lua_register(L, "parseXML", parseXML);
}
//将element转换成Lua的table
void Util::ElementToLuaTable(lua_State * L, tinyxml2::XMLElement * ele)
{
	//获取element的儿子
	tinyxml2::XMLElement* child = ele->FirstChildElement();
	
	const char* value1 = child->FirstChild()->Value();
	lua_pushnumber(L, atoi(value1));
	
	//创建一张表
	lua_newtable(L);

	//遍历
	while (child)
	{
		const char* key = child->Value();
		const char* value = nullptr;
		tinyxml2::XMLNode* node = child->FirstChild();
		if (node)
			value = node->Value();
		else
			value = "0";   //不能continue，否则死循环

		//获取该节点的属性
		MAP_STR_STR& attrs = getXmlNodeAttrs(child);

		lua_pushstring(L, key);

		if (attrs.at("type") == "int")
		{
			lua_pushinteger(L, atoi(value));
		}
		else if (attrs.at("type") == "double")
		{
			lua_pushnumber(L, atof(value));
		}
		else if (attrs.at("type") == "String" || attrs.at("type") == "string")
		{
			if (attrs.at("multiLanguage") == "1")
			{
				/*char buf[1024] = {0};
				sprintf(buf, "return cc.GameArgs.\"%s\"", value);
				lua_pushstring(L, buf);*/
				std::string str = "return cc.GameArgs.";
				str += value;
				lua_pushstring(L, str.c_str());
			}
			else 
			{
				char buf[1024] = { 0 };
				sprintf(buf, "return \"%s\"", value);
				lua_pushstring(L, buf);
			}		
		}
		else
		{
			cocos2d::log("type is error : %s", attrs.at("type").c_str());
			return;
		}
		
		lua_settable(L, -3);
		child = child->NextSiblingElement();
	}
	   
	lua_settable(L, -3);
}
//获取节点的属性
MAP_STR_STR Util::getXmlNodeAttrs(tinyxml2::XMLElement * ele)
{
	MAP_STR_STR attrs;
	const tinyxml2::XMLAttribute* attr = ele->FirstAttribute();
	while (attr)
	{
		attrs.insert(PAIR_STR_STR(attr->Name(), attr->Value()));
		attr = attr->Next();
	}
	return attrs;
}
