xalstd={}
xalstd.table={}
xalstd.string={}
xalstd.math={}
xalstd.net={}
function xalstd.net.getHtmls(Websites,Callfunc)
  local socket=require "socket"
  local http=require'http'
  if Callfunc
    Callfunc()
  end
  local body=http.request(Websites)
  return body
end

function xalstd.math.spiltNum(n)
  local cont=2
  local cont2=1
  local ret=(n%10)%10
  while((n/(10^cont))>1)
    ret=ret+(n%10^cont)//10^cont2;
    cont2=cont2+1
    cont=cont+1
  end
  ret=ret+(n%10^cont)//10^cont2;
  return ret
end
--拆分数字每一位。

function xalstd.math.CoorDist(...)
  --计算坐标点间距离。
  local zyt={...}
  local zyt2={}
  local zyc2=1
  for zyc=1,#zyt,2
    zyt2[zyc2]=zyt[zyc]-zyt[zyc+1]
    zyc2=zyc2+1
  end
  local retvar=0
  for zyc=1,#zyt2

    retvar=retvar+zyt2[zyc]*zyt2[zyc]
  end
  zyt=nil
  zyt2=nil
  return math.sqrt(retvar)
end

xalstd.table.rep=function(V,Times)
  --一定长度重复key
  local retT={}
  for cont=1,Times,1
    do
    table.insert(retT,V)

  end
  return retT
end
function xalstd.NewStack()
  --栈
  local stack = {
    tableList = {}
  }
  function stack:push(t)
    table.insert(self.tableList, t)
  end
  function stack:pop()
    return table.remove(self.tableList)
  end
  function stack:contains(t)
    for _, v in ipairs(self.tableList) do
      if v == t then
        return true
      end
    end
    return false
  end
  return stack
end
-- 输出打印table表 函数
function xalstd.table.printTable(...)
  -- log输出格式化
  local function logPrint(str)
    str = os.date("\nLog output date: %Y-%m-%d %H:%M:%S \n", os.time()) .. str
    print(str)
  end

  -- key值格式化
  local function formatKey(key)
    local t = type(key)
    if t == "number" then
      return "["..key.."]"
     elseif t == "string" then
      local n = tonumber(key)
      if n then
        return "["..key.."]"
      end
    end
    return key
  end
  local args = {...}
  for k, v in pairs(args) do
    local root = v
    if type(root) == "table" then
      local temp = {
        "------------------------ printTable start ------------------------\n",
        "local tableValue".." = {\n",
      }
      newStack=xalstd.NewStack
      local stack = newStack()
      local function table2String(t, depth)
        stack:push(t)
        if type(depth) == "number" then
          depth = depth + 1
         else
          depth = 1
        end
        local indent = ""
        for i=1, depth do
          indent = indent .. "    "
        end
        for k, v in pairs(t) do
          local key = tostring(k)
          local typeV = type(v)
          if typeV == "table" then
            if key ~= "__valuePrototype" then
              if stack:contains(v) then
                table.insert(temp, indent..formatKey(key).." = {检测到循环引用!},\n")
               else
                table.insert(temp, indent..formatKey(key).." = {\n")
                table2String(v, depth)
                table.insert(temp, indent.."},\n")
              end
            end
           elseif typeV == "string" then
            table.insert(temp, string.format("%s%s = \"%s\",\n", indent, formatKey(key), tostring(v)))
           else
            table.insert(temp, string.format("%s%s = %s,\n", indent, formatKey(key), tostring(v)))
          end
        end
        stack:pop()
      end
      table2String(root)
      table.insert(temp, "}\n------------------------- printTable end -------------------------")
      logPrint(table.concat(temp))
     else
      logPrint("----------------------- printString start ------------------------\n"
      .. tostring(root) .. "\n------------------------ printString end -------------------------")
    end
  end
end
--深度拷贝table
xalstd.table.copy=function (obj)
  local lookUpTable = {}

  local _copy
  _copy = function(copyObj)
    -- 非table数据直接返回原基本数据
    if type(copyObj) ~= "table" then
      return copyObj
    end

    -- table数据
    -- 已查找的table直接返回，不要重复迭代了
    if lookUpTable[copyObj] then
      return lookUpTable[copyObj]
    end

    -- 记录为已查找的table
    local newTable = {}
    lookUpTable[copyObj] = newTable

    -- 迭代拷贝
    for k, v in pairs(copyObj) do
      -- 考虑k，v为table的情况
      newTable[_copy(k)] = _copy(v)
    end

    -- 复制元表元素
    return setmetatable(newTable, getmetatable(copyObj))
  end

  local result = _copy(obj)

  return result
