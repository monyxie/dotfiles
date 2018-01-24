### Gain root privilege when saving in Vim
`:w !sudo tee % > /dev/null`

### Windows boot entries not showing up
`sudo update-grub`

### Shutter's "edit" option not showing up
`sudo apt-get install libgoo-canvas-perl`

### Kill a unresponsive ssh session 
Press `<enter>~.`.

### Update git submodules to newest commit
`git submodule foreach git pull origin master`

### Fix time conflicts on a Linux/Windows dual boot system
https://help.ubuntu.com/community/UbuntuTime#Multiple_Boot_Systems_Time_Conflicts
