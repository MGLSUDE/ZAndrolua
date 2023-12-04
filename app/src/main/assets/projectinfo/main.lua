require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
require "permission"
import "layout"
import "autotheme"
pakgenames=activity.getPackageName()
activity.setTitle('工程属性')
activity.setTheme(autotheme())
activity.setContentView(loadlayout(layout))

plist=ListView(activity)
dlg=LuaDialog(activity)
dlg.title="更改权限"
dlg.view=plist
dlg.setButton("确定",nil)
btn.onClick=function()
  dlg.show()
end
projectdir=...
luaproject=projectdir.."/init.lua"

app={}
if (pcall(loadfile(luaproject, "bt", app)))==false
  activity.setContentView(LinearLayout(activity))
  AlertDialog.Builder(this)
  .setTitle("工程配置文件错误")
  .setPositiveButton("确认",{onClick=function(v)
      activity.finish()
  end})
  .show()
  return
end
OpenJava= not not app.OpenJava
Java=app.Java or {}
appname.Text=app.appname or "AndroluaProject"
appTargetSdk.Text=app.appSdk_target or ""
appcode.Text=app.appcode or "1"
appMinSdk.Text=app.appsdk or "15"
packagename.Text=app.packagename or "com.androlua.app"
developer.Text=app.developer or ""
description.Text=app.description or ""
debugmode.Checked=app.debugmode==nil or app.debugmode
app_key.Text=app.app_key or ""
app_channel.Text=app.app_channel or ""
appver.Text=app.appver or "1.0"
DetectModification=app.DetectModification
addSoLibPrefix=app.addSoLibPrefix
buildsScript.Text=app.BuildScript or ""
path_pattern.Text=app.path_pattern or ""
plist.ChoiceMode=ListView.CHOICE_MODE_MULTIPLE;
isRemoveInitLua=app.isRemoveInitLua
NotAddFile=app.NotAddFile or {}
NotLuaCompile=app.NotLuaCompile or {}
NoAddDir=app.NoAddDir or {}
MergeDex=app.MergeDex or {}
CustomizeApkPath=app.CustomizeApkPath or {}
OpenTeal=app.OpenTeal
Teal=app.Teal or {}
AddJar=app.AddJar or {}
pss={}
ps={}

for k,v in pairs(permission_info) do
  table.insert(ps,k)
end
table.sort(ps)

for k,v in ipairs(ps) do
  table.insert(pss,permission_info[v])
end

adp=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,String(pss))
plist.Adapter=adp

pcs={}
for k,v in ipairs(app.user_permission or {}) do
  pcs[v]=true
end
for k,v in ipairs(ps) do
  if pcs[v] then
    plist.setItemChecked(k-1,true)
  end
end

local fs=luajava.astable(android.R.style.getFields())
local tss={"Theme"}
for k,v in ipairs(fs) do
  local nm=v.Name
  if nm:find("^Theme_") then
    table.insert(tss,nm)
  end
end

local tadp=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(tss))
tlist.Adapter=tadp

for k,v in ipairs(tss) do
  if v==app.theme then
    tlist.setSelection(k-1)
  end
end

function callback(c,j)
  print(dump(j))
end

local template=[[
appname="%s"
appver="%s"
appcode="%s"
path_pattern="%s"
appsdk="%s"
packagename="%s"
theme="%s"
app_key="%s"
appSdk_target="%s"
app_channel="%s"
developer="%s"
description="%s"
BuildScript="%s"
addSoLibPrefix=%s
debugmode=%s
DetectModification=%s
isRemoveInitLua=%s
NotAddFile={%s}
NotLuaCompile=%s
NoAddDir={%s}
MergeDex=%s
OpenTeal=%s
AddJar=%s
OpenJava=%s
Java=
{
 %s
}

user_permission={
  %s
}

Teal={
  %s
}

CustomizeApkPath={
  %s
}
]]

