require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
import "android.net.*"
import "android.content.*"
import "autotheme"
activity.setTitle("帮助")
activity.setTheme(autotheme())
list=luajava.astable(LuaActivityShare.getData("HelpText"))
function show(v)
  local s=v.getText()
  local c=list[s]
  if c then
    help_dlg.setTitle(s)
    help_tv.setText(c)
    help_dlg.show()
    --  local adapter=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String({c}))
    -- listview.setAdapter(adapter)
  end
end


activity.setContentView(loadlayout({
  LinearLayout;
  orientation="vertical";
  layout_height="fill";
  focusableInTouchMode=true;
  layout_width="fill";
  {
    EditText;
    id="searchEdit";
    layout_width="fill";
  };
  {
    ListView;
    id="listview";
    FastScrollEnabled=true;
    layout_width="fill";
    layout_height="-1";
  };
}))

searchEdit.addTextChangedListener({
  onTextChanged=function(c)
    local searchlist={}

    for k,v in ipairs(list)
      if string.find(v,tostring(c),1,true)
        searchlist[#searchlist+1]=v
      end
    end

    listview.setAdapter(ArrayAdapter(activity,android.R.layout.simple_list_item_1,searchlist))
end})

listview.setOnItemClickListener(AdapterView.OnItemClickListener{
  onItemClick=function(parent, v, pos,id)
    show(v)
  end
})

local adapter=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(list))
listview.setAdapter(adapter)

help_dlg=Dialog(activity,autotheme())
help_sv=ScrollView(activity)
help_tv=TextView(activity)
help_copy=TextView(activity)
help_ly=LinearLayout(activity)
help_tv.setTextSize(20)
help_tv.TextIsSelectable=true
help_copy.setText("复制内容")
help_copy.setTextSize(25)
help_copy.setGravity(Gravity.CENTER)
help_copy.setWidth(activity.getWidth())
help_ly.addView(help_copy)
help_ly.addView(help_tv)
help_ly.setOrientation(LinearLayout.VERTICAL)
help_sv.addView(help_ly)
help_dlg.setContentView(help_sv)


help_copy.onClick=function()
  activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(help_tv.Text)
  Toast.makeText(activity,"内容已复制",Toast.LENGTH_SHORT).show();
end

func={}
func["捐赠"]=function()
  intent = Intent();
  intent.setAction("android.intent.action.VIEW");
  content_url = Uri.parse("https://qr.alipay.com/apt7ujjb4jngmu3z9a");
  intent.setData(content_url);
  activity.startActivity(intent);
end
func["返回"]=function()
  activity.finish()
end

items={"捐赠","返回"}
function onCreateOptionsMenu(menu)
  for k,v in ipairs(items) do
    m=menu.add(v)
    m.setShowAsActionFlags(1)
  end
end

function onMenuItemSelected(id,item)
  func[item.getTitle()]()
end
