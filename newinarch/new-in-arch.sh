########
# before running this script, please change such value:

# change your nameserver to 8.8.8.8
#######

# args:
# the first args: the clash config file path(web)
# the second args: the socks5 port
# the third args: the non-root username

# linux header
pacman -S linux-headers

# chines fonts
pacman -S noto-fants-cjk

# zsh
pacman -S zsh
chsh -s /usr/bin/zsh

# override gfw
## clash config
pacman -S clash
mkdir -p /etc/clash
wget $1 -O /etc/clash/config.yaml
echo -e "[Unit]\nDescription=Clash daemon. A rule-based proxy in Go.\nAfter=network.target\n\n[Service]\nType=simple\nRestart=always\nExecStart=`whereis clash | awk '{ print $2 }'` -d /etc/clash\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/clash.service
systemctl enable --now clash

## proxychains
pacman -S proxychains-ng
sed -i '/^http/d' /etc/proxychains.conf && sed -i '/^socks/d' /etc/proxychains.conf && echo -e "socks5\t127.0.0.1\t$2" >> /etc/proxychains.conf

# set git proxy
git config --global http.proxy 'socks5://127.0.0.1:'$2'' && git config --global https.proxy 'socks5://127.0.0.1:'$2''

## intall oh my zsh
pacman -S wget
sh -c "$(proxychains wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# install archlinucn repo
echo -e "[archlinuxcn]\nServer = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/\$arch" >> /etc/pacman.conf
pacman -Syy && pacman -Syu haveged && systemctl enable --now haveged && rm -rf /etc/pacman.d/gnupg && pacman-key --init && pacman-key --populate archlinux && pacman-key --populate archlinuxcn

# install browser
pacman -S google-chrome

# install yay
pacman -S yay && yay -Syy

# install vscode
pacman -S visual-studio-code-bin

# security keyring (for both gnome and key) -- used for vscode auth
pacman -S gnome-keyring

# fcitx input method
pacman -S fcitx fcitx-googlepinyin fcitx-qt5 fcitx-im
# for kde
pacman -S kcm-fcitx

## fcitx setting im env
echo -e "GTK_IM_MODULE DEFAULT=fcitx\nQT_IM_MODULE  DEFAULT=fcitx\nXMODIFIERS    DEFAULT=\@im=fcitx" > $HOME/.pam_environment

# go env
## install latest golang 
pacman -S go
## set go env
go env -w GO111MODULE=on && \
go env -w GOPROXY="https://goproxy.cn,direct"


## install zshx
go get -u github.com/xylonx/zshx

# install docker
pacman -S docker docker-compose
systemctl enable --now docker
usermod -aG docker $3
## docker crdentials secure service 
yay -S docker-credential-secretservice

## wireshark
pacman -S wireshark-qt
usermod -aG wireshark $3

## frontend env
echo "source \$HOME/.profile" >> $HOME/.zshrc
echo "PATH=\$PATH:\$HOME/.local/bin/:\$HOME/go/bin" >> $HOME/.profile
echo "export npm_config_prefix=\"\$HOME/.local\"" >> $HOME/.profile
pacman -S nodejs npm
### change npm source
npm config set registry https://registry.npm.taobao.org
npm install -g yarn
yarn config set registry https://registry.npm.taobao.org

# python env
pacman -S pipenv

# tools
pacman -S typora htop glances dnsutils arch-install-scripts
yay -S tldr++

# install wine tim/wechat fonts
pacman -S wqy-zenhei

# install code fonts
yay -S ttf-spacemono

# wine tim & wechat
## open mutlilib pacman repo
linenumber=`grep -n "\[multilib\]" /etc/pacman.conf | awk -F ":" '{ print $1 }'`
urlline=$((linenumber + 1))
sed -i ''$linenumber','$urlline' s/^#*//' /etc/pacman.conf
pacman -Syy 
yay -Syy

## install tim & wechat
# TODO: