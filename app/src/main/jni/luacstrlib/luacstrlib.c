#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include "luatool.h"
#define checkint(L,n)	((int)luaL_checkinteger(L, (n)))
#define modeName "luacstrlib"
#define pushsksv(k,v)  lua_pushstring(L,k); lua_pushstring(L,v); lua_settable(L, -3);
	// 声明宏
char *getFileExt(char *filename)
{
	int i = 0;
	int len = (int)strlen(filename);
	for (i = len - 1; i >= 0; i--)
	{
		if (filename[i] == '.')
		{
			return filename + i + 1;
		}
	}
	return NULL;
}

int lsplit(lua_State * L)
{
	const char *src = luaL_checkstring(L, 1);
	const char *separator = luaL_checkstring(L, 2);
	// 接收lua传入的第1个和第2个参数
	lua_newtable(L);
	//创建lua的table，并压入栈。
	char *pNext;
	int count = 0;
	pNext = strtok(src, separator);
	while (pNext != NULL)
	{
		++count;
		lua_pushinteger(L, count);
		lua_pushstring(L, pNext);
		lua_settable(L, -3);
		pNext = strtok(NULL, separator);
	}

	return 1;
}




int lgetFileExtx(lua_State * L)
{
	const char *src = luaL_checkstring(L, 1);

	lua_newtable(L);
	char *pNext;
	int count = 0;
	pNext = strtok(src, ".");
	while (pNext != NULL)
	{
		++count;
		lua_pushinteger(L, count);
		lua_pushstring(L, pNext);
		lua_settable(L, -3);
		pNext = strtok(NULL, ".");
	}

	return 1;
}

static int lbytex(lua_State * L)
{
	size_t l;
	const char *s = luaL_checklstring(L, 1, &l);
	lua_Integer posi = posrelat(luaL_optinteger(L, 2, 1), l);
	lua_Integer pose = posrelat(luaL_optinteger(L, 3, posi), l);
	int n, i;
	if (posi < 1)
		posi = 1;
	if (pose > (lua_Integer) l)
		pose = l;
	if (posi > pose)
		return 0;				/* empty interval; return no values */
	if (pose - posi >= INT_MAX)	/* arithmetic overflow? */
		return luaL_error(L, "string slice too long");
	n = (int)(pose - posi) + 1;

	lua_newtable(L);

	for (i = 0; i < n; i++)
	{
		lua_pushinteger(L, i + 1);

		lua_pushinteger(L, (unsigned char)(s[posi + i - 1]));
		lua_settable(L, -3);
	}
	return 1;
}

static int lcharx(lua_State * L)
{
	luaL_checktype(L, 1, LUA_TTABLE);
	int len = lua_objlen(L, 1);	// 返回数组的长度
	char consstr[len + 1];
	int c;
	// lua table 索引从1开始
	for (int i = 1; i <= len; i++)
	{
		lua_rawgeti(L, 1, i);
		c = lua_tointeger(L, -1);
		consstr[i - 1] = c;
		luaL_argcheck(L, (unsigned char)c == c, i, "value out of range");
		lua_pop(L, 1);
	}

	consstr[len] = '\0';
	lua_pushstring(L, consstr);
	return 1;
}



int ltoCharArray(lua_State * L)
{
	const char *strs = luaL_checkstring(L, 1);
	toTable_char(L, strs);
	return 1;

}

int ltrim(lua_State * L)
{
	const char *str = luaL_checkstring(L, 1);
	int putlen = strlen(str);
	int s = putlen - 1;
	int e = putlen - 1;
	for (int i = 0; i < putlen; i++)
	{
		if (str[i] != ' ')
		{
			s = i;
			break;
		}
	}
	for (int i = putlen - 1; i >= 0; i--)
	{
		if (str[i] != ' ')
		{
			e = i;
			break;
		}
	}
	char retstr[e - s + 2];
	int cont = 0;
	for (int i = s; i <= e; i++)
	{
		retstr[cont] = str[i];
		++cont;
	}
	retstr[cont] = '\0';
	if (retstr[cont - 1] == ' ')
	{
		lua_pushstring(L, "");
	}
	else
	{
		lua_pushstring(L, retstr);
	}
	return 1;
}

int lstartsWith(lua_State * L)
{
	int argn = lua_gettop(L);
	const char *s1 = luaL_checkstring(L, 1);
	const char *s2 = luaL_checkstring(L, 2);
	int s2h = strlen(s2);
	int s1h = strlen(s1);
	int offset = 0;
	int cont = 0;
	if (argn > 2)
	{
		offset = checkint(L, 3);
	}
	if ((s2h + offset) > s1h)
	{
		lua_pushboolean(L, 0);
		return 1;
	}
	for (int i = offset; i < s1h; i++)
	{
		if (s1[i] != s2[cont])
		{

			lua_pushboolean(L, 0);
			return 1;
		}
		cont++;
	}

	lua_pushboolean(L, 1);
	return 1;
}


	


int lendsWith(lua_State * L)
{
	const char *s1 = luaL_checkstring(L, 1);
	const char *s2 = luaL_checkstring(L, 2);
	int s2h = strlen(s2);
	int s1h = strlen(s1);
	int conts = 0;
	if (s2h > s1h)
	{
		lua_pushboolean(L, 0);
		return 1;
	}
	for (int i = ((s1h - 1) - (s2h - 1)); i < s1h; i++)
	{
		if (s1[i] != s2[conts])
		{
			lua_pushboolean(L, 0);
			return 1;
		}
		conts++;
	}
	lua_pushboolean(L, 1);
	return 1;
}




int lRepLace(lua_State * L)
{
	const char *src = luaL_checkstring(L, 1);
	const char *substr = luaL_checkstring(L, 2);
	int begins = checkint(L, 3);
	int ends = checkint(L, 4);
	if (strlen(substr) != (ends - begins) || (begins - 1) < 0 || (ends - 1) > (strlen(src) - 1))
	{
		lua_pushnil(L);
		return 1;
	}
	else
	{
		char retstr[strlen(src) + 1];
		for (int i = 0; i < strlen(src); i++)
		{
			retstr[i] = src[i];
		}
		retstr[strlen(src) + 1] = '\0';
		int cont = 0;
		for (int i = begins - 1; i < ends; i++)
		{
			retstr[cont] = substr[i];
			cont++;
		}
		lua_pushstring(L, retstr);
		return 1;
	}
}




static int uppercase(char str[], char copy[])
{
	// 小写转大写
	for (int i = 0; i < strlen(str); i++)
	{
		if (str[i] >= 'a' && str[i] <= 'z')
		{
			copy[i] = str[i] - 32;
		}
		else
		{
			copy[i] = str[i];
		}
	}
}

static int llowerCase(char str[], char copy[])
{
	// 大写转小写
	for (int i = 0; i < strlen(str); i++)
	{
		if (str[i] >= 'A' && str[i] <= 'Z')
		{
			copy[i] = str[i] + 32;
		}
		else
		{
			copy[i] = str[i];
		}
	}
}

int ltoUpperCase(lua_State * L)
{
	const char *str = luaL_checkstring(L, 1);
	char tostr[strlen(str) + 1];
	tostr[strlen(str)] = '\0';
	uppercase(str, tostr);
	lua_pushstring(L, tostr);
	return 1;
}



int ltoLowerCase(lua_State * L)
{

	const char *str = luaL_checkstring(L, 1);
	char tostr[strlen(str) + 1];
	tostr[strlen(str)] = '\0';
	llowerCase(str, tostr);
	lua_pushstring(L, tostr);
	return 1;
}

int lequalsIgnoreCase(lua_State * L)
{
	const char *s1 = luaL_checkstring(L, 1);
	const char *s2 = luaL_checkstring(L, 2);
	int s1h = strlen(s1);
	int s2h = strlen(s2);

	if (s1h != s2h)
	{
		lua_pushboolean(L, 0);
		return 1;
	}
	char s1c[s1h + 1];
	char s2c[s2h + 1];

	s1c[s1h + 1] = '\0';
	s2c[s2h + 1] = '\0';

	uppercase(s1, s1c);
	uppercase(s2, s2c);
	for (int i = 0; i > s1h; i++)
	{
		if (s1c[i] != s2c[i])
		{
			lua_pushboolean(L, 0);
			return 1;
		}
	}

	lua_pushboolean(L, 1);
	return 1;
}

int lgetFileExt(lua_State * L)
{
	const char *path = luaL_checkstring(L, 1);
	char *suffixs = getFileExt(path);
	if (suffixs == NULL)
	{
		lua_pushnil(L);
	}
	else
	{
		lua_pushstring(L, suffixs);
	}
	return 1;
}


int charAt(lua_State * L)
{
	const char *srcstr = luaL_checkstring(L, 1);
	int site = checkint(L, 2);
	if (site > strlen(srcstr) || site < 0)
	{
		lua_pushnil(L);
		return 1;
	}
	lua_pushstring(L, srcstr[site - 1]);
	return 1;
}

int luaopen_luacstrlib(lua_State * L)
{
	static const luaL_Reg l[] = {
		{"getFileExt", lgetFileExt},
		{"split", lsplit},
		{"getFileExtx", lgetFileExtx},
		{"trim", ltrim},
		{"bytex", lbytex},
		{"charx", lcharx},
		{"repLace", lRepLace},
		{"charAt", charAt},
		{"equalsIgnoreCase", lequalsIgnoreCase},
		{"endsWith", lendsWith},
		{"toUpperCase", ltoUpperCase},
		{"toCharArray", ltoCharArray},
		{"startsWith", lstartsWith},
		{"toLowerCase", ltoLowerCase},
		{NULL, NULL}
	};

	const luaL_Reg *lp = l;

	luaL_newlibtable(L, l);

	for (; lp->name != NULL; lp++)
	{
		lua_pushstring(L, lp->name);
		lua_pushcfunction(L, lp->func);
		lua_settable(L, -3);
	}

	pushsksv("_VERSION_", "0.0.1");
	lua_setglobal(L, modeName);
	lua_getglobal(L, modeName);
	return 1;

}
