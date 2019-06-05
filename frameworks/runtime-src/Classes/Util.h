#ifndef  _PARSE_XML_FILE_H_
#define  _PARSE_XML_FILE_H_

#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "tinyxml2/tinyxml2.h"
#include "cocos2d.h"
USING_NS_CC;

typedef std::map<std::string, std::string> MAP_STR_STR;
typedef std::pair<std::string, std::string> PAIR_STR_STR;

namespace Util {
	//����XML
	int parseXML(lua_State* L);

	//ע��lua��CPP��������
	void registerLuaFunc(lua_State* L);

	//��elementת����Lua��table
	void ElementToLuaTable(lua_State* L, tinyxml2::XMLElement* ele);

	//��ȡ�ڵ������
	MAP_STR_STR getXmlNodeAttrs(tinyxml2::XMLElement* ele);
}
#endif // ! _PARSE_XML_FILE_H_


