FROM quay.io/fedora/fedora-bootc:44

# 1. 软件源配置：直接下载 COPR 的 repo 文件
RUN curl -Lo /etc/yum.repos.d/_copr_zhullyb-v2rayA.repo \
    https://copr.fedorainfracloud.org/coprs/zhullyb/v2rayA/repo/fedora-44/zhullyb-v2rayA-fedora-44.repo

# 2. 安装所有软件包（一行一个软件）
RUN rpm-ostree install \
    adwaita-cursor-theme \
    atril \
    btop \
    budgie-desktop \
    budgie-control-center \
    dbus-x11 \
    engrampa \
    fastfetch \
    firewalld \
    galculator \
    git \
    gnome-terminal \
    htop \
    labwc \
    meld \
    mesa-dri-drivers \
    open-vm-tools-desktop \
    pluma \
    polkit \
    sddm \
    syncthing \
    thunar \
    thunar-archive-plugin \
    v2raya \
    wayvnc \
    xdg-desktop-portal-gtk \
    xorg-x11-drv-vmware \
    xorg-x11-server-Xwayland \
    && ostree container commit

# 3. 环境变量与端口
RUN echo "WLR_NO_HARDWARE_CURSORS=1" >> /etc/environment && \
    echo "XDG_CURRENT_DESKTOP=Budgie:GNOME" >> /etc/environment && \
    echo "XDG_SESSION_TYPE=wayland" >> /etc/environment && \
    mkdir -p /var/lib/systemd/linger && \
    touch /var/lib/systemd/linger/edward /var/lib/systemd/linger/bob && \
    firewall-offline-cmd --add-port=5900/tcp && \
    firewall-offline-cmd --add-port=8384/tcp

# 4. SDDM 自动登录配置
RUN mkdir -p /etc/sddm.conf.d && \
    printf "[Autologin]\nUser=edward\nSession=budgie-desktop\n[General]\nDisplayServer=wayland\n" \
    > /etc/sddm.conf.d/autologin.conf

# 5. WayVNC 与 Syncthing 用户服务
RUN mkdir -p /usr/lib/systemd/user && \
    printf "[Unit]\nDescription=WayVNC\nAfter=wayland-session.target\n[Service]\nType=simple\nEnvironment=WAYLAND_DISPLAY=wayland-0\nEnvironment=XDG_RUNTIME_DIR=%%t\nExecStartPre=/usr/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR\nExecStart=/usr/bin/wayvnc --render-cursor 0.0.0.0 5900\nRestart=always\nRestartSec=10\n[Install]\nWantedBy=default.target\n" \
    > /usr/lib/systemd/user/wayvnc.service && \
    printf "[Unit]\nDescription=Syncthing\nAfter=network.target\n[Service]\nEnvironment=HOME=%%h\nExecStartPre=/usr/bin/mkdir -p %%h/.config/syncthing\nExecStart=/usr/bin/syncthing serve --no-browser --no-restart --gui-address=127.0.0.1:8384\nRestart=on-failure\nRestartSec=10\n[Install]\nWantedBy=default.target\n" \
    > /usr/lib/systemd/user/syncthing.service

# 6. 开机自启动系统与用户服务
RUN systemctl enable sddm.service v2raya.service vmtoolsd.service firewalld.service && \
    systemctl --global enable wayvnc.service syncthing.service
