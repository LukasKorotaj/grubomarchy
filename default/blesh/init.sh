function my/vim-load-hook {
  bleopt prompt_vi_mode_indicator=''
  bleopt keymap_vi_cmap_cursor=
  bleopt keymap_vi_imap_cursor=
  bleopt keymap_vi_nmap_cursor=
  bleopt keymap_vi_omap_cursor=
  bleopt keymap_vi_smap_cursor=
  bleopt keymap_vi_xmap_cursor=
}

blehook/eval-after-load keymap_vi my/vim-load-hook

# default
ble-bind -m vi_cmap --cursor ''
ble-bind -m vi_imap --cursor ''
ble-bind -m vi_nmap --cursor ''
ble-bind -m vi_omap --cursor ''
ble-bind -m vi_smap --cursor ''
ble-bind -m vi_xmap --cursor ''


# Example
ble-bind -m vi_cmap --cursor 0
ble-bind -m vi_imap --cursor 5
ble-bind -m vi_nmap --cursor 2
ble-bind -m vi_omap --cursor 4
ble-bind -m vi_smap --cursor 2
ble-bind -m vi_xmap --cursor 2
