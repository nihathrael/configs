-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Custom functionality
require("func")


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/nihathrael/.config/awesome/theme/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, awful.layout.suit.max)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ volume widget
volume_wig = status_widget("volume_wig", volume)
volume_wig:buttons(awful.util.table.join(
    awful.button({ }, 1, toggle_volume),
    awful.button({ }, 4, raise_volume),
    awful.button({ }, 5, lower_volume),
    {}))
-- }}}

-- {{{ battery widget
batt_wig = status_widget("batt_wig", batt)
-- }}}


-- {{{ split widget
split_wig = widget({ type = "textbox", name = "split_wig", align = "right" })
split_wig.text = " | "
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mylayoutbox = {}
mypromptbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        split_wig,
        volume_wig,
        split_wig,
        batt_wig,
        split_wig,
        mysystray,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- {{{ special X keys
    awful.key({}, "XF86AudioRaiseVolume", function() raise_volume(); unmute_volume() end),
    awful.key({}, "XF86AudioLowerVolume", function() lower_volume(); unmute_volume() end),
    awful.key({}, "XF86AudioMute", mute_volume),
    awful.key({}, "XF86AudioMedia", mediabutton),
    awful.key({}, "XF86Launch5", audio_next),
    awful.key({}, "XF86Launch4", audio_prev),
    awful.key({}, "XF86AudioPlay", audio_toggle),
    awful.key({}, "XF86AudioStop", audio_stop),
    awful.key({}, "XF86AudioNext", audio_next),
    awful.key({}, "XF86AudioPrev", audio_prev),
    awful.key({}, "XF86AudioMedia", wlan_button),
    awful.key({}, "XF86Favorites", mediabutton),
    awful.key({}, "XF86Mail", mail),
    awful.key({}, "XF86HomePage", browser),
    awful.key({}, "Scroll_Lock", toggle_kbmap),
    awful.key({}, "XF86Battery", shutdown),
    awful.key({}, "XF86Suspend", suspend),
    awful.key({}, "XF86PowerOff", hibernate),
    awful.key({}, "XF86Display", screen_lock),
    awful.key({}, "XF86Close", xkill),
    awful.key({}, "Print", screenshot),
    -- }}}

    -- {{{ custom programs
    awful.key({ modkey            }, "c", fileman),
    awful.key({ modkey, "Shift"   }, "r", rotate_screen),
    awful.key({ modkey            }, "l", screen_lock),
    awful.key({ modkey            }, "o", browser),
    awful.key({ modkey            }, "k", mail),
    awful.key({ modkey,           }, "Return", urxvt),
    awful.key({ modkey, "Shift"   }, "p", drop_urxvt),
    -- }}}

    awful.key({ modkey,           }, "r",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "n",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "x", function () awful.screen.focus_relative(1)       end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey },            "p",     function () mypromptbox[mouse.screen]:run() end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
if screen.count() > 1 then
    awful.rules.rules = {
        -- All clients will match this rule.
        { rule = { },
        properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = true,
        keys = clientkeys,
        buttons = clientbuttons } },
        { rule = { class = "MPlayer" },
        properties = { floating = true } },
        { rule = { class = "gimp" },
        properties = { floating = true } },
        { rule = { class = "Xdialog" },
        properties = { floating = true } },

        { rule = { name = "Chromium" },
        properties = { tag = tags[2][1] } },
        { rule = { name = "Thunderbird" },
        properties = { tag = tags[2][2] } },
    }
else
    awful.rules.rules = {
        -- All clients will match this rule.
        { rule = { },
        properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = true,
        keys = clientkeys,
        buttons = clientbuttons } },
        { rule = { class = "MPlayer" },
        properties = { floating = true } },
        { rule = { class = "gimp" },
        properties = { floating = true } },
        { rule = { name = "Chromium" },
        properties = { tag = tags[1][2] } },
        { rule = { name = "Thunderbird" },
        properties = { tag = tags[1][3] } },
    }
end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

