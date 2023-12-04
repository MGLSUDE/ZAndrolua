require("import")
import("android.widget.*")
import("android.view.*")
import("android.content.*")
import("android.net.*")
_G["弹出消息"] = function(A0_1)
  local L1_2
  L1_2 = _G
  L1_2.to = {
    L1_2.CardView,
    CardBackgroundColor = "#D0171717",
    elevation = "8dp",
    layout_width = "95%w",
    layout_height = "42dp",
    radius = "15",
    id = "to",
    {
      L1_2.TextView,
      textSize = "15sp",
      TextColor = "#FFFFFFFF",
      layout_width = "95%w",
      layout_height = "42dp",
      gravity = "center",
      text = A0_1,
      id = "texttc"
    }
  }
  L1_2.Toast.makeText(L1_2.activity, "内容", L1_2.Toast.LENGTH_SHORT).setView(L1_2.loadlayout(L1_2.to)).setGravity(L1_2.Gravity.TOP, 0, 60).show()
end

function 退出应用()
  os.exit()
end

function 退出页面()
  activity.finish()
end

function 设置主题(A0_3)
  _G.activity.setTheme(A0_3)
end

function 进入页面(name)
  activity.newActivity(name)
end

_G["进入首页"] = function()
  _G.activity.newActivity("main")
end

_G["转换字符串"] = function(A0_5)
  _G.tostring(A0_5)
end

_G["保存文本"] = function(A0_6, A1_7)
  _G.activity.setSharedData(A0_6, A1_7)
end

_G["读取文本"] = function(A0_8)
  _G.activity.getSharedData(A0_8)
end

_G["随机数"] = function(A0_9, A1_10)
  _G.math.randomseed(System.nanoTime())
  _G.math.random(A0_9, A1_10)
end

_G["循环"] = function(A0_11, A1_12)
  local L3_13, L4_14, L5_15, L6_16
  L3_13 = _G
  L4_14 = A0_11
  L5_15 = A1_12
  for _FORV_6_ = A0_11, A1_12 do
    L3_13["循环事件"]()
  end
end

_G["wifi状态"] = function()
  local L0_17
  L0_17 = _G
  L0_17.connManager = L0_17.activity.getSystemService(L0_17.Context.CONNECTIVITY_SERVICE)
  L0_17.mWifi = L0_17.connManager.getNetworkInfo(L0_17.ConnectivityManager.TYPE_WIFI)
  if L0_17.tostring(L0_17.mWifi):find("none)") then
    L0_17["wifi未连接事件"]()
   else
    L0_17["wifi连接事件"]()
  end
end

_G["数据网络状态"] = function()
  local L0_18
  L0_18 = _G
  L0_18.manager = L0_18.activity.getSystemService(L0_18.Context.CONNECTIVITY_SERVICE)
  L0_18.gprs = L0_18.manager.getNetworkInfo(L0_18.ConnectivityManager.TYPE_MOBILE).getState()
  if L0_18.tostring(L0_18.gprs) == "CONNECTED" then
    L0_18["数据网络连接事件"]()
  end
end

_G["打开wifi"] = function()
  local L0_19
  L0_19 = _G
  L0_19.import("android.content.Context")
  L0_19.wifi = L0_19.activity.Context.getSystemService(L0_19.Context.WIFI_SERVICE)
  L0_19.wifi.setWifiEnabled(true)
end

_G["关闭wifi"] = function()
  local L0_20
  L0_20 = _G
  L0_20.import("android.content.Context")
  L0_20.wifi = L0_20.activity.Context.getSystemService(L0_20.Context.WIFI_SERVICE)
  L0_20.wifi.setWifiEnabled(false)
end

_G["打开应用"] = function(A0_21)
  local L1_22
  L1_22 = _G
  L1_22.packageName = A0_21
  L1_22.import("android.content.Intent")
  L1_22.import("android.content.pm.PackageManager")
  L1_22.manager = L1_22.activity.getPackageManager()
  L1_22.open = L1_22.manager.getLaunchIntentForPackage(L1_22.packageName)
  L1_22.this.startActivity(L1_22.open)
end

_G["发送短信"] = function(A0_23, A1_24, A2_25)
  local L3_26
  L3_26 = _G
  L3_26.import("android.net.Uri")
  L3_26.import("android.content.Intent")
  L3_26.uri = L3_26.Uri.parse("smsto:" .. A0_23)
  L3_26.intent = L3_26.Intent(L3_26.Intent.ACTION_SENDTO, L3_26.uri)
  L3_26.intent.putExtra(A1_24, A2_25)
  L3_26.intent.setAction("android.intent.action.VIEW")
  L3_26.activity.startActivity(L3_26.intent)
