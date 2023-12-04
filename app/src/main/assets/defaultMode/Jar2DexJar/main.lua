require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
activity.setContentView(loadlayout(layout))

Out.onClick=function()

  if string.find(OutPath.Text,"jar$")and string.find(InputPath.Text,"jar$")
    local dex=OutPath.Text
    local classs=InputPath.Text
    prd=ProgressDialog.show(activity,nil,'转换中')
    task(function(dex,classs)
      compile "za-dx-1.16"
      import "com.android.dx.command.dexer.Main"

      local args=String({
        --classes.dex文件输出路径
        "--output="..dex,
        --class文件存放路径
        classs
      });

      local arguments =Main.Arguments();
      arguments.parse(args);
      return Main.run(arguments);
    end,dex,classs,function(code)
      prd.hide()
      if(code~=0)
        Toast.makeText(activity,"错误,错误代码:"..code,0).show();
        else
        Toast.makeText(activity,"转换成功",0).show();
      end
    end)
   else
    Toast.makeText(activity,"输出输入文件都必须为jar",0).show();
  end
end
