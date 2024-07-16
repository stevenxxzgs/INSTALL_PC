## 查看cuda版本
# nvcc --version

## wget 对应的安装包，cuda=12.0-12.5
filename="nv-tensorrt-local-repo-ubuntu2204-10.2.0-cuda-12.5_1.0-1_amd64.deb"
min_size=2621400000 

# 检查文件是否存在
if [ -f "$filename" ]; then
    filesize=$(du -b "$filename" | cut -f1)
    if [ "$filesize" -lt "$min_size" ]; then
        echo "File size is less than 2.5GB. Deleting and downloading..."
        rm "$filename"
        wget https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.2.0/local_repo/$filename
    else
        echo "File already exists and is of sufficient size."
    fi
else
    echo "File does not exist. Downloading..."
    wget https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.2.0/local_repo/$filename
fi


## 安装tensorrt
sudo dpkg -i nv-tensorrt-local-repo-ubuntu2204-10.2.0-cuda-12.5_1.0-1_amd64.deb
sudo cp /var/nv-tensorrt-local-repo-ubuntu2204-10.2.0-cuda-12.5/*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get install tensorrt

## 安装其他支持
python3 -m pip install --upgrade pip
python3 -m pip install wheel
python3 -m pip install --upgrade tensorrt
python3 -m pip install numpy onnx onnx-graphsurgeon

## 设置环境变量
sudo su
export PATH=/usr/local/cuda-12.3/bin:/usr/local/cuda/bin:$PATH
su sportvision
export PATH=/usr/local/cuda-12.3/bin:/usr/local/cuda/bin:$PATH

## 安装pycuda支持
pip install pycuda==2024.1
python3 -m pip install --upgrade setuptools pip
python3 -m pip install nvidia-pyindex

## 检查安装情况
dpkg-query -W tensorrt
python -c "import tensorrt; print(tensorrt.__version__); assert tensorrt.Builder(tensorrt.Logger())"
python -c "
import pycuda.autoinit
import pycuda.driver as drv
import numpy as np
import time
from pycuda.compiler import SourceModule

mod = SourceModule('''
__global__ void Text_GPU(float *A, float *B, float *K, size_t N){
    int bid = blockIdx.x;    
    int tid = threadIdx.x;
    __shared__ float s_data[20];
    s_data[tid] = (A[bid*20 + tid] - B[bid*20 + tid]);
    __syncthreads();
    if(tid == 0)
    {
        float sum_d = 0.0;
        for(int i = 0; i < 20; i++)
        {
            sum_d += (s_data[i] * s_data[i]);
        }
        K[bid] = exp(-sum_d);
    }
}
''')

multiply_them = mod.get_function('Text_GPU')
tic = time.time() 
A = np.random.random((1000,20)).astype(np.float32)
B = np.random.random((1000,20)).astype(np.float32)
K = np.zeros((1000,), dtype=np.float32)
N = 20
N = np.int32(N)   
multiply_them(
        drv.In(A), drv.In(B), drv.InOut(K), N,
        block=(20,1,1), grid=(1000,1))
toc = time.time()
print('time cost is:' + str(toc - tic))
"