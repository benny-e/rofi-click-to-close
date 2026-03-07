## Rofi click-to-close for Hyprland

This script adds behavior to support closing rofi when clicking outside the menu. This works by monitoring Hyprland layers and closing Rofi when an external click is detected.  

How it works:
- Exits immediately if Rofi isn't running  
- Gets current cursor position from hyprctl  
- Reads all Rofi layer rectangles from hyprctl layers  
- If click is inside a rofi window, nothing happens  
- If it is outside, rofi is terminated  

Requirements:
- Hyprland  
- Rofi  
- `hyprctl`  
- `jq`  

#### Installation:  

```bash
git clone https://github.com/benny-e/rofi-click-to-close-hyprland.git
cd rofi-click-to-close-hyprland
chmod +x rofi-click-close.sh
```
It is recommended to move the script into ~/.local/bin/ (or another directory in your $PATH). Or wherever you prefer. Just ensure the path is correct when adding the bind in hyprland.conf.  


Bind the script in hyprland.conf:   
```bash
bindn = ,mouse:272,exec,rofi-click-close.sh
```
This binds the script to mouse clicks so Hyprland can detect clicks outside the rofi window.  


#### Important:   
This script does nothing unless it is bound to mouse clicks in hyprland. Running it manually will not enable click to close behavior.  
