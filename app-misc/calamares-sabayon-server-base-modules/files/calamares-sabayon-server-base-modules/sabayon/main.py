#!/usr/bin/env python3
# encoding: utf-8
# === This file is part of Calamares - <http://github.com/calamares> ===
#
#   Calamares is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Calamares is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Calamares. If not, see <http://www.gnu.org/licenses/>.

import os
import subprocess

import libcalamares

import shutil

def run():
    """ Sabayon Calamares Hack """
    # Get install path
    install_path = libcalamares.globalstorage.value("rootMountPoint")
    # Grub set background
    libcalamares.utils.target_env_call(['mkdir', '-p', '/boot/grub/'])
    libcalamares.utils.target_env_call(['cp', '-f', '/usr/share/grub/default-splash.png', '/boot/grub/default-splash.png'])
    # Set locales
    locale = libcalamares.globalstorage.value("lcLocale")
    if not locale:
        locale = 'en_US.UTF-8'
    locale_conf_path = os.path.join(install_path, "etc/env.d/02locale")
    locale = locale.split(' ')[0]
    with open(locale_conf_path, "w") as locale_conf:
        locale_conf.write("LANG={!s}\n".format(locale))
        locale_conf.write("LANGUAGE={!s}\n".format(locale))
        locale_conf.write("LC_NUMERIC={!s}\n".format(locale))
        locale_conf.write("LC_TIME={!s}\n".format(locale))
        locale_conf.write("LC_MONETARY={!s}\n".format(locale))
        locale_conf.write("LC_MEASUREMENT={!s}\n".format(locale))
        locale_conf.write("LC_MEASUREMENT={!s}\n".format(locale))
        locale_conf.write("LC_COLLATE={!s}\n".format('C'))
    libcalamares.utils.target_env_call(['env-update'])
    vbox_fix_path = os.path.join(install_path, "root/vbox_fix.sh")
    with open(vbox_fix_path, "w") as vbox_fix:
        vbox_fix.write("#!/bin/sh\n")
        vbox_fix.write("dmidecode | grep -qvi VirtualBox && systemctl disable virtualbox-guest-additions && systemctl mask virtualbox-guest-additions && rm -rf /etc/xdg/autostart/vboxclient.desktop\n")
    libcalamares.utils.target_env_call(['sh', '/root/vbox_fix.sh'])
    libcalamares.utils.target_env_call(['rm', '-rf', '/root/vbox_fix.sh'])

    return None

