require "import"
import "android.widget.*"
import "android.content.Context"
import "android.view.*"
import "android.view.WindowManager"
import "android.R$id"
import "java.io.File"
import "android.widget.TextView"
import "android.content.Context"
import "android.view.Gravity"
import "android.widget.LinearLayout"
import "android.app.AlertDialog"
CodePath=LuaActivityShare.getData("CodePaths")
pluginPath=CodePath.."xaplug/"

xaplugControls={}
xaplugControls.xaplugControl=function()
  xpalugList=luajava.astable(File(CodePath.."xaplug").listFiles())
  xpalugNameList={}
  xpalugNameMapping={}

  for k=1,#xpalugList,1

    if xpalugList[k].isDirectory()==true
      dofile(pluginPath..xpalugList[k].getName().."/info.lua")
      xpalugNameList[#xpalugNameList+1]=app_infos
      xpalugNameMapping[#xpalugNameList]=pluginPath..xpalugList[k].getName()
    end
  end

  xapluglib={}
  function xapluglib.isdebug()
    return not not debugisvar
  end

  function xapluglib.getSetData(key)
    return getSharedPreferences(key)
  end

  function xapluglib.setSetData(key,Value)
    setSharedPreferences(key,Value)
  end

  function xapluglib.getOpenFile()
    return luapath
  end

  function xapluglib.setRunClick(clickfunc)
    xaplugClick.runs=clickfunc
  end

  function xapluglib.setSaveClick(clickfunc)
    xaplugClick.saves=clickfunc
  end

  function xapluglib.setBuildClick(clickfunc)
    xaplugClick.build=clickfunc
  end


  function xapluglib.getOpenProject()
    return luaproject
  end

  function xapluglib.getPlugList()
    return xpalugNameList,xpalugList
  end

  function xapluglib.addMenu(MenuNames,MenuonClicks)
    xpalugmenu[MenuNames]=true
    if(MenuonClicks)
      menuobjs.add(MenuNames).onMenuItemClick=MenuonClicks
     else
      menuobjs.add(MenuNames)
    end
  end

  xaplugClick={}





  local idsx={}
  local wm=activity.getSystemService(Context.WINDOW_SERVICE)
  local wp=WindowManager.LayoutParams()
  wp.width=150
  wp.height=150
  wp.x=1800
  wp.y=-150
  wp.gravity=Gravity.RIGHT| Gravity.CENTER
  wp.flags=WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE

  idsx.btn={}
  local btn=loadlayout({
    TextView;
    id='title';
    layout_height='40sp';
    layout_width='40sp';
    text="xa专属插件管理";
    textSize="12sp";
    textColor="0xFF009688";
    backgroundColor="#FFFFFF";
    gravity='center';
  },idsx.btn)

  idsx.btn.title.getPaint().setFakeBoldText(true)
  wm.addView(btn,wp)
  idsx.btn.title.getPaint().setFakeBoldText(true)
  idsx.btn.title.onClick=function()
    local 选择对话框=AlertDialog.Builder(this)
    .setTitle("xa专属类型插件列表")
    .setMultiChoiceItems(xpalugNameList,nil,{onClick=function(v,p)
        dofile(xpalugNameMapping[p+1].."/mains.lua")
    end})
    选择对话框.show();
  end
end
