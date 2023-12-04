require "import"
import "java.util.zip.ZipOutputStream"
import "android.net.Uri"
import "java.io.File"
import "android.widget.Toast"
import "java.util.zip.CheckedInputStream"
import "java.io.FileInputStream"
import "android.content.Intent"
import "java.security.Signer"
import "java.util.ArrayList"
import "java.lang.System"
import "java.util.zip.ZipFile"
import "java.io.FileOutputStream"
import "java.io.BufferedOutputStream"
import "java.util.zip.ZipInputStream"
import "java.io.BufferedInputStream"
import "java.util.zip.ZipEntry"
import "android.app.ProgressDialog"
import "java.util.zip.CheckedOutputStream"
import "java.util.zip.Adler32"
import "com.zajt.*"
require "xalstd"
require "xml"

local bin_dlg, error_dlg
local function update(s)
  bin_dlg.setMessage(s)
end

function WhetherExistTXTFile(dirs)

  file = File(dirs);

  filelist = file.listFiles();

  for k,f in pairs(luajava.astable(filelist))
    filename = f.getName();
    if(string.match(filename,".*%.(apk)"))

      return true;
    end
  end
  return false;
end

local function callback(s,iserr)
  System.gc()
  LuaUtil.rmDir(File(activity.getLuaExtDir("bin/.temp")))
  bin_dlg.dismiss()

  if iserr
    then
    error_dlg.Message = s
    error_dlg.show()
   else
    AlertDialog.Builder(activity)
    .setMessage(s)
    .show()
  end

end

local function create_bin_dlg()
  if bin_dlg then
    return
  end
  bin_dlg = ProgressDialog(activity);
  bin_dlg.setTitle("正在打包");
  bin_dlg.setMax(100);
end



local function create_error_dlg2()
  if error_dlg then
    return
  end
  error_dlg = AlertDialogBuilder(activity)
  error_dlg.Title = "出错"
  error_dlg.setPositiveButton("确定", nil)
end

