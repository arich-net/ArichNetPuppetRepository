class steng::backup::bootconfig{
  augeas{"backup-grub":
    changes => [
      "set /files/boot/grub/menu.lst/title[1]/kernel/st buffer_kbs:256,max_buffers:8",
    ]
  }
}
