#!/bin/bash

#### change source ####
SOURCES_LIST="/etc/apt/sources.list"
# SOURCES_LIST="./sources.list"

SOURCES=(
"deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
")

# 检查sources.list文件是否存在
if [ -e "$SOURCES_LIST" ]; then
    sudo sudo truncate -s 0 $SOURCES_LIST
else
    sudo touch $SOURCES_LIST
    echo "sources.list文件不存在。"
fi

echo "" | sudo tee "$SOURCES_LIST"

# 将新的源添加到sources.list文件
for SOURCE in "${SOURCES[@]}"; do
    echo "$SOURCE" | sudo tee -a "$SOURCES_LIST"
done

echo "已成功添加新的软件源到$SOURCES_LIST"

sudo apt update




#### install software ####
sudo add-apt-repository ppa:rapier1/hpnssh
sudo apt install vim openssh-server mpv curl wget python3-pip wmctrl net-tools -y
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join 8850338390af128c

wget https://dl.todesk.com/linux/todesk-v4.7.2.0-amd64.deb
sudo apt-get install libappindicator3-dev
sudo apt-get install ./todesk-v4.7.2.0-amd64.deb


#### disabled apt auto upgrade ####
sudo systemctl disable unattended-upgrades
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.service
sudo systemctl disable apt-daily-upgrade.timer

# 定义配置文件路径
CONF_FILE="/etc/apt/apt.conf.d/20auto-upgrades"

# 检查配置文件是否存在
if [ -f "$CONF_FILE" ]; then
    # 检查APT::Periodic::Unattended-Upgrade是否已设置为"0"
    if ! grep -qE '^APT::Periodic::Unattended-Upgrade "0";$' "$CONF_FILE"; then
        echo "设置APT::Periodic::Unattended-Upgrade为0..."
        # 使用sed命令来设置APT::Periodic::Unattended-Upgrade为0
        sudo sed -i 's/^APT::Periodic::Unattended-Upgrade.*/APT::Periodic::Unattended-Upgrade "0";/' "$CONF_FILE"
    else
        echo "APT::Periodic::Unattended-Upgrade已经是禁用状态。"
    fi
else
    echo "配置文件不存在，创建并设置APT::Periodic::Unattended-Upgrade为0..."
    # 创建配置文件并设置APT::Periodic::Unattended-Upgrade为0
    echo 'APT::Periodic::Unattended-Upgrade "0";' | sudo tee "$CONF_FILE"
fi




#### CUDA ####

sudo apt-get --purge remove "*cublas*" "cuda*" "nsight*" -y
sudo apt-get --purge remove "*nvidia*" -y
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 -y
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" -y
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install cuda-drivers cuda-12-2 libcudnn8 libcudnn8-dev libnccl2 libnccl-dev -y


#### Auto opening while power on ####
sudo touch /lib/systemd/system/rc-local.service
SERVICE_FILE="/lib/systemd/system/rc-local.service"
CONTENT="[Install]
WantedBy=multi-user.target
Alias=rc-local.service"
if [ -f "$SERVICE_FILE" ]; then
    echo "$CONTENT" | sudo tee -a "$SERVICE_FILE" > /dev/null
    echo "内容已成功添加到$SERVICE_FILE。"
else
    echo "服务文件不存在：$SERVICE_FILE"
fi

sudo ln -s /lib/systemd/system/rc-local.service /lib/systemd/system/
sudo systemctl enable rc-local
sudo touch /etc/rc.local
mkdir /home/sportvision/LOG
RC_FILE="/etc/rc.local"
RC_CONTENT="
#!/bin/sh
export DISPLAY=:0
wmctrl -k on
current_time=$(date +"%Y-%m-%d_%H-%M-%S")
echo "Current time: $current_time"
main_log_file="court1_${current_time}.log"
record_log_file="court1_${current_time}_record.log"
cd /home/sportvision/court1
nohup echo password|sudo -S -u sportvision bash main.sh >> "/home/sportvision/LOG/${main_log_file}"  2>&1 &
cd court1_record
nohup echo password|sudo -S -u sportvision python cap_record.py >> "/home/sportvision/LOG/${record_log_file}"  2>&1 &
"

if [ -f "$RC_FILE" ]; then
    echo "$RC_CONTENT" | sudo tee -a "$RC_FILE" > /dev/null
    echo "内容已成功添加到$RC_FILE"
else
    echo "服务文件不存在：$RC_FILE"
fi
sudo chmod +x /etc/rc.local


sudo snap install ffmpeg

#### python soft link ####
sudo ln -s /usr/bin/python3 /usr/bin/python
pip install -r requirements.txt
