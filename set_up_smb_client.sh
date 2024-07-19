## 使用/mnt/remote_folder去共享远程主机的文件

# sudo mkdir /mnt/remote_folder
# sudo chown sportvision:sportvision /mnt/remote_folder
# sudo apt install smbclient -y
# sudo mount -t cifs //172.22.2.162/shared_folder /mnt/remote_folder -o username=sportvision,password=sv04091211,rw

remote_folder="/mnt/remote_folder"
remote_host="172.22.2.162"
sudo mkdir "$remote_folder"
sudo chown sportvision:sportvision "$remote_folder"
sudo apt install smbclient -y
sudo mount -t cifs "//$remote_host/shared_folder" "$remote_folder" -o username=sportvision,password=sv04091211,rw