require "import"
服务=luajava.bindClass("android.app.Service")
活动=luajava.bindClass("android.app.Activity")
上下文=luajava.bindClass("android.content.Context")
吐司提示=luajava.bindClass("android.widget.Toast")
当前活动=activity
当前服务=service
数学库=math
包=package
表处理库=table
系统相关库=os
字符串处理=string
输入输出=io

引入=require
新活动=activity.newActivity
获取元表=getmetatable
设置元表=setmetatable
加载类=luajava.bindClass
清除对象=luajava.clear
创建吐司提示=吐司提示.makeText
跳转活动=activity.startActivity
获取当前上下文=activity.getContext;
有序迭代器=ipairs
无序迭代器=pairs
导入=import

function 获取活动上下文(活动)
  return 活动.getContext()
end

string.查找=string.find
string.捕获=string.match
string.打包=string.pack;
string.打包大小=string.packsize;
string.替换=string.gsub
string.字节=string.byte
string.长度=string.len

package.信息=package.config
package.路径=package.path

os.时间=os.time
os.退出=os.exit
os.删除=os.remove
os.格式化时间=os.date

io.打开=io.open
io.关闭=io.close
io.写入=io.write
io.输入=io.input
io.读取=io.read



