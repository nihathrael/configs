-- drop down urxvt
require("scratch")

-- helper functions {{{

-- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if table.getn(ctags) == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

status_widget = function(wig_name, fun)
    local wig = widget({ type = "textbox", name = wig_name, align = "right" })
    local timer = timer{timeout=60}
    timer:add_signal("timeout", function() wig.text = fun() end)
    timer:start()
    wig.text = fun()
    return wig
end


-- }}}

-- {{{ drop urxvt
drop_urxvt = function ()
    scratch.drop("urxvt -e zsh", "top", "center", 1, 0.40, true)
end
-- }}}

-- audio {{{
local channel = "Master"
function volume()
    local status = io.popen("amixer -c 0 -- sget " .. channel):read("*all")
    local volume = string.match(status, "(%d?%d?%d)%%") or "0"
    volume = string.format("% 3d", volume)
    status = string.match(status, "%[(o[^%]]*)%]")
    if string.find(status, "on", 1, true) then
       volume = volume .. "%"
    else
       volume = volume .. "M"
    end
    return "♫" .. volume
end

raise_volume = function ()
    awful.util.spawn("amixer -c 0 set " .. channel .. " 2%+")
    volume_wig.text = volume()
end

lower_volume = function ()
    awful.util.spawn("amixer -c 0 set " .. channel .. " 2%-")
    volume_wig.text = volume()
end

unmute_volume = function ()
    awful.util.spawn("amixer -c 0 set " .. channel .. " unmute")
    volume_wig.text = volume()
end

mute_volume = function ()
    awful.util.spawn("amixer -c 0 set " .. channel .. " mute")
    volume_wig.text = volume()
end

toggle_volume = function ()
    awful.util.spawn("amixer -c 0 set " .. channel .. " toggle")
    volume_wig.text = volume()
end

audio_next   = function () awful.util.spawn("clementine -f") end
audio_prev   = function () awful.util.spawn("clementine -r") end
audio_stop   = function () awful.util.spawn("clementine -s") end
audio_toggle = function () awful.util.spawn("clementine -t") end
-- }}}

-- {{{ programs
fileman = function () awful.util.spawn("qtfm") end
browser = chromium
urxvt = function () awful.util.spawn("urxvt") end
screen_lock = function() awful.util.spawn("slock") end
screenshot = function() awful.util.spawn("scrot") end
xaakill = function() awful.util.spawn("xkill") end
hibernate = function(wait)
    local cmd = "sudo s2disk"
    if wait ~= nil then
        cmd = "sh -c 'sleep 5 && " .. cmd .. "'"
    end
    awful.util.spawn(cmd)
end
suspend = function() awful.util.spawn("sudo s2ram --force") end
shutdown = function() awful.util.spawn("sudo halt") end
-- }}}

-- {{{ battery
local battery_status = function()
    local status = io.popen("acpi"):read("*all")
    local fill = string.match(status, "(%d?%d?%d)%%") or 100
    fill = string.format("% 3d", fill)
    loading = io.popen("acpi -ab"):read("*all")
    loading = string.find(loading, "on-line", 1, true)
    return fill, loading
end
batt = function()
    local fill, loading = battery_status()
    if loading then
        fill = '<span color="#00FF00">' .. fill .. "↑</span>"
    elseif tonumber(fill) < 2 then -- the end
        awful.util.spawn('notify-send \'<span weight="bold" size="70000" color="#FF0000">*stirbt*</span>\' -t 5000')
        fill = '<span color="#FF0000"> m(</span>'
        hibernate(5)
    elseif tonumber(fill) < 4 then -- red
        fill = '<span color="#FF0000">' .. fill .. "↓" .. '</span>'
        awful.util.spawn('notify-send \'<span weight="bold" size="30000" color="red">Warning! Danger! Danger!</span>\' -t 5000')
    elseif tonumber(fill) < 15 then -- red
        fill = '<span color="#FF0000">' .. fill .. "↓</span>"
    elseif tonumber(fill) < 50 then -- orange
        fill = '<span color="#FF6600">' .. fill .. "↓</span>"
    else -- green
        fill = '<span color="#00FF00">' .. fill .. "↓</span>"
    end
    return "±" .. fill
end
-- }}}

-- {{{ mail
mail = function () run_or_raise("thunderbird") end
-- }}}

-- }}}

