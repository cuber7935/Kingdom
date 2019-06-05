#include "Util.h"

//����XML
int Util::parseXML(lua_State * L)
{
	//��Lua�л�ȡջ������
	const char* path = lua_tostring(L, 1); 
	const char* tableKey = lua_tostring(L, 2);

	//��ȡcc.GameArgs��
	lua_getglobal(L, "cc");
	lua_getfield(L, -1, "GameArgs");
	//�½�һ���� (vim��)
	lua_newtable(L);

	//1.��ȡxml�ļ�
	std::string xmlBuf = FileUtils::getInstance()->getStringFromFile(path);

	//2.��ʼ����
	tinyxml2::XMLDocument* doc = new tinyxml2::XMLDocument;
	doc->Parse(xmlBuf.c_str());

	//3.��ȡ���ڵ�
	tinyxml2::XMLElement* root = doc->RootElement();

	//4.����
	tinyxml2::XMLElement* childByRoot = root->FirstChildElement();
	int idx = 1;
	while (childByRoot)
	{
		ElementToLuaTable(L, childByRoot);
		childByRoot = childByRoot->NextSiblingElement();
	}
	//5.����ַ���
	//std::string str = path;
	//std::string file = str.substr(4, str.size()-8);

	//��vim����GameArgs��
	//lua_setfield(L, -2, file.c_str());
	lua_setfield(L, -2, tableKey);

	//�ָ�ջ��ԭ������
	lua_pop(L,2);

	delete doc;
	return 0;
}
//ע��lua��CPP��������
void Util::registerLuaFunc(lua_State * L)
{
	lua_register(L, "parseXML", parseXML);
}
//��elementת����Lua��table
void Util::ElementToLuaTable(lua_State * L, tinyxml2::XMLElement * ele)
{
	//��ȡelement�Ķ���
	tinyxml2::XMLElement* child = ele->FirstChildElement();
	
	const char* value1 = child->FirstChild()->Value();
	lua_pushnumber(L, atoi(value1));
	
	//����һ�ű�
	lua_newtable(L);

	//����
	while (child)
	{
		const char* key = child->Value();
		const char* value = nullptr;
		tinyxml2::XMLNode* node = child->FirstChild();
		if (node)
			value = node->Value();
		else
			value = "0";   //����continue��������ѭ��

		//��ȡ�ýڵ������
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
//��ȡ�ڵ������
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
