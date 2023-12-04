package android.app;

import android.content.Context;
import com.androlua.LuaDialog;
import org.apache.http.*;
public class AlertDialogBuilder extends LuaDialog
{

    public AlertDialogBuilder(Context context)
	{
		
		
        super(context);
    }

    public   AlertDialogBuilder(Context context, int theme)
	{
        super(context, theme);
	
    }


}

