#!/bin/bash
exec > >(tee -a /home/sportvision/INSTALL_PC/install_cuda.log) 2>&1
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
echo "sv04091211" | sudo -S -u root  mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.3.2/local_installers/cuda-repo-ubuntu2204-12-3-local_12.3.2-545.23.08-1_amd64.deb
echo "sv04091211" | sudo -S -u root  dpkg -i cuda-repo-ubuntu2204-12-3-local_12.3.2-545.23.08-1_amd64.deb
echo "sv04091211" | sudo -S -u root  cp /var/cuda-repo-ubuntu2204-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/
echo "sv04091211" | sudo -S -u root  apt-get update
echo "sv04091211" | sudo -S -u root  apt-get -y install cuda-toolkit-12-3
SOURCES_LIST="$HOME/.bashrc"
SOURCES=(
"export PATH=/usr/local/cuda/bin:\$PATH"
"export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH"
)
if [ -e "$SOURCES_LIST" ]; then
    # echo "sv04091211" | sudo -S -u root  truncate -s 0 "$SOURCES_LIST"
    echo "here is"
else
    echo "sv04091211" | sudo -S -u root  touch "$SOURCES_LIST"
    echo "$SOURCES_LIST 文件不存在，已创建。"
fi

for SOURCE in "${SOURCES[@]}"; do
    echo "$SOURCE" | sudo tee -a "$SOURCES_LIST"
done

echo "已成功添加新的路径到 $SOURCES_LIST"
source ~/.bashrc
