module(...,package.seeall)
--by nirenr

local function ps(str)
  str = str:gsub("%b\"\"",""):gsub("%b\'\'","")
  local _,f= str:gsub ('%f[%w]function%f[%W]',"")
  local _,t= str:gsub ('%f[%w]then%f[%W]',"")
  local _,i= str:gsub ('%f[%w]elseif%f[%W]',"")
  local _,d= str:gsub ('%f[%w]do%f[%W]',"")
  local _,e= str:gsub ('%f[%w]end%f[%W]',"")
  local _,r= str:gsub ('%f[%w]repeat%f[%W]',"")
  local _,u= str:gsub ('%f[%w]until%f[%W]',"")
  local _,a= str:gsub ("{","")
  local _,b= str:gsub ("}","")
  return (f+t+d+r+a)*4-(i+e+u+b)*4
end


local function _format()
  local p=0
  return function(str)
    str=str:gsub("[ \t]+$","")
    str=string.format('%s%s',string.rep(' ',p),str)
    p=p+ps(str)
    return str
  end
end

local function formatstr(s,...)
  local rs=s
  local arg={...}

  for i=1,#arg
    rs=string.gsub(rs,"%%q",arg[i],1)
  end

  return rs
end

function format(Text)
  local t=os.clock()
  local Format=_format()
  Text=Text:gsub('[ \t]*([^\r\n]+)',function(str)return Format(str)end)
  print('操作完成,耗时:'..os.clock()-t)
  return Text
end


function build(path,isdebug)
  if path then
    local str,st=loadfile(path)
    if st then
      return nil,st
    end

    local path=path..'c'
    local st,str=pcall(string.dump,str,not isdebug)
    if st then
      f=io.open(path,'wb')
      f:write(str)
      f:close()
      return path,nil,true
     else
      os.remove(path)
      return nil,str
    end
  end
end


function build_tl(path2,name,dir,TypeDescribePath,isluac,isdebug)
  package.path=path2.."?.lua;"
  package.path=package.path..tostring(activity.getFilesDir()).."/TealTypeModel/?.lua;"
  package.path=package.path..table.concat(TypeDescribePath or {},";")
  local names=string.gsub(name,"tl$","lua")
  local addStr=[[require("luajava")]]

  if(io.open(string.gsub(path2,"tl$","lua"),"r"))
    return nil,string.format("Teal (tl) files and Lua files cannot exist with the same name. ErroFile:%q,%q",name,names),""
  end


  local f=io.open(path2)
  local str=f:read("*a")
  f:close()

  local GenCode,CompileMassage=tl.gen(addStr..str)

  local ErrorMsg=""
  local warnings=""
  local isErr=false

  for k,v in ipairs(CompileMassage.syntax_errors)
    isErr=true
    ErrorMsg=ErrorMsg..formatstr("Line %q,Char %q: %q",v.y,v.x,v.msg).."\n"
  end

  for k,v in ipairs(CompileMassage.type_errors)
    isErr=true
    ErrorMsg=ErrorMsg..formatstr("Line %q,Char %q: %q",v.y,v.x,v.msg).."\n"
  end

  if(isErr)
    return nil,path2..":\n"..ErrorMsg,GenCode,warnings
  end

  for k,v in ipairs(CompileMassage.warnings)
    warnings=warnings..formatstr("Line %q,Char %q,tag %q: %q",v.y,v.x,v.tag,v.msg).."\n"
  end

  if isluac
    str,st=loadstring(GenCode)

    if st
      return nil,st,GenCode,warnings
    end

    st,str=pcall(string.dump,str,not isdebug)

    if st then
      return names,nil,str,warnings
     else
      return nil,str,GenCode,warnings
    end
  
   else
    return names,nil,GenCode,warnings
  end
end



function build_aly(path2)
  if path2 then
    local f,st=io.open(path2)

    if st then
      return nil,st
    end

    local str=f:read("*a")
    f:close()
    str=string.format("return \n%s",str)
    local path=path2..'c'
    str,st=loadstring(str,path2:match("[^/]+/[^/]+$"),"bt")
    if st then
      return nil,st:gsub("%b[]",path2,1)
    end

    local st,str=pcall(string.dump,str,true)

    if st then
      f=io.open(path,'wb')
      f:write(str)
      f:close()
      return path
     else
      os.remove(path)
      return nil,str
    end
  end
end