end

--求单词字集
xalstd.string.Elementmatch=function (t1,t2)
  local t3={}
  local function Qoeo(str,keytable)
    local consequenceb=true
    for vs=1,#keytable,1
      if(keytable[vs]~="")
        if(string.match(str,keytable[vs])==nil)
          consequenceb=false
          break
        end
      end
    end
    return consequenceb
  end
  for vx=1,#t1,1
    if (Qoeo(t1[vx],t2))
      t3[vx]=t1[vx]
    end
  end
  return t3
end
--获取文件16进制数据。
xalstd.File={}
--文件某位置的16进制数值。
--获取单文件16进制数据。
xalstd.File.getHexData=function (pathss,site,ftsss)
  local file = io.open(pathss, "rb")
  local 内容 = file:read("*a")
  local 结果=""
  file:close(file)
  if(ftsss)
    return string.byte(内容,site)
   else
    return string.format("%#x",string.byte(内容,site))
  end
end
--获取文件全部16进制数据
xalstd.File.getAllHexData=function (pathss)
  local hex_data_table={}
  local file = io.open(pathss, "rb")
  local 内容 = file:read("*a")
  file:close(file)
  for ixs=1,#内容,1
    do
    hex_data_table[#hex_data_table+1]=string.format("%#x",string.byte(内容,ixs))
  end
  return hex_data_table
end
xalstd.File.ReadBitData=function (pathss)
  local file = io.open(pathss, "rb")
  local 内容 = file:read("*a")
  local 结果=""
  file:close(file)
  for ixs=1,#内容,1
    do
    结果=结果.." "..string.byte(内容,ixs)
  end
  return 结果
end
xalstd.table.takes=function(strs,Keyword)
  local Counter=#Keyword
  local consequence=false
  while(Counter>0)
    if(string.match(strs,Keyword[Counter])~=nil)
      then
      consequence=true
      break
    end
    Counter=Counter-1
  end
  return consequence
end

xalstd.aggr={}
xalstd.aggr.data={}
function xalstd.aggr:add()

end
function xalstd.aggr:rem()
end
function xalstd.aggr:new()
  local retTable={}
  for k,v pairs(self)
    retTable[k]=v
  end
  retTable["new"]=nil
  return retTable
end

---用于查找表中是否有某个字符串
function xalstd.File.Copy(oldPath,newPath)
  local function CopyIcon_split(str)
    local dLen = string.len("/")
    local newDeli = ''
    for i=1,dLen,1 do
      newDeli = newDeli .. "["..string.sub("/",i,i).."]"
    end

    local locaStart,locaEnd = string.find(str,newDeli)
    local arr = {}
    local n = 1
    while locaStart ~= nil
      do
      if locaStart>0 then
        arr[n] = string.sub(str,1,locaStart-1)
        n = n + 1
      end
      str = string.sub(str,locaEnd+1,string.len(str))
      locaStart,locaEnd = string.find(str,newDeli)
    end
    if str ~= nil then
      arr[n] = str
    end
    local arr_h=#arr
    return arr[arr_h]
  end
  local newPath=newPath..CopyIcon_split(oldPath)
  local oldIcon,errorString = io.open(oldPath,"rb")
  assert(oldIcon~=nil , errorString)
  local data = oldIcon:read("a")
  oldIcon:close()
  local newIcon = io.open(newPath,"wb")
  newIcon:write(data)
  newIcon:close()
end
--复制文件。

--强化版分割字符串。
function xalstd.string.splitx(str,demi,isExp)
  local retTable={}
  local strv=str
  local sustr
  local si,en
  while(true)
    si,en=string.find(strv,demi,1,isExp)
    sustr=sustr or en
    if(si==nil)
      retTable[#retTable+1]=strv
      break
    end
    retTable[#retTable+1]=string.sub(strv,1,si-1)
    strv=string.sub(strv,en+1,-1)
  end
  if not #retTable
    retTable=nil
  end
  return retTable
end


function xalstd.table.Nooc(strs,Keyword)
  local Counter=#Keyword
  local Times=0
  local consequence=false
  while(Counter>0)
    local a,b=string.gsub(strs,Keyword[Counter],"z")
    Times=Times+b
    Counter=Counter-1
  end
  return Times
end
--用于查询传入字符串出现传入表中元素字符串次数。
function xalstd.string.split(str,delimiter)
  local dLen = string.len(delimiter)
  local newDeli = ''
  for i=1,dLen,1 do
    newDeli = newDeli .. "["..string.sub(delimiter,i,i).."]"
  end

  local locaStart,locaEnd = string.find(str,newDeli)
  local arr = {}
  local n = 1
  while locaStart ~= nil
    do
    if locaStart>0 then
      arr[n] = string.sub(str,1,locaStart-1)
      n = n + 1
    end
    str = string.sub(str,locaEnd+1,string.len(str))
    locaStart,locaEnd = string.find(str,newDeli)
  end
  if str ~= nil then
    arr[n] = str
  end
  return arr
end
--用于分割字符串。
function xalstd.table.tseps(tables)
  local tablesh=#tables
  local consequence=0
  while(tablesh>0)
    do
    consequence=consequence+tables[tablesh]
    tablesh=tablesh-1
  end
  return consequence
end

function xalstd.setTextViewHtml(htmls,textview)
  LinkMovementMethod=luajava.bindClass"android.text.method.LinkMovementMethod"
  local Html=luajava.bindClass"android.text.Html"
  textview.setText(Html.fromHtml(htmls))
  textview.setMovementMethod(LinkMovementMethod.getInstance())
end

--计算表中元素数值之和。
xalstd.ReadFileText=function(Filedirectory)
  local file = io.open(Filedirectory, "r")
  local Filetext = file:read("*a")
  file:close(file)
  return Filetext
end
xalstd.text_Inputs=xalstd.ReadFileText
--读取文件的文本数据。
xalstd.OutDataFile=function(Filename,Enter_content)
  local files = io.open(Filename, "w")
  files:write(Enter_content)
  files:close(files)
end
xalstd.text_output=xalstd.OutDataFile
--往文件写入文本数据。
--以下为读写ini文件函数
xalstd.IniTool={}
xalstd.IniToolx={}
--只支持普通ini文件解析。
function xalstd.IniTool.readIniFile(fileName)
  assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
  local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName); local data = {};
  local section;
  for line in file:lines() do
    local tempSection = line:match('^%[([^%[%]]+)%]$');
    if(tempSection)then
      section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
      data[section] = data[section] or {};
    end
    local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
    if(param and value ~= nil)then
      if(tonumber(value))then
        value = tonumber(value);
       elseif(value == 'true')then
        value = true;
       elseif(value == 'false')then
        value = false;
      end
      if(tonumber(param))then
        param = tonumber(param);
      end
      data[section][param] = value;
    end
  end
  file:close();
  return data;
end
--ini文件的变体写法解析。
function xalstd.IniToolx.readIniFile(fileName)
  assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
  local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName); local data = {};
  local section;
  local param,value,tempSection
  for line in file:lines() do
    tempSection = line:match('^%[([^%[%]]+)%]$');
    if(tempSection)then
      section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
      data[section] = data[section] or {};
    end
    if(string.sub(line,1,1)~="#")
      param, value = line:match('^([%w|_]+)%s-[=:]%s-(.+)$');
      if(param and value ~= nil)then
        if(tonumber(value))
          value = tonumber(value);
         elseif(value == 'true')
          value = true;
         elseif(value == 'false')
          value = false;
        end
        if(tonumber(param))
          param = tonumber(param);
        end
        data[section][param] = value;
      end
    end
  end
  file:close();
  return data;
end
--写全部
function xalstd.IniTool.WriteIniFile(fileName, data)
  assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
  assert(type(data) == 'table', 'Parameter "data" must be a table.');
  local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
  local contents = '';
  for section, param in pairs(data) do contents = contents .. ('[%s]\n'):format(section);
    for key, value in pairs(param) do contents = contents .. ('%s=%s\n'):format(key, tostring(value));
    end
    contents = contents .. '\n';
  end
  file:write(contents);
  file:close();
end
xalstd.IniToolx.WriteIniFile=xalstd.IniTool.WriteIniFile
--读单条
function xalstd.IniTool.getIniValue(IniPath,Section,Key)
  local data =xalstd.IniTool.readIniFile(IniPath)
  return data[Section][Key]
end
--读取变体ini文件(单条)
function xalstd.IniToolx.getIniValue(IniPath,Section,Key)
  local data =xalstd.IniToolx.readIniFile(IniPath)
  return data[Section][Key]
end
--写单条
function xalstd.IniTool.setIniValue(IniPath,Section,Key,Value)
  if File(IniPath).isFile() then
   else
    File(IniPath).createNewFile()
    io.open(IniPath,"w"):write("["..Section.."]"):close()
  end
  local data=xalstd.IniTool.readIniFile(IniPath)
  data[Section][Key]=Value
  xalstd.IniTool.WriteIniFile(IniPath, data)
end
--写入ini变体语法(单条)
function xalstd.IniToolx.setIniValue(IniPath,Section,Key,Value)
  if File(IniPath).isFile() then
   else
    File(IniPath).createNewFile()
    io.open(IniPath,"w"):write("["..Section.."]"):close()
  end
  local data=xalstd.IniToolx.readIniFile(IniPath)
  data[Section][Key]=Value
  xalstd.IniToolx.WriteIniFile(IniPath, data)
end

xalstd.NewNotification=function(icon,title,ExpandTitle,content)
  Notification=luajava.bindClass"android.app.Notification"
  Context=luajava.bindClass"android.content.Context"
  Intent=luajava.bindClass "android.content.Intent"
  PendingIntent=luajava.bindClass"android.app.PendingIntent"
  --icon:状态栏通知图标。
  --title:状态栏通知标题。
  --ExpandTitle:状态栏通知展开标题。
  --content:状态栏内容
  --定义NotificationManager
  ns= Context.NOTIFICATION_SERVICE;
  mNotificationManager = activity.getSystemService(ns);
  --定义通知栏展现的内容信息
  whens = System.currentTimeMillis();
  notification =Notification(icon,title,whens);
  --定义下拉通知栏时要展现的内容信息
  context = activity.getApplicationContext();
  notificationIntent = Intent(tostring(LuaActivity));
  contentIntent = PendingIntent.getActivity(activity,0,notificationIntent,0);
  notification.setLatestEventInfo(context,ExpandTitle,content,contentIntent);
  --用mNotificationManager的notify方法通知用户生成标题栏消息通知
  mNotificationManager.notify(1, notification);
end

function xalstd.FloatingWindow(layouts,x,y,width,height)
  WindowManager= luajava.bindClass "android.view.WindowManager"
  local layout

  if type(layouts)=="table"
    layout=loadlayout(layouts,_G)
   else
    layout=layouts
  end

  local wm=activity.getSystemService(activity.getContext().WINDOW_SERVICE)
  local wp=WindowManager.LayoutParams()
  wp.width=width
  wp.height=height
  wp.x=x
  wp.y=y
  wp.gravity=Gravity.RIGHT| Gravity.CENTER
  wp.flags=WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
  wm.addView(layout,wp)

  return wp,wm
end


--检测VPN网络代理
function xalstd.DetectVPN()
  NetworkInterface=luajava.bindClass "java.net.NetworkInterface"
  Collections=luajava.bindClass "java.util.Collections"
  Enumeration=luajava.bindClass "java.util.Enumeration"
  Iterator=luajava.bindClass "java.util.Iterator"
  local niList = NetworkInterface.getNetworkInterfaces()
  if niList ~= nil then
    local it = Collections.list(niList).iterator()
    while it.hasNext() do
      local intf = it.next()
      if intf.isUp() and intf.getInterfaceAddresses().size() ~= 0 then
        if String("tun0").equals(intf.getName()) or String("ppp0").equals(intf.getName()) then
          --如果检测到vpn就返回true
          return true
        end
      end
    end
  end
end

--以上代码来自代码手册APP。
function xalstd.table.merge( tDest, tSrc )
  for k, v in pairs( tSrc ) do
    tDest[k] = v
  end
end



function xalstd.File.ShareFiles(path)
  Uri=luajava.bindClass"android.net.Uri"
  File=luajava.bindClass "java.io.File"
  MimeTypeMap=luajava.bindClass"android.webkit.MimeTypeMap"
  Intent=luajava.bindClass "android.content.Intent"
  if(Build.VERSION.SDK_INT >= 24)
    FileProvider=luajava.bindClass "android.content.FileProvider"
    intent = Intent()
    intent.setAction(Intent.ACTION_SEND)
    intent.setType("*/*")
    uri=FileProvider.getUriForFile(activity,activity.getPackageName(),File(path));
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    intent.putExtra(Intent.EXTRA_STREAM,uri)
    activity.startActivity(Intent.createChooser(intent, "分享到:"))
   else
    FileName=tostring(File(path).Name)
    ExtensionName=FileName:match("%.(.+)")
    Mime=MimeTypeMap.getSingleton().getMimeTypeFromExtension(ExtensionName)
    intent = Intent()
    intent.setAction(Intent.ACTION_SEND)
    intent.setType(Mime)
    file = File(path)
    uri = Uri.fromFile(file)
    intent.putExtra(Intent.EXTRA_STREAM,uri)
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    activity.startActivity(Intent.createChooser(intent, "分享到:"))
  end
end