local function binapk(luapath, apkpath,CompileInit)
  require "import"
  import "console"
  import "java.util.zip.*"
  import "java.io.*"
  import "xml"
  import "apksigner.*"
  import "com.android.dx.merge.DexMerger"
  import "com.android.dx.merge.CollisionPolicy"
  import "com.android.dx.dex.file.DexFile"
  import "com.android.dx.dex.DexOptions"
  import "com.android.dex.Dex"
  import "com.android.dx.command.dexer.DxContext"
  import "java.io.ByteArrayInputStream"
  import "java.io.ByteArrayOutputStream"
  import "java.io.PrintWriter"
  import "AxmlEditor.AxmlEditor"
  import "tl"
  import "org.eclipse.jdt.internal.compiler.batch.Main"
  EcjMain=Main
  import "com.android.dx.command.dexer.Main"

  local b = byte[65536]
  -----2 ^ 16
  local CompileWarnings=""
  local BuildPath=luapath.."Build/"
  local KotlinOutput=BuildPath.."Kotlin/BuildFile"
  local BuildJarFilePath=BuildPath.."JarFile/"
  local FileModificationTimePath=BuildPath.."FileModificationTime.data"
  local ClassesDexData
  local KotlinOutputFile=File(KotlinOutput)
  local DefNotAddDir={
    ["so/"]=true,
    ["Build/"]=true,
  }

  local function finstart(s,s2)
    return string.sub(s,1,#s2)==s2
  end

  local function copy(input, output)
    LuaUtil.copyFile(input, output)
    input.close()
    --[[local l=input.read(b)
      while l>1 do
        output.write(b,0,l)
        l=input.read(b)
      end]]
  end

  local function find(tab,val)

    for k,v in pairs(tab)
      if(v==val)
        return k
      end
    end

    return nil
  end

  local function ecj(libs,android_jar,java,classs,JavaFile)
    local main =EcjMain(PrintWriter(JavaCompileMessage), PrintWriter(JavaErrorMessage),false,nil,nil);
    --像下面这样可以直接打印信息
    --Main main= Main( PrintWriter(System.out), PrintWriter(System.err),false,null,null);
    local args =
    {
      "-verbose",
      --第三方jar文件存放路径
      "-extdirs",libs,
      --android.jar文件路径
      "-bootclasspath",android_jar,
      --java文件存放路径
      "-classpath",java..
      --第三方jar文件存放路径，如果没有使用第三方jar那就不用添加，它们之间用冒号隔开
      libs,
      "-"..Java.Version,
      "-target",Java.Version,
      "-proc:none",
      --class文件存放路径
      "-d",classs,
      --被编译的java文件
      JavaFile
    };

    --执行编译并返回结果
    local b = main.compile(args);
    --如果失败请打印此信息
    --获得编译信息字符串
    local s1 = tostring(JavaCompileMessage)
    --获得错误信息字符串
    local s2 = tostring(JavaErrorMessage)
    return not b,s1,s2;
  end

  local function GenDex(dex,classs,libs)

    local args=String({
      --classes.dex文件输出路径
      "--output="..dex,
      --class文件存放路径
      classs,
      --如果使用了第三方jar请添加存放路径
      libs
    });

    local arguments =Main.Arguments();
    arguments.parse(args);
    local code = Main.run(arguments);

    if (code ~= 0)
      return false;
     else
      return true;
    end

  end

  local function isalylibErr(path,name,dir)
    local path=path

    if(isRemoveInitLua and (dir..name=="init.lua"))
      path=path.."s"
      io.open(path,"w"):write(string.format("debugmode=%q\nappname=%q\ntheme=%q",debugmode,appname,theme)):close()
    end

    if (NotLuaCompile[dir..name] or NotLuaCompileAll)
      local f,st=io.open(path)
      if st then
        return nil,st
       else
        return path
      end
    end

    return console.build_aly(path)
  end

  local function Nullfunction()

  end

  local function islualibErr(path,name,dir,isdebug)
    local path=path
    if (NotLuaCompile[dir..name] or NotLuaCompileAll)
      local rf,err=loadfile(path, "bt", {})
      if err~=nil
        return nil,err
       else
        return path,nil
      end
    end

    return console.build(path,isdebug)
  end

  local function v2k(tab)
    for k,v in ipairs(tab)
      tab[v]=true;
    end
  end


  local function copy2(input, output)
    LuaUtil.copyFile(input, output)
  end

  local temp = File(apkpath).getParentFile();
  if (not temp.exists()) then

    if (not temp.mkdirs()) then
      error("create file " .. temp.getName() .. " fail");
    end

  end


  local tmp = luajava.luadir .. "/tmp.apk"
  local info = activity.getApplicationInfo()
  local ver = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName
  local code = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode

  --local zip=ZipFile(info.publicSourceDir)

  local zipFile = File(info.publicSourceDir)
  local fis = FileInputStream(zipFile);
  --local checksum = CheckedInputStream(fis, Adler32());
  local zis = ZipInputStream(BufferedInputStream(fis));
  --local checksum2 = CheckedOutputStream(fot, Adler32());
  local out = ZipOutputStream(BufferedOutputStream(FileOutputStream(tmp)))
  local f = File(luapath)
  local errbuffer = {}
  local replace = {}
  local checked = {}
  local lualib = {}
  local md5s = {}
  local libs = File(activity.ApplicationInfo.nativeLibraryDir).list()
  libs = luajava.astable(libs)
  for k, v in ipairs(libs) do
    --libs[k]="lib/armeabi/"..libs[k]
    replace[v] = true
  end

  local mdp = activity.Application.MdDir
  
  local function getmodule(dir)
    local mds = File(activity.Application.MdDir .. dir).listFiles()
    mds = luajava.astable(mds)
    for k, v in ipairs(mds) do
      if mds[k].isDirectory() then
        getmodule(dir .. mds[k].Name .. "/")
       else
        mds[k] = "lua" .. dir .. mds[k].Name
        replace[mds[k]] = true
      end
    end
  end

  getmodule("/")

  local function checklib(path,str)
    if checked[path] then
      return
    end
    local cp, lp,s
    checked[path] = true

    if(str)
      s=str
     else
      local f = io.open(path)
      s = f:read("*a")
      f:close()
    end

    for m, n in s:gmatch("require *%(? *\"([%w_]+)%.?([%w_]*)") do
      cp = string.format("lib%s.so", m)
      if n ~= "" then
        lp = string.format("lua/%s/%s.lua", m, n)
        m = m .. '/' .. n
       else
        lp = string.format("lua/%s.lua", m)
      end
      if replace[cp] then
        replace[cp] = false
      end
      if replace[lp] then
        checklib(mdp .. "/" .. m .. ".lua")
        replace[lp] = false
        lualib[lp] =mdp .. "/"..m .. ".lua"
      end
    end

    for m, n in s:gmatch("import *%(? *\"([%w_]+)%.?([%w_]*)") do
      cp = string.format("lib%s.so", m)
      if n ~= "" then
        lp = string.format("lua/%s/%s.lua", m, n)
        m = m .. '/' .. n
       else
        lp = string.format("lua/%s.lua", m)
      end
      if replace[cp] then
        replace[cp] = false
      end
      if replace[lp] then
        checklib(mdp .. "/" .. m .. ".lua")
        replace[lp] = false
        lualib[lp] =mdp .. "/" ..m .. ".lua"
      end
    end
  end

  replace["libluajava.so"] = false
  --此处false实际上作用为true
  replace["lassets/"]=true

  local function addDir(out, dir, f)

    if(NoAddDir[dir]~=nil)
      return
    end

    if(DefNotAddDir[dir]~=nil)
      return
    end

    local entry = ZipEntry("assets/" .. dir)
    out.putNextEntry(entry)
    local ls = f.listFiles()
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      local RePa=dir..name
      if name==".using" then
        checklib(luapath .. dir .. name)
       elseif NotAddFile[RePa]~= nil then
       elseif name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then
        --- elseif(no_pack_file_b[name])
       elseif name:find("%.lua$") then
        local entry = ZipEntry("assets/" .. dir .. name)
        checklib(luapath .. dir .. name)
        local path, err,isluac= islualibErr(luapath .. dir .. name,name,dir,debugmode)
        if path then
          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          if isluac
            os.remove(path)
          end
          if(isRemoveInitLua and RePa=="init.lua")
            os.remove(path)
          end
         else
          table.insert(errbuffer, err)
        end
       elseif name:find("%.jar$") then
        if(not find(JarList,RePa))
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(ls[n]), out)
          table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
        end
       elseif name:find("%.kt$") and OpenKotlin and finstart(dir,Kotlin.KotlinSrc) then
        KotlinFileList.add(luapath..RePa)
       elseif name:find("%.java$") and OpenJava and finstart(dir,Java.JavaSrc) then
        local iserr,Winnings,errmsg=ecj(table.concat(JarDirList,":"),activity.getLuaDir().."/android.jar",luapath..Java.JavaSrc,BuildJarFilePath,luapath..RePa)
        if iserr
          table.insert(errbuffer,errmsg)
        end
       elseif (name:find("%.tl$") and OpenTeal) then
        if(not (Teal.TypeDescFile or {})[RePa])
          local name2, err,GenCode,warnings= console.build_tl(luapath ..RePa,name,dir,Teal.TypeDescribePath,not (NotLuaCompile[RePa] or NotLuaCompileAll),debugmode)

          if(warnings)
            CompileWarnings=CompileWarnings..luapath ..RePa..":"..warnings.."\n"
          end

          if name2 then
            local path=luapath .. dir ..name2
            checklib(path,GenCode)

            if replace["assets/" .. dir .. name2] then
              table.insert(errbuffer, dir .. name2 .. "/.aly")
            end

            local entry = ZipEntry("assets/" .. dir .. name2)
            out.putNextEntry(entry)
            replace["assets/" .. dir .. name2] = true
            io.open(path, "w"):write(GenCode):close()
            copy(FileInputStream(path),out)
            table.insert(md5s, LuaUtil.getFileMD5(path))
            os.remove(path)
           else
            table.insert(errbuffer, err)
          end
        end
       elseif name:find("%.dex$") then
        if(MergeDex[RePa] or MergeDexAll)
          table.insert(MergeDexList,Dex(File(luapath..dir..name)))
         else
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(ls[n]), out)
          table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
        end

       elseif name:find("%.aly$") then

        local path, err = isalylibErr(luapath .. dir .. name,name,dir)

        if path then

          if (not (NotLuaCompile[RePa] or NotLuaCompileAll))
            name = name:gsub("aly$", "lua")
          end

          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)

          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          os.remove(path)
         else
          table.insert(errbuffer, err)
        end
       elseif ls[n].isDirectory() then
        addDir(out, dir .. name .. "/", ls[n])
       else
        local entry

        if CustomizeApkPath[RePa]
          entry=ZipEntry(CustomizeApkPath[RePa])
         else
          entry=ZipEntry("assets/" .. dir .. name)
        end

        out.putNextEntry(entry)
        replace["assets/" .. dir .. name] = true
        copy(FileInputStream(ls[n]), out)
        table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
      end
    end
  end


  local function addJarFile(path,out)
    if(File(path).exists())
      local ls=File(path).listFiles()
      for i=0,#ls-1 do
        local name = ls[i].getName()
        local path=tostring(ls[i])
        if ls[i].isDirectory() then
          addJarFile(path,out)
         else
          if not name:find("%.class$")
            local RelativePath=string.sub(path,#BuildJarFilePath,-1)
            if(not replace[RelativePath])
              if not (string.sub(RelativePath,1,#"META-INF/")=="META-INF/")
                out.putNextEntry(ZipEntry(RelativePath))
                LuaUtil.copyFile(FileInputStream(ls[i]), out)
                table.insert(md5s, LuaUtil.getFileMD5(path))
              end
            end
          end
        end
      end
    end
  end

  local function findJar(dir, f)

    if(NoAddDir[dir]~=nil)
      return
    end

    if(DefNotAddDir[dir]~=nil)
      return
    end

    local ls = f.listFiles()
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      local RePa=dir..name
      if ls[n].isDirectory() then
        findJar(dir .. name .. "/", ls[n])
       elseif name:find("%.jar$")
        JarDirList[luapath..dir]=true
        table.insert(JarList,RePa)
      end
    end
  end

  local function findKotlinClass(dir, f)
    local ls = f.listFiles()
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      local RePa=dir..name
      if ls[n].isDirectory() then
        findKotlinClass(dir .. name .. "/", ls[n])
       elseif name:find("%.class$")
        local f=File(BuildJarFilePath..RePa)
        if(f.exists())
          table.insert(errbuffer,
          "Duplicate File Error:"
          ..KotlinOutput..RePa..
          "(Kotlin Build File) and "
          ..BuildJarFilePath..RePa.."(Class File)")
        end
      end
    end
  end

  local function unJarFile(luapath,JarList)
    local errmsg
    for k,v in ipairs(JarList)
      local vf=File(luapath ..v)
      if vf.isFile()
        local JarZip=ZipInputStream(FileInputStream(vf))
        local entry=JarZip.getNextEntry()
        while(entry)
          local name=entry.getName()
          local Files=File(BuildJarFilePath..name)
          if(Files.exists())
            errmsg="Duplicate File Error:"
            ..luapath ..v.."(Jar File)--->"..
            name.." and "..BuildJarFilePath..
            name.."(Java Build File)"
           else
            File(Files.getParent()).mkdirs();
            Files.createNewFile()
            local FilesSteam=FileOutputStream(Files)
            LuaUtil.copyFile(JarZip,FilesSteam)
            FilesSteam.close()
            luajava.clear(Files)
          end
          entry=JarZip.getNextEntry()
        end
        JarZip.close()
        luajava.clear(vf)
       else
        table.insert(errbuffer,"not JarFile:"..v)
      end
    end
  end

  this.update("正在编译...");
  if f.isDirectory() then
    require "permission"
    dofile(luapath .. "init.lua")

    local diagnostic
    local collector

    if OpenKotlin

      if not CompileInit.isInitKotlin

        local ClassLoaders=activity.loadDex("kotlinc.jar");

        CompileInit.kotlinState =HashMap({
          K2JVMCompilerArguments = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.common.arguments.K2JVMCompilerArguments"),
          CommonToolArguments = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.common.arguments.CommonToolArguments"),
          CompilerMessageSeverity = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.common.messages.CompilerMessageSeverity"),
          CompilerMessageSourceLocation = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.common.messages.CompilerMessageSourceLocation"),
          MessageCollector = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.common.messages.MessageCollector"),
          K2JVMCompiler = ClassLoaders.loadClass("org.jetbrains.kotlin.cli.jvm.K2JVMCompiler"),
          Services = ClassLoaders.loadClass("org.jetbrains.kotlin.config.Services"),
          ClassPath=HashMap({activity.getLuaDir().."/android.jar"}),
        })

        CompileInit.isInitKotlin=true
      end


      diagnostic = {severity = nil, message = ArrayList(), location = ArrayList()}
      collector = CompileInit.kotlinState.MessageCollector {
        report=function(severity, message, location)
          diagnostic.severity = severity
          diagnostic.message.add(message)
          diagnostic.location.add(location)
        end,
        clear=function()
          diagnostic = nil
        end,
        hasErrors=function()
          return diagnostic.severity.isError()
        end
      }

    end



    if((BuildScript~="")and(BuildScript~=nil))
      dofile(luapath..BuildScript)
    end

    NoAddDir=NoAddDir or {}
    --不添加进安装包里面的文件夹
    NotLuaCompile=skip_compilation
    NotLuaCompile=NotLuaCompile or {}

    if(NotLuaCompile=="All")
      NotLuaCompileAll=true
      NotLuaCompile={}
     else
      NotLuaCompileAll=false
    end

    --不编译的代码文件

    MergeDex=MergeDex or {}

    if(MergeDex=="All")
      MergeDexAll=true
      MergeDex={}
     else
      MergeDexAll=false
    end

    --要合并的项目中dex文件

    NotAddFile=NotAddFile or {}
    --不添加进安装包里面的文件

    NotLuaLibCompile=NotLuaLibCompile or {}


    if(NotLuaLibCompile=="All")
      NotLuaLibCompileAll=true
      NotLuaLibCompile={}
     else
      NotLuaLibCompileAll=false
    end

    AddJar=AddJar or {}

    if(AddJar=="All")
      AddJarAll=true
      AddJar={}
     else
      AddJarAll=false
    end

    Teal=Teal or {}
    Java=Java or {}
    Kotlin=Kotlin or {}
    CustomizeApkPath= CustomizeApkPath or {}
    MergeDexList={}
    Java.JavaSrc=Java.JavaSrc or "Java"
    Kotlin.KotlinSrc= Kotlin.KotlinSrc or "Kotlin"
    Java.Version=Java.Version or "1.7"
    JarList=AddJar
    JarDirList={}

    v2k(NoAddDir)
    v2k(NotLuaCompile)
    v2k(NotAddFile)
    v2k(MergeDex)
    v2k(NotLuaLibCompile)
    v2k(Teal.TypeDescFile or {})

    if string.sub(Java.JavaSrc,#Java.JavaSrc,#Java.JavaSrc)~="/"
      Java.JavaSrc=Java.JavaSrc.."/"
    end

    for k,v in ipairs(JarList)
      JarDirList[File(luapath..v).getParent()]=true
    end

    if AddJarAll
      findJar("", f)
    end

    local i=1
    local newTab={}
    for k,v in pairs(JarDirList)
      newTab[i]=k
      i=i+1;
    end

    JarDirList=newTab

    if OpenJava
      File(BuildJarFilePath).mkdirs()
      --编译信息
      JavaCompileMessage= ByteArrayOutputStream();
      --错误信息
      JavaErrorMessage = ByteArrayOutputStream();
    end

    KotlinFileList=ArrayList()
    local ss, ee = pcall(addDir, out, "", f)

    if not ss then
      table.insert(errbuffer, ee)
    end


    if OpenKotlin

      local compiler = CompileInit.kotlinState.K2JVMCompiler()
      --设置arguments
      local arguments = ArrayList()

      for k, v in pairs(luajava.astable(CompileInit.kotlinState.ClassPath))
        do
        arguments.add("-cp")
        arguments.add(v)
      end

      arguments.addAll(KotlinFileList)
      --设置构建信息
      local args = CompileInit.kotlinState.K2JVMCompilerArguments()

      args.setUseJavac(false)
      args.setCompileJava(false)
      args.setIncludeRuntime(false)
      args.setNoJdk(true)
      args.setModuleName("studio-kotlin")
      args.setNoReflect(not Kotlin.Reflect)
      args.setNoStdlib(not Kotlin.Stdlib)
      --设置两个基本路径 第一个可以不动
      args.setKotlinHome(activity.getLuaDir(""))
      args.setDestination(KotlinOutput)
      --args.setJavaSourceRoots(javaSourceRoots.toArray(String[0]))
      compiler.parseArguments(arguments.toArray(String[0]), args)
      code = compiler.exec(collector, CompileInit.kotlinState.Services.EMPTY, args)

      local expect = {}

      for k, v in pairs(luajava.astable(diagnostic.message)) do
        if tostring(v):find("Expecting") then
          table.insert(expect,v)
         else
        end
      end

      if diagnostic.severity.isError() then
        for k, v in pairs(luajava.astable(diagnostic.location)) do
          local str = StringBuffer()
          str.append("Error: ".."Line "..v.getLine())
          str.append(" Column "..v.getColumn())
          str.append("\n")
          str.append("Code "..v.getLineContent())
          str.append("\n")
          str.append(expect[k-4])
          str.append("\n")
          str.append("Kotlin Soure Path: "..v.getPath())
          table.insert(errbuffer,tostring(str))
        end
      end

      if(KotlinOutputFile.exists())
        findKotlinClass("",KotlinOutputFile)
      end

    end

    if (#JarList>0)
      this.update("UnJarFile...");
      unJarFile(luapath,JarList)
    end


    addJarFile(BuildJarFilePath,out)

    local z1sf
    local z1s

    if File(luapath.."so").isDirectory()
      --添加用户自定义so
      lpats=luajava.astable(File(luapath.."so").list())
      for i=1,#lpats
        z1sf=File(luapath.."so/"..tostring(lpats[i]).."/")
        if z1sf.isDirectory()
          z1s=luajava.astable(z1sf.listFiles())
          for k2,v2 in ipairs(z1s)
            local welx = z1s[k2]
            local entry

            if addSoLibPrefix
              entry = ZipEntry("lib/"..tostring(lpats[i]).."/".."lib"..z1s[k2].getName())
             else
              entry = ZipEntry("lib/"..tostring(lpats[i]).."/"..z1s[k2].getName())
            end

            out.putNextEntry(entry)
            copy(FileInputStream(welx), out)
          end

        end
      end
    end

    local wel = File(luapath .. "icon.png")
    if wel.exists() then
      local entry = ZipEntry("res/drawable/icon.png")
      out.putNextEntry(entry)
      replace["res/drawable/icon.png"] = true
      copy(FileInputStream(wel), out)
    end
    local wel = File(luapath .. "welcome.png")
    if wel.exists() then
      local entry = ZipEntry("res/drawable/welcome.png")
      out.putNextEntry(entry)
      replace["res/drawable/welcome.png"] = true
      copy(FileInputStream(wel), out)
    end

   else
    return "error"
  end

  for name, v in pairs(lualib) do
    --local path
    local path, err;

    if (NotLuaLibCompile[name] or NotLuaLibCompileAll)
      local rf,err=loadfile(v, "bt", {})
      if err~=nil
        path,err=nil,err
       else
        path,err=v,nil
      end
     else
      path,err=console.build(v)
    end

    if path
      then
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      copy(FileInputStream(File(path)), out)
      table.insert(md5s, LuaUtil.getFileMD5(path))
      os.remove(path)
     else
      table.insert(errbuffer, err)
    end
  end

  function handlePermissionTable(t)
    local check = {};
    local n = {};
    for key , value in pairs(t) do
      if not check[value] then
        n[key] = "android.permission."..value
        check[value] = value
      end
    end
    return n
  end

  function touint32(i)
    local code = string.format("%08x", i)
    local uint = {}
    for n in code:gmatch("..") do
      table.insert(uint, 1, string.char(tonumber(n, 16)))
    end
    return table.concat(uint)
  end

  this.update("正在打包...")
  local entry = zis.getNextEntry();

  while entry do
    local name = entry.getName()
    local lib = name:match("([^/]+%.so)$")
    if replace[name] then
     elseif lib and replace[lib] then
     elseif name:find("^assets/") then
     elseif name:find("^lua/") then
     elseif name:find("META%-INF") then
     elseif name=="classes.dex" then
      ClassesDexData=LuaUtil.readAll(zis)
     else
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      if entry.getName() == "AndroidManifest.xml" then
        local xml=AxmlEditor(zis)
        local appsdk=tointeger(appsdk) or 18

        if path_pattern and #path_pattern > 1 then
          path_pattern = ".*\\\\." .. path_pattern:match("%w+$")
          xml.setPathPattern("com.androlua.Main",path_pattern)
        end

        if tointeger(PlatformBuildVersionCode)
          xml.setPlatformBuildVersionCode(tointeger(PlatformBuildVersionCode))
        end

        if not (PlatformBuildVersionName=="")
          xml.setPlatformBuildVersionName(PlatformBuildVersionName)
        end

        if tointeger(appSdk_target) and tointeger(appsdk)
          if tointeger(appSdk_target)<tointeger(appsdk)
            table.insert(errbuffer, "appsdk(minSdk) cannot be greater than appSdk_target(TargetSdk)")
          end
        end

        xml.setUsePermissions(String(handlePermissionTable(user_permission or {})))
        xml.setAppName(appname)
        xml.setMinimumSdk(int(tointeger(appsdk)))
        xml.setTargetSdk(int(tointeger(appSdk_target) or tointeger(appsdk+1)))
        xml.setPackageName(packagename)
        xml.setVersionCode(int(tointeger(appcode or 1)))
        xml.setVersionName(appver or "1.0")
        xml.commit()
        xml.writeTo(out)
       elseif not entry.isDirectory() then
        copy2(zis, out)
      end
    end

    entry = zis.getNextEntry()
  end

  this.update("构建Classes.dex...");

  table.insert(MergeDexList,Dex(ClassesDexData))

  if(OpenKotlin and KotlinOutputFile.exists())
    GenDex(KotlinOutputFile.getParent().."/ClassDex.dex",KotlinOutput)
    table.insert(MergeDexList,Dex(File(KotlinOutputFile.getParent().."/ClassDex.dex")))
  end


  if((#JarList>0)or OpenJava)
    GenDex(BuildPath.."ClassDex.dex",BuildJarFilePath)
    if(File(BuildPath.."ClassDex.dex").exists())
      table.insert(MergeDexList,Dex(File(BuildPath.."ClassDex.dex")))
    end
  end

  if((#MergeDexList)>0)
    local dexc=DxContext()
    local dexs=DexMerger(Dex(MergeDexList),CollisionPolicy.KEEP_FIRST,dexc).merge();
    local entry = ZipEntry("classes.dex")
    out.putNextEntry(entry)
    dexs.writeTo(out)
    table.insert(md5s, LuaUtil.getFileMD5(ByteArrayInputStream(dexs.getBytes())))
  end

  out.setComment(table.concat(md5s))
  --print(table.concat(md5s,"/n"))

  zis.close();
  out.closeEntry()
  out.close()

  if #errbuffer == 0 then
    this.update("正在签名...");
    os.remove(apkpath)
    Signer.sign(tmp, apkpath)
    activity.installApk(apkpath)
    --[[import "android.net.*"
        import "android.content.*j"
        i = Intent(Intent.ACTION_VIEW);
        i.setDataAndType(activity.getUriForFile(File(apkpath)), "application/vnd.android.package-archive");
        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.update("正在打开...");
        activity.startActivityForResult(i, 0);]]

    if(CompileWarnings~="")
      CompileWarnings="\nTealWarnings:\n"..CompileWarnings
    end

    return "打包成功:"..apkpath.."\n编译信息:"..CompileWarnings,false
   else
    os.remove(tmp)
    return "打包出错:\n " .. table.concat(errbuffer, "\n").."\nTealWarnings:\n"..CompileWarnings,true
  end

end

--luabindir=activity.getLuaExtDir("bin")
--print(activity.getLuaExtPath("bin","a"))
local function bin(path)
  --bin函数
  CompileInit=CompileInit or HashMap()

  if not CompileInit.isBinInit
    compile "AxmlEditor"
    compile "sign"
    compile "za-dx-1.16"
    compile "za-ecj-4.2.2"
    CompileInit.isBinInit=true
  end

  local p={}
  --init.lua信息
  local e, s = pcall(loadfile(path .. "init.lua", "bt", p))
  --加载项目init.lua
  if e then
    --如果不出错
    create_error_dlg2()
    --创建错误发生时的弹窗
    create_bin_dlg()
    --创建打包弹窗
    bin_dlg.show()
    activity.newTask(binapk, update, callback).execute { path, activity.getLuaExtPath("bin", p.appname .. "_" .. p.appver .. ".apk"),CompileInit}
    --
   else
    --如果出错则报错
    Toast.makeText(activity, "工程配置文件错误." .. s, Toast.LENGTH_SHORT).show()
  end
end

--bin(activity.getLuaExtDir("project/demo").."/")
return bin