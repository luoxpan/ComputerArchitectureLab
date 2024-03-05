#include <stdio.h>

#define SIZE 32 // 块大小

__global__ void gemm_baseline(float *A, float *B, float *C, int N)
{
    int idx_x = blockIdx.x * blockDim.x + threadIdx.x; 
    int idx_y = blockIdx.y * blockDim.y + threadIdx.y; 

    float sum = 0.f;
    if (idx_x < N && idx_y < N)
    { 
        for (int kk = 0; kk < N; ++kk)
        {
            sum += A[idx_y * N + kk] * B[kk * N + idx_x];
        }
        C[idx_y * N + idx_x] = sum;
    }
}

__global__ void gemm_block(float *A, float *B, float *C, int N) {

  __shared__ float s_a[SIZE][SIZE];
  __shared__ float s_b[SIZE][SIZE];

  int idx_x = blockIdx.x * blockDim.x + threadIdx.x;
  int idx_y = blockIdx.y * blockDim.y + threadIdx.y;

  float sum = 0.0;
  for (int bk = 0; bk < N; bk += SIZE) {
    s_a[threadIdx.y][threadIdx.x] = A[idx_y * N + bk + threadIdx.x];
    s_b[threadIdx.y][threadIdx.x] = B[(bk + threadIdx.y) * N + idx_x];
    __syncthreads();

    for (int i = 0; i < SIZE; ++i) {
      sum += s_a[threadIdx.y][i] * s_b[i][threadIdx.x];
    }
    __syncthreads();
  }

  if (idx_x < N && idx_y < N) {
    C[idx_y * N + idx_x] = sum;
  }
}

int main()
{
    float *A, *B, *C;
    int N = 512; 

    A = new float[N * N](); 
    B = new float[N * N]();
    C = new float[N * N]();
    float *d_A, *d_B, *d_C;
    cudaMalloc((void **)&d_A, N * N * sizeof(float));
    cudaMalloc((void **)&d_B, N * N * sizeof(float));
    cudaMalloc((void **)&d_C, N * N * sizeof(float));

    // 在主机(CPU)中产生数据
    for (int i = 0; i < N * N; ++i)
    {
        A[i] = static_cast<float>(rand()%10);
        B[i] = static_cast<float>(rand()%10);
    }

    // 将数据从主机(CPU)内存拷贝到设备(GPU)内存
    cudaMemcpy(d_A, A, N * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, N * N * sizeof(float), cudaMemcpyHostToDevice);

    dim3 blockSize(SIZE, SIZE, 1);
    dim3 gridSize((N + blockSize.x - 1) / blockSize.x, (N + blockSize.y - 1) / blockSize.y, 1);
    //dim3 gridSize(2, 2, 1);
    // 使用kernel计算C矩阵
    gemm_block<<<gridSize, blockSize>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize(); 

    // 将数据从设备(GPU)内存拷贝回主机(CPU)内存
    cudaMemcpy(C, d_C, N * N * sizeof(float), cudaMemcpyDeviceToHost);

    // 进行结果验证
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)
        {
            float result = 0;
            for (int kk = 0; kk < N; ++kk)
            {
                result += A[i * N + kk] * B[kk * N + j];
            }
            if (C[i * N + j] != result)
            { 
                printf("error!\n");
                exit(-1);
            }
        }
    }

    // 释放内存
    delete[] A;
    delete[] B;
    delete[] C;
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}