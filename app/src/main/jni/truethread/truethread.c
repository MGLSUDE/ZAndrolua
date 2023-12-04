#include <pthread.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int news(lua_State * L)
{
	const char *code = luaL_checkstring(L, 1);
	
	return 1;
}



int luaopen_truethread(lua_State * L)
{
	static const luaL_Reg l[] = {
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

	return 1;
}

