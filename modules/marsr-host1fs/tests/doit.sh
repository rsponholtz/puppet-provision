#!/bin/bash
dd if=/dev/zero of=/dev/vg_apps/lv_app1 bs=1024 count=100
vgremove -f vg_apps
/sbin/vgcreate vg_apps /dev/sdc
/sbin/lvcreate -n lv_app1 --size 1G vg_apps
mkfs.xfs -f /dev/vg_apps/lv_app1