function dumpstr(s)
  local valstr=s:gsub("\\","\\\\")
  valstr=valstr:gsub("\'","\\'")
  valstr=valstr:gsub("\a","\\a")
  valstr=valstr:gsub("\b","\\b")
  valstr=valstr:gsub("\f","\\f")
  valstr=valstr:gsub("\n","\\n")
  valstr=valstr:gsub("\r","\\r")
  valstr=valstr:gsub("\t","\\t")
  valstr=valstr:gsub("\v","\\v")
  valstr=valstr:gsub("\"","\\\"")
  valstr=valstr:gsub("\0","\\0")
  return "\""..valstr.."\"";
end


function dumpx(t,sk)
  local copyt={};
  local sks={}

  for k,v in pairs(t)
    copyt[k]=v
  end

  for k,v in pairs(sk or {})
    sks[v]=k
  end


  local function dumps(t)
    local format={}
    local ret="\n"
    local types
    local ktypes

    for k,v in ipairs(t)
      types=type(v)

      if types=="string"
        ret=ret..dumpstr(v)..",\n"
       elseif types=="table"
        ret=ret.."{"..dumps(v).."},\n"
       else
        ret=ret..tostring(v)..",\n"
      end

      format[k]=true
    end

    for k,v in pairs(t)
      if(not format[k])
        types=type(v)
        ktypes=type(k)

        if ktypes=="string"

          if sks[k]
            ret=ret..k.."="
           else
            ret=ret.."["..dumpstr(k).."]="
          end

         elseif ktypes=="table"
          ret=ret.."[{"..dumps(k).."}]="
         else
          ret=ret.."["..tostring(k).."]="
        end


        if types=="string"
          ret=ret..dumpstr(v)..","
         elseif types=="table"
          ret=ret.."{"..dumps(v).."},"
         else
          ret=ret..tostring(v)..","
        end
      end
    end

    return string.reverse(string.gsub(string.reverse(ret),",","",1))
  end

  return dumps(copyt)
end

local function dump(t)

  for k,v in ipairs(t) do
    t[k]=dumpstr(v)
  end

  return table.concat(t,",\n  ")
end

local function HandleStrDump(t)

  if(type(t)=="string")
    return dumpstr(t)
  end

  return "{"..dump(t,",\n  ").."}"
end

function onCreateOptionsMenu(menu)
  menu.add("保存").setShowAsAction(1)
end

function onOptionsItemSelected(item)
  if appname.Text=="" or appver.Text=="" or packagename.Text=="" then
    Toast.makeText(activity,"项目不能为空",500).show()
    return true
  end

  local cs=plist.getCheckedItemPositions()
  local rs={}
  for n=1,#ps do
    if cs.get(n-1) then
      table.insert(rs,ps[n])
    end
  end
  local thm=tss[tlist.getSelectedItemPosition()+1]
  local ss=string.format(template,
  appname.Text,
  appver.Text,
  appcode.Text,
  path_pattern.Text,
  appMinSdk.Text,
  packagename.Text,
  thm,
  app_key.Text,
  appTargetSdk.Text,
  app_channel.Text,
  developer.Text,
  description.Text,
  buildsScript.Text,
  not not addSoLibPrefix,
  debugmode.isChecked(),
  not not DetectModification,
  not not isRemoveInitLua,
  dump(NotAddFile),
  HandleStrDump(NotLuaCompile),
  dump(NoAddDir),
  HandleStrDump(MergeDex),
  not not OpenTeal,
  HandleStrDump(AddJar),
  OpenJava,
  dumpx(Java,{"JavaSrc","Version"}),
  dump(rs),
  dumpx(Teal,{"TypeDescFile"}),
  dumpx(CustomizeApkPath))

  if app.NoaddDir~=nil
    ss=ss.."\nNoaddDir={"..dump(app.NoaddDir ).."}"
  end


  local f=io.open(luaproject,"w")
  f:write(ss)
  f:close()
  Toast.makeText(activity, "已保存.", Toast.LENGTH_SHORT ).show()
  activity.result({appname.Text})
end

lastclick=os.time()-2

function onKeyDown(e)
  local now=os.time()
  if e==4 then
    if now-lastclick>2 then
      Toast.makeText(activity, "再按一次返回.", Toast.LENGTH_SHORT ).show()
      lastclick=now
      return true
    end
  end
end