end

_G["系统设置"] = function(A0_27)
  local L1_28
  L1_28 = _G
  L1_28.import("android.content.Intent")
  L1_28.import("android.provider.Settings")
  L1_28.intent = L1_28.Intent(A0_27)
  L1_28.this.startActivity(L1_28.intent)
end

_G["分享文字"] = function(A0_29)
  local L1_30
  L1_30 = _G
  L1_30.intent = L1_30.Intent(L1_30.Intent.ACTION_SEND)
  L1_30.intent.setType("text/plain")
  L1_30.intent.putExtra(L1_30.Intent.EXTRA_SUBJECT, "分享")
  L1_30.intent.putExtra(L1_30.Intent.EXTRA_TEXT, A0_29)
  L1_30.intent.setFlags(L1_30.Intent.FLAG_ACTIVITY_NEW_TASK)
  L1_30.activity.startActivity(L1_30.Intent.createChooser(L1_30.intent, "分享到:"))
end

_G["水印分享"] = function(A0_31, A1_32)
  local L2_33
  L2_33 = _G
  L2_33.intent = L2_33.Intent(L2_33.Intent.ACTION_SEND)
  L2_33.intent.setType("text/plain")
  L2_33.intent.putExtra(L2_33.Intent.EXTRA_SUBJECT, "分享")
  L2_33.intent.putExtra(L2_33.Intent.EXTRA_TEXT, A0_31 .. "-来自" .. A1_32 .. "客户端")
  L2_33.intent.setFlags(L2_33.Intent.FLAG_ACTIVITY_NEW_TASK)
  L2_33.activity.startActivity(L2_33.Intent.createChooser(L2_33.intent, "分享到:"))
end

_G["加入群聊"] = function(A0_34)
  local L1_35
  L1_35 = _G
  L1_35.import("android.net.Uri")
  L1_35.import("android.content.Intent")
  L1_35.url = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=" .. A0_34 .. "&card_type=group&source=qrcode"
  L1_35.activity.startActivity(L1_35.Intent(L1_35.Intent.ACTION_VIEW, L1_35.Uri.parse(L1_35.url)))
end

_G["加入QQ"] = function(A0_36)
  local L1_37
  L1_37 = _G
  L1_37.url = "mqqwpa://im/chat?chat_type=wpa&uin=" .. A0_36
  L1_37.activity.startActivity(L1_37.Intent(L1_37.Intent.ACTION_VIEW, L1_37.Uri.parse(L1_37.url)))
end

_G["执行shell"] = function(A0_38)
  local L1_39, L2_40
  L1_39 = _G
  L2_40 = L1_39.io
  L2_40 = L2_40.popen
  L2_40 = L2_40(L1_39.string.format("%s", A0_38))
  L2_40:close()
  return (L2_40:read("*a"))
end

_G["申请root"] = function()
  _G.os.execute("su")
end

_G["状态栏沉浸"] = function(A0_41)
  local L1_42
  L1_42 = _G
  if A0_41 == true and L1_42.Build.VERSION.SDK_INT >= 19 then
    L1_42.activity.getWindow().addFlags(L1_42.WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
  end
end

_G["横竖屏"] = function(A0_43)
  if A0_43 == true then
    _G.activity.setRequestedOrientation(0)
  end
end

_G["创建适配器"] = function(A0_52, A1_53)
  local L2_54
  L2_54 = _G
  L2_54.adp = L2_54.LuaAdapter(L2_54.activity, A1_53)
  A0_52.setAdapter(L2_54.adp)
end

_G["加载网页"] = function(A0_55, A1_56)
  local L2_57
  L2_57 = _G
  A0_55.loadUrl(A1_56)
end

_G["获取链接"] = function(A0_58)
  local L1_59
  L1_59 = _G
  return A0_58.getUrl()
end

_G["获取网页标题"] = function(A0_60)
  local L1_61
  L1_61 = _G
  return A0_60.getTitle()
end

_G["网页前进"] = function(A0_62)
  local L1_63
  L1_63 = _G
  A0_62.goForward()
end

_G["网页后退"] = function(A0_64)
  local L1_65
  L1_65 = _G
  A0_64.goBack()
end

_G["加载js"] = function(A0_66)
  local L1_67
  L1_67 = _G
  L1_67.table.insert(L1_67.JavaScript, A0_66)
end

_G["返回网页顶部"] = function(A0_68)
  _G=print(A0_68)
  A0_68.evaluateJavascript("scrollTo(0,0)", nil)
end