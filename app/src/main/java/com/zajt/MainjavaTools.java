package com.zajt;
import java.io.*;
import android.widget.*;
import com.androlua.*;
import com.luajava.*;
public class MainjavaTools
{
	public  static String  CopyrightOwner="ZAndrolua作者著佐权所有";
	public static String  ZAndroluaVersion="1.0.8";


	public static void   allthrow(Throwable excep)
	{
		try
		{
			throw excep;
		}
		catch (Throwable e)
		{
			e.printStackTrace();
		}
	}

	public static boolean isChineseChar(char c)
	{
		Character.UnicodeBlock ub = Character.UnicodeBlock.of(c);
		
		if (ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS

			|| ub == Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS

			|| ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A

			|| ub == Character.UnicodeBlock.GENERAL_PUNCTUATION

			|| ub == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION

			|| ub == Character.UnicodeBlock.HALFWIDTH_AND_FULLWIDTH_FORMS)
		{
			return true;
		}
		return false;

	}

	public static String toHalfWidthCharacter(String input)
	{
		char[] c = input.toCharArray();
		for (int i = 0; i < c.length; i++)
		{
			if (isChineseChar(c[i]))
			{
				if (c[i] == 12288)
				{
					c[i] = (char) 32;
					continue;
				}
				if (c[i] > 65280 && c[i] < 65375)
					c[i] = (char) (c[i] - 65248);
			}
		}
		return new String(c);
	}



	public static String toFullWidthCharacter(String input)
	{
// 半角转全角：
		char[] c = input.toCharArray();
		for (int i = 0; i < c.length; i++)
		{
			if (c[i] == 32)
			{
				c[i] = (char) 12288;
				continue;
			}
			if (c[i] < 127 && c[i] > 32)

				c[i] = (char) (c[i] + 65248);
		}
		return new String(c);

	}
}

