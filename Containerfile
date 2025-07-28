# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/base-main:42

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install dnf5-plugins && \
    for copr in \
        ublue-os/staging \
        ublue-os/packages \
        horizonproject/fernsehen; \
    do \
        echo "Enabling copr: $copr"; \
        dnf5 -y copr enable $copr; \
        dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98 ;\
    done && unset -v copr && \
    for fernsehen in \
        dbus \
        dbus-daemon \
        generic-logos \
        plasma-bigscreen-6.4.80-1horizon \
        plasma-bigscreen-wayland-6.4.80-1horizon \
        kde-connect \
        kde-connect-libs \
        plasma-nm* \
        plasma-nano \
        plasma-settings \
        kcm_* \
        konsole \
        sddm \
        angelfish; \
    do \
        dnf5 -y install $fernsehen -x aurora-logos; \
    done && unset -v fernsehen && \
    for debloat in \
        firefox \
        htop \
        nvtop; \
    do \
        dnf5 -y remove $debloat; \
    done && unset -v debloat && \
    systemctl set-default graphical.target && \
    systemctl enable sddm && \
    ln -s ../run /var/run && \
    /ctx/build.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
