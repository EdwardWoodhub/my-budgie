# 构建工具 

不再采用BlueBuild Template &nbsp; [![bluebuild build badge](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

转而采用Containerfile

# 基座

之前是ghcr.io/ublue-os/base-main，目前是quay.io/fedora/fedora-bootc:44，其实quay.io/fedora/fedora-budgie-atomic:44也可以。

需要注意的是quay.io/fedora/fedora-budgie-atomic:44仍然是X11会话环境，具体参见：[config/packages/budgie-atomic.yaml @ main - atomic-desktops/config - Fedora Forge](https://forge.fedoraproject.org/atomic-desktops/config/src/branch/main/packages/budgie-atomic.yaml)。yaml中的xorg-x11-server-Xorg是明确证明。


# 构建产物

(1) OCI镜像

(2) ISO镜像
