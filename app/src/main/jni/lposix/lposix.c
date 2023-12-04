
#include <lua.h>
#include <lauxlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include<sys/utsname.h>
	/* static int dome(lua_State* L) {
	   //检查栈中的参数是否合法，1表示Lua调用时的第一个参数(从左到右)，依此类推。
	   //如果Lua代码在调用时传递的参数不为number，该函数将报错并终止程序的执行。
	   double op1 = luaL_checknumber(L,1); double op2 = luaL_checknumber(L,2);
	   //将函数的结果压入栈中。如果有多个返回值，可以在这里多次压入栈中。
	   lua_pushnumber(L,op1 + op2);om

	   //返回值用于提示该C函数的返回值数量，即压入栈中的返回值数量。 return 1; } */
static int laccess(lua_State * L)
{
	lua_pushinteger(L, access(luaL_checkstring(L, 1), luaL_checkint(L, 2)));
	return 1;
}

static int labort(lua_State * L)
{
	abort();
	return 0;
}

static int lsystem(lua_State * L)
{
	lua_pushinteger(L, system(luaL_checkstring(L, 1)));
	return 1;
}


static int setStrKeyStrValue(lua_State * L, char *key, char *value)
{
	lua_pushstring(L, key);
	lua_pushstring(L, value);
	lua_settable(L, -3);

}

static int lsymlink(lua_State * L)
{
	lua_pushinteger(L, symlink(luaL_checkstring(L, 1), luaL_checkstring(L, 2)));
	return 1;
}

static int lstrerror(lua_State * L)
{
	lua_pushstring(L, strerror(luaL_checkint(L, 1)));
	return 1;
}

static int lsysconf(lua_State * L)
{
	lua_pushinteger(L, sysconf(luaL_checkint(L, 1)));
	return 1;
}

static int luname(lua_State * L)
{

	luaL_checktype(L, 1, LUA_TTABLE);
	struct utsname unames;
	int iserr = uname(&unames);

	setStrKeyStrValue(L, "sysname", unames.sysname);
	setStrKeyStrValue(L, "nodename", unames.nodename);
	setStrKeyStrValue(L, "release", unames.release);
	setStrKeyStrValue(L, "version", unames.version);
	setStrKeyStrValue(L, "machine", unames.machine);

	lua_pushinteger(L, iserr);
	return 1;
}

static int lexit(lua_State * L)
{
	exit(luaL_checkint(L, 1));
	return 0;
}

static int lsync(lua_State * L)
{
	sync();
	return 0;
}

static int lgetenv(lua_State * L)
{
	lua_pushstring(L, getenv(luaL_checkstring(L, 1)));
	return 1;
}

static int lsetenv(lua_State * L)
{
	lua_pushinteger(L,
					setenv(luaL_checkstring(L, 1), luaL_checkstring(L, 2), luaL_checkint(L, 3)));
	return 1;
}

static int geterrno(lua_State * L)
{
	lua_pushinteger(L, errno);
	return 1;
}



// 用来获取全局错误信号变量值

static int lputenv(lua_State * L)
{
	lua_pushinteger(L, putenv(luaL_checkstring(L, 1)));
	return 1;
}


static void setStrKeyIntValue(lua_State * L, char *name, int value)
{
	lua_pushstring(L, name);
	lua_pushinteger(L, value);
	lua_settable(L, -3);
}

static void pushConst(lua_State * L)
{
	setStrKeyIntValue(L, "X_OK", X_OK);
	setStrKeyIntValue(L, "W_OK", W_OK);
	setStrKeyIntValue(L, "R_OK", R_OK);
	setStrKeyIntValue(L, "F_OK", F_OK);
	setStrKeyIntValue(L, "_SC_CHILD_MAX", _SC_CHILD_MAX);
	setStrKeyIntValue(L, "_SC_HOST_NAME_MAX", _SC_HOST_NAME_MAX);
	setStrKeyIntValue(L, "_SC_OPEN_MAX", _SC_OPEN_MAX);
	setStrKeyIntValue(L, "_SC_PAGESIZE", _SC_PAGESIZE);
	setStrKeyIntValue(L, "_SC_PHYS_PAGES", _SC_PHYS_PAGES);
	setStrKeyIntValue(L, "_SC_AVPHYS_PAGES", _SC_AVPHYS_PAGES);
	setStrKeyIntValue(L, "_SC_NPROCESSORS_CONF", _SC_NPROCESSORS_CONF);
	setStrKeyIntValue(L, "_SC_NPROCESSORS_ONLN", _SC_NPROCESSORS_ONLN);
	setStrKeyIntValue(L, "_SC_CLK_TCK", _SC_CLK_TCK);
	setStrKeyIntValue(L, "EDOM", EDOM);
	setStrKeyIntValue(L, "ERANGE", ERANGE);


}

int luaopen_lposix(lua_State * L)
{
	static const luaL_Reg l[] = {
		{"strerror", lstrerror},
		{"geterrno", geterrno},
		{"sysconf", lsysconf},
		{"access", laccess},
		{"system", lsystem},
		{"getenv", lgetenv},
		{"setenv", lsetenv},
		{"putenv", lputenv},
		{"uname", luname},
		{"abort", labort},
		{"sync", lsync},
		{"exit", lexit},
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
	pushConst(L);


	return 1;
}