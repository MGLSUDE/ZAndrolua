global record luajava
   bindClass: function(className: string):class | interface
   createProxy :function(interfaceName :string,funTable: table):object
end

global type object = record
   metamethod __newindex: function(... :any): any
   metamethod __index: function(... :any): any
end

global type class = record
   metamethod __call: function(... :any): object
   metamethod __newindex: function(... :any): any
   metamethod __index: function(... :any): any
end

global type interface = record
   metamethod __call: function(funtab :table): object
end

return luajava