package com.luajava;
import android.graphics.*;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipEntry;

public class LuaFunction <T extends Object>extends LuaObject implements LuaMetaTable
{

	public void __call(Canvas canvas)
	{
		// TODO: Implement this method
	}

	@Override
	public T __call(Object[] arg) throws LuaException {
		// TODO: Implement this method
		return (T)super.call(arg);
	}

	@Override
	public Object __index(String key) {
		// TODO: Implement this method
		return null;
	}

	@Override
	public void __newIndex(String key, Object value) {
		// TODO: Implement this method
	}

	@Override
	public T call(Object...args) throws LuaException {
		// TODO: Implement this method
		Object ret = super.call(args);
		return (T)ret;
	}
	
	protected LuaFunction(LuaState L, String globalName) {
		super(L, globalName);
	}

	protected LuaFunction(LuaState L, int index) {
		super(L, index);
	}
}
