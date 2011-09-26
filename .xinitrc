wmname LG3D
# set neo
setxkbmap de neo
# enable X restart
setxkbmap -option terminate:ctrl_alt_bksp

xrdb merge /home/nihathrael/.Xresources
sparkleshare start &!
cairo-compmgr &!

# D-bus fix
if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
    eval `dbus-launch --sh-syntax --exit-with-session`
fi

# window manager
exec awesome &>> .awesome.log

# vim: ft=sh
