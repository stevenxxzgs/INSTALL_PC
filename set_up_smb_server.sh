## 使用shared_folder去共享自己的内部文件
sudo mkdir /shared_folder
sudo chmod 755 /shared_folder  # 设置文件夹权限
sudo chown sportvision:sportvision /shared_folder  # 设置文件夹所有者

sudo apt install samba -y
sudo apt install smbclient -y
sudo pdbedit -a -u sportvision << EOF
sv04091211
sv04091211
EOF

