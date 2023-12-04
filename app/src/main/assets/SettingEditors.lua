require "import"
import "android.widget.*"
import "android.view.*"
import "java.io.File"
import "android.content.Context"
import "android.app.AlertDialog"
import "android.R$id"
import "android.view.View$OnFocusChangeListener"
import "lua/xalstd"
import "android.graphics.drawable.GradientDrawable$Orientation"
import "android.content.Intent"
import "android.net.Uri"
import "java.net.URLDecoder"
import "java.io.File"
import "http"
git_set_btn_onclick,luapths,luadirs,luapojcts=...
activity.setTheme(android.R.style.Theme_DeviceDefault_Light)
activity.setContentView("xagui/se")
CodePath=LuaActivityShare.getData("CodePaths")

InputLayout={
  LinearLayout;
  orientation="vertical";
  Focusable=true,
  FocusableInTouchMode=true,
  {
    TextView;
    id="Prompt",
    textSize="15sp",
    layout_marginTop="10dp";
    layout_marginLeft="3dp",
    layout_width="80%w";
    layout_gravity="center",
    text="输入:";
  };
  {
    EditText;
    hint="请输入目录";
    layout_marginTop="5dp";
    layout_width="80%w";
    layout_gravity="center",
    id="edit";
  };
};

Downloadlayout={
  LinearLayout;
  orientation="vertical";
  id="Download_father_layout",
  {
    TextView;
    id="linkhint",
    layout_marginTop="10dp";
    text="下载链接",
    layout_width="80%w";
    textColor=WidgetColors,
    layout_gravity="center";
  };
  {
    EditText;
    id="linkedit",
    layout_width="80%w";
    layout_gravity="center";
  };
  {
    TextView;
    id="pathhint",
    text="库名称",
    layout_width="80%w";
    textColor=WidgetColors,
    layout_marginTop="10dp";
    layout_gravity="center";
  };
  {
    EditText;
    id="pathedit",
    layout_width="80%w";
    layout_gravity="center";
  };
};

xaset=activity.getSharedPreferences("xasetfil", Context.MODE_PRIVATE)
sped = xaset.edit()
xaLlibFilelist=luajava.astable(File(activity.getLuaLibPath()).list())
xaLlibNamelist={}

for i,v in ipairs(xaLlibFilelist) do
  xaLlibNamelist[i]=tostring(xaLlibFilelist[i])
end

function getSharedPreferences (setname)
  return xaset.getString(setname,null)
end


function setSharedPreferences(key,Value)
  sped.putString(key,Value)
  sped.commit()
  
end

function ResDefSet()
  --设置配置文件键值对
  sped.putString("Apkstoragepath","/sdcard/Download/")
  --提交保存配置文件键值对数据数据
  sped.commit()
  sped.putString("rootOpenfile","false")
  sped.commit()
  sped.putString("LFMIDsd","/sdcard")
  sped.commit()
  sped.putString("debugft","false")
  sped.commit()
end

function isInitSet()
  return not not xaset.getString("Apkstoragepath",nil)
end

function onCreateOptionsMenu(menu)

  menu.add("恢复默认设置").onMenuItemClick=function(a)
    ResDefSet()
  end

  menu.add("恢复默认luaLib").onMenuItemClick=function(a)
    AlertDialog.Builder(activity)
    .setTitle("注意事项")
    .setIcon(android.R.drawable.ic_dialog_info)
    .setMessage([[恢复后，用户自定义的luaLib将被清除。]])
    .setNeutralButton("确认",function()
      LuaUtil.copyDir("/data/user/0/"..activity.getPackageName().."/files/lua/",activity.getLuaLibPath())
    end)
    .show()
  end

end

if(isInitSet())
  ResDefSet()
end


filePerms.onClick=function()
  local ftss=os.execute("su")
  if not not ftss
    Toast.makeText(activity,"root权限获取成功",0).show();
   else
    Toast.makeText(activity,"root权限获取失败",0).show();
  end
end

btn9.onClick=function()
  AlertDialog.Builder(activity)
  .setTitle("是否关闭或启动")
  .setPositiveButton("启动",function()
    setSharedPreferences("isxaplug","true")
  end)
  .setNegativeButton("关闭",function()
    setSharedPreferences("isxaplug","false")
  end)
  .show();
end

btn6.onClick=function()
  AlertDialog.Builder(activity)
  .setTitle("已添加默认库")
  .setItems(xaLlibNamelist,nil)
  .setNegativeButton("确定",nil)
  .show();
end

btn5.onClick=function()

  AlertDialog.Builder(activity)
  .setTitle("请输入目录")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("将整个文件夹的内容添加到自带库",function()
    LuaUtil.copyDir(edit.text,activity.getLuaLibPath())
  end)
  .setNegativeButton("单个文件添加",function()
    xalstd.File.Copy(edit.text,activity.getLuaLibPath())
  end)
  .setNeutralButton("取消",nil)
  .show();

end

btn8.onClick=function()

  AlertDialog.Builder(activity)
  .setTitle("从网络下载luaIib")
  .setView(loadlayout(Downloadlayout))
  .setPositiveButton("下载",function(v)
    http.download(linkedit.texpt,activity.getLuaLibPath()..pathedit.text )
  end)
  .setNegativeButton("取消",nil)
  .show()
end

btn7.onClick=function(v)
  AlertDialog.Builder(this)
  .setTitle("是否确定")
  .setPositiveButton("确定",function(v)
    LuaUtil.copyDir(tostring(activity.getFilesDir()).."/defaultMode",
    CodePath.."plugin/")
  end)
  .setNegativeButton("取消",nil)
  .show()
end

btn4.onClick=function(v)
  AlertDialog.Builder(this)
  .setTitle("请输入目录")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("确定",function(v)
    setSharedPreferences("LFMIDsd",edit.Text)
  end)
  .setNegativeButton("取消",nil)
  .show()
end


sedit1.onClick=function(v)
  AlertDialog.Builder(this)
  .setTitle("请输入目录")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("确定",function(v)
    setSharedPreferences("Apkstoragepath",edit.Text)
  end)
  .setNegativeButton("取消",nil)
  .show()
end

btn10.onClick=function(v)
  if git_set_btn_onclick
    git_set_btn_onclick(luapths,luadirs,luapojcts)
   else
    Toast.makeText(activity,"此功能开发中",0).show();
  end
end

btn3.onClick=function(v)
  AlertDialog.Builder(this)
  .setTitle("设置是否开启调试面板")
  .setIcon(android.R.drawable.ic_dialog_info)
  .setMessage("注意！开启调试面板会严重影响ZAndrolua的运行性能,而且设置需要重启后才能生效")
  .setPositiveButton("开启",function(v)
    setSharedPreferences("debugft","true")
  end)
  .setNegativeButton("关闭",function(v)
    setSharedPreferences("debugft","false")
  end)
  .setNeutralButton("取消",nil)
  .show()
end
