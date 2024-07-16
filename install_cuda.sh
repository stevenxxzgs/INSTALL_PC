#!/bin/bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.3.2/local_installers/cuda-repo-ubuntu2204-12-3-local_12.3.2-545.23.08-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-3-local_12.3.2-545.23.08-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-3
SOURCES_LIST="$HOME/.bashrc"
SOURCES=(
"export PATH=/usr/local/cuda/bin:\$PATH"
"export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH"
)
if [ -e "$SOURCES_LIST" ]; then
    # sudo truncate -s 0 "$SOURCES_LIST"
    echo "here is"
else
    sudo touch "$SOURCES_LIST"
    echo "$SOURCES_LIST 文件不存在，已创建。"
fi

for SOURCE in "${SOURCES[@]}"; do
    echo "$SOURCE" | sudo tee -a "$SOURCES_LIST"
done

echo "已成功添加新的路径到 $SOURCES_LIST"
source ~/.bashrc
