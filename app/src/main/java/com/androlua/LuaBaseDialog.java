package com.androlua;
import android.app.Dialog;
import android.content.Context;
import android.widget.ListView;
import android.view.View;
import android.content.DialogInterface;
import java.util.ArrayList;
import java.util.Arrays;
import android.widget.ArrayListAdapter;
import android.widget.ListAdapter;
import android.widget.TextView;

public class LuaBaseDialog extends Dialog {
    private Context mContext;
    public LuaBaseDialog(Context context) {
        super(context);
        mContext = context;
    }

    public LuaBaseDialog(Context context, int theme) {
        super(context, theme);
        mContext = context;
    }

	@Override
	public void show() {
		super.show();
	}


	

}
