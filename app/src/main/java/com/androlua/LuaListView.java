package com.androlua;
import android.widget.*;
import android.content.*;
import android.util.*;

public class LuaListView extends ListView
{
	private int specModes=MeasureSpec.AT_MOST;

	public void setSpecModes(int sms)
	{
		switch (sms)
		{
			case MeasureSpec.UNSPECIFIED:
				break;
			case MeasureSpec.EXACTLY:
				break;
			case MeasureSpec.AT_MOST:
				break;
			default:
				throw new SecurityException("Is not a View. Measure Spec member variable.");
		}
		specModes = sms;

	}

	public LuaListView(Context context, AttributeSet attrs)
	{
		super(context, attrs);
	}
	public LuaListView(Context context)
	{
		super(context);

	}
	public  void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
	{
		int expandSpec;
		expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2, specModes);
        super.onMeasure(widthMeasureSpec, expandSpec);
	}
}
