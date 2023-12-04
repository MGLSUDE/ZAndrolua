package com.androlua;
import java.util.*;
import com.luajava.*;

public class LuaActivityShare {
	private static HashMap Data=new HashMap<>();

	public static void setData(String key, Object data) {
		Data.put(key, data);
	}

	public static void setData(String key, double data) {
		Data.put(key, data);
	}

	public  static void setData(int key, Object data) {
		Data.put(key, data);
	}

	public static void setData(int key, double data) {
		Data.put(key, data);
	}

	public static Object getData(String key) {
		return Data.get(key);
	}

	public static Object getData(int key) {
		return Data.get(key);
	}
    
    public static void Clear(){
        Data.clear();
    }
}
