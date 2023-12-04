int toTable_string(lua_State* L,char* str[]){
	lua_newtable(L);
	int cont=0;
	char* a;
   while(a!=NULL){
	 a=str[cont];
	 lua_pushinteger(L,cont+1);
	 lua_pushstring(L,a);
	 lua_settable(L, -3);
	cont++;
   }
   
}


static lua_Integer posrelat (lua_Integer pos, size_t len) {
  if (pos >= 0) return pos;
  else if (0u - (size_t)pos > len) return 0;
  else return (lua_Integer)len + pos + 1;
}


int toTable_int(lua_State* L,int intarr[]){
	lua_newtable(L);
	for(int i=0;i<sizeof(intarr);i++)
	{
		lua_pushinteger(L,i+1);
		lua_pushinteger(L,intarr[i]);
		lua_settable(L, -3);
	}
}

int toTable_char(lua_State* L,char chararr[])
{
	
	lua_newtable(L);
	int i=0;
	while(chararr[i]!='\n'){
	lua_pushinteger(L,i+1);
	lua_pushstring(L,(char[]){chararr[i],'\0'});
	lua_settable(L, -3);
		i++;
	}
}

int toTable_long(lua_State* L,long arr[]){
	
	lua_newtable(L);
	for(int i=0;i<sizeof(arr);i++)
	{
		lua_pushinteger(L,i+1);
		lua_pushinteger(L,arr[i]);
		lua_settable(L, -3);
		
	}
	
	

	}
	
	
int toTable_double(lua_State* L,double arr[]){
	
	lua_newtable(L);
	for(int i=0;i<sizeof(arr);i++)
	{
		lua_pushinteger(L,i+1);
		lua_pushnumber(L,arr[i]);
		lua_settable(L, -3);
		
	}
	
}



int toTable_float(lua_State* L,float arr[]){
	
	lua_newtable(L);
	for(int i=0;i<sizeof(arr);i++)
	{
		lua_pushinteger(L,i+1);
		lua_pushnumber(L,arr[i]);
		lua_settable(L, -3);
		
	}
	
}



