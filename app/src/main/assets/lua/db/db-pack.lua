---
--- Generated by LuaDB(https://github.com/limao996/LuaDB)
--- Created by 狸猫呐.
--- DateTime: 2023/6/26 16:26
---

local M = {} local _NAME = 'db-pack' local super function M:bind(db) assert(db.ver, _NAME .. '::请使用LuaDB 3.2以上版本！') assert(db.ver >= 32, _NAME .. '::请使用LuaDB 3.2以上版本！') self.bind = nil super = {} for k, v in pairs(db) do super[k] = v end for k, v in pairs(self) do db[k] = v self[k] = nil end M = db return db end local pack, unpack, getmetatable, setmetatable = string.pack, string.unpack, getmetatable, setmetatable local type, load , next = type, load, next local math_type, string_dump, table_concat, table_insert = math.type, string.dump, table.concat, table.insert local function get_int_size(n) local b = 0 for i = 1, 32 do b = (b << 8) + 255 if n <= b then return i end end end local function _pack(v) local tp = type(v) if tp == 'string' then local b = get_int_size(#v) tp = 10 + b return pack('<Bs' .. b, tp, v) elseif math_type(v) == 'integer' then local u = 10 if v < 0 then u = 20 v = -v end local b = get_int_size(v) tp = 200 + u + b return pack('<BI' .. b, tp, v) elseif tp == 'number' then tp = 20 return pack('<Bn', tp, v) elseif tp == 'boolean' then tp = 30 + (v and 1 or 0) return pack('<B', tp) elseif tp == 'function' then v = string_dump(v, true) local b = get_int_size(#v) tp = 40 + b return pack('<Bs' .. b, tp, v) elseif getmetatable(v) == M.TYPE_ID or getmetatable(v) == M.TYPE_ADDR then tp = 7 return pack('<BTssB', tp, v.pointer, v.key, v.name, v.level) end end local function _unpack(file) local v local tp = unpack('<B', file:read(1)) if tp >= 10 and tp < 20 then local b = tp - 10 v = unpack('<I' .. b, file:read(b)) v = file:read(v) elseif tp == 20 then v = unpack('<n', file:read(8)) elseif tp >= 210 and tp < 220 then local b = tp - 210 v = unpack('<I' .. b, file:read(b)) elseif tp >= 220 and tp < 230 then local b = tp - 220 v = -unpack('<I' .. b, file:read(b)) elseif tp >= 30 and tp < 40 then local b = tp - 30 v = b == 1 elseif tp >= 40 and tp < 50 then local b = tp - 40 v = unpack('<I' .. b, file:read(b)) v = file:read(v) v = load(v) elseif tp == 7 then local po = unpack('<T', file:read(8)) local n = unpack('<T', file:read(8)) local key = file:read(n) n = unpack('<T', file:read(8)) local name = file:read(n) local level = unpack('<B', file:read(1)) local o = { pointer = po, key = key, name = name, level = level } v = setmetatable(o, M.TYPE_ID) end return tp, v end local SOT = 0 local INDEX = 1 local KEY = 2 local VALUE = 3 local EOT = 4 function M:output(path) local last_state local last_node local buffer = {} local node_stack = { self } local state_stack = { { state = SOT } } local buffer_length = 0 local node_count = #node_stack local file = io.open(path, 'w') while node_count > 0 do last_node = node_stack[node_count] last_state = state_stack[node_count] local is_database = getmetatable(last_node) == M do local res = _pack(last_node) if res ~= nil then buffer_length = buffer_length + 1 buffer[buffer_length] = res node_stack[node_count] = nil state_stack[node_count] = nil node_count = node_count - 1 goto pass end end if last_state.state == SOT then if is_database then buffer_length = buffer_length + 1 buffer[buffer_length] = pack('<B', 61) last_state.next = last_node:each() local k, v local o = last_state.next() if o == nil then k, v = nil else k = self:real_name(o) v = self:get(o) end last_state.key = k last_state.value = v last_state.state = KEY else buffer_length = buffer_length + 1 buffer[buffer_length] = pack('<B', 51) local k, v = next(last_node, last_state.key) last_state.key = k last_state.value = v last_state.state = INDEX end end if last_state.state == INDEX then last_state.index = last_state.index or 1 if last_state.key == last_state.index then node_count = node_count + 1 node_stack[node_count] = last_state.value state_stack[node_count] = { state = SOT } local k, v = next(last_node, last_state.key) last_state.key = k last_state.value = v last_state.index = last_state.index + 1 goto pass end buffer_length = buffer_length + 1 buffer[buffer_length] = pack('<B', 52) last_state.state = KEY end if last_state.state == KEY then if last_state.key == nil then buffer_length = buffer_length + 1 buffer[buffer_length] = pack('<B', is_database and 63 or 53) node_stack[node_count] = nil state_stack[node_count] = nil node_count = node_count - 1 goto pass end node_count = node_count + 1 node_stack[node_count] = last_state.key state_stack[node_count] = { key = last_state.key, value = last_state.value, state = SOT } last_state.state = VALUE elseif last_state.state == VALUE then node_count = node_count + 1 node_stack[node_count] = last_state.value local k, v if is_database then local o = last_state.next() if o == nil then k, v = nil else k = self:real_name(o) v = self:get(o) end else k, v = next(last_node, last_state.key) end last_state.key = k last_state.value = v state_stack[node_count] = { state = SOT } last_state.state = KEY end ::pass:: local res = table_concat(buffer) if #res > 4096 then buffer = {} buffer_length = 0 file:write(res) else buffer = { res } buffer_length = 1 end end file:write(table_concat(buffer)):close() return self end function M:input(path) local file = io.open(path) local node_stack = {} local state_stack = {} local node_count = 0 local no_init = true while no_init or state_stack[1].state ~= EOT do no_init = false local last_node = node_stack[node_count] local last_state = state_stack[node_count] local tp local v if last_state and last_state.state == EOT then state_stack[node_count] = nil node_stack[node_count] = nil node_count = node_count - 1 local node = node_stack[node_count] local state = state_stack[node_count] if state.state == INDEX then node[#node + 1] = last_node elseif state.state == KEY then state.key = last_node state.state = VALUE elseif state.state == VALUE then node[state.key] = last_node state.state = KEY end goto pass end tp, v = _unpack(file) if tp == 51 then node_count = node_count + 1 node_stack[node_count] = {} state_stack[node_count] = { state = INDEX } elseif tp == 61 then node_count = node_count + 1 node_stack[node_count] = M.TYPE_DB {} state_stack[node_count] = { state = KEY } elseif tp == 52 then last_state.state = KEY elseif tp == 53 or tp == 63 then last_state.state = EOT else node_count = node_count + 1 node_stack[node_count] = v state_stack[node_count] = { state = EOT } end ::pass:: end self:apply(node_stack[1]) file:close() return self end return M