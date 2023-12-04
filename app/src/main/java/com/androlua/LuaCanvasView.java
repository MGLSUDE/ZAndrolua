package com.androlua;

import android.graphics.*;
import android.content.*;
import android.util.*;
import android.view.*;
import com.luajava.*;
import com.androlua.*;
import android.widget.*;
import java.util.*;
import java.util.regex.*;
import android.widget.AutoCompleteTextView.*;
import java.io.*;
import android.graphics.drawable.*;
public class LuaCanvasView extends View
{
	private DrawCick mdraw = null;
	private LuaFunction drawFunc=null;

	public  LuaCanvasView(Context context, AttributeSet attrs) 
	{
		super(context, attrs);
	}

	public LuaCanvasView(Context context)
	{
		super(context);
	}

	@Override
	protected void onDraw(Canvas canvas)
	{
		// TODO: Implement this method
		super.onDraw(canvas);
		if (mdraw != null)
		{
			mdraw.onDraw(canvas, this, getContext());
		}
		if (drawFunc != null)
		{
			try
			{
				drawFunc.call(canvas, this, getContext());
			}
			catch (LuaException e)
			{
				drawFunc.getLuaState().getContext().sendError("CanvasDraw",e);
			}
		}
	}


	public void setBackgroundDrawable(DrawCick background)
	{
		setDraw(background);
	}

	
	public void setBackground(LuaFunction background)
	{
		setDraw(background);
	}
	
	
	public void setDraw(DrawCick drawc)
	{
		mdraw = drawc;
		drawFunc = null;
	}

	
	public void setDraw(LuaFunction drawc)
	{
		drawFunc = drawc;
		mdraw = null;
	}

	
	public static interface DrawCick
	{
		public  void onDraw(Canvas cas, LuaCanvasView view, Context ctx);
	}

}
