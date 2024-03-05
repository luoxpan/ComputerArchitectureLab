#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <memory.h>
#include <immintrin.h>

int N ;
int BLOCKSIZE;

void gemm_baseline(float *A, float *B, float *C)
{
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)
        {
            for (int k = 0; k < N; ++k)
            {
                C[i * N + j] += A[i * N + k] * B[k * N + j];
            }
        }
    }
}

void gemm_verify(float *C1, float *C2)
{
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)
        {
            if (C1[i * N + j] != C2[i * N + j])
            {
                printf("ERROR! %f,%f\n",C1[i*N+j],C2[i*N+j]);
                return;
            }
        }
    }
    return;
}

void gemm_avx(float *A, float *B, float *C)
{
    __m256 tmp;
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; j += 8)
        {
            tmp = _mm256_loadu_ps(C + i * N + j);
            for (int k = 0; k < N; ++k)
            {
                tmp = _mm256_add_ps(tmp, _mm256_mul_ps(_mm256_broadcast_ss(A + i * N + k), _mm256_loadu_ps(B + k * N + j)));
                _mm256_storeu_ps(C + i * N + j, tmp);
            }
        }
    }
}



void gemm_avx_one_block(int i0, int j0, int k0, float *A, float *B, float *C)
{
    __m256 tmp;
    for (int i = i0; i < i0 + BLOCKSIZE; ++i)
    {
        for (int j = j0; j < j0 + BLOCKSIZE; j += 8)
        {
            tmp = _mm256_loadu_ps(C + i * N + j); //取出16个float
            for (int k = k0; k < k0 + BLOCKSIZE; ++k)
            {
                tmp = _mm256_add_ps(tmp, _mm256_mul_ps(_mm256_broadcast_ss(A + i * N + k), _mm256_loadu_ps(B + k * N + j)));
            }
            _mm256_storeu_ps(C + i * N + j, tmp);
        }
    }
}

void gemm_avx_block(float *A, float *B, float *C)
{
    for (int i = 0; i < N; i += BLOCKSIZE) 
    {
        for (int j = 0; j < N; j += BLOCKSIZE) 
        {
            for (int k = 0; k < N; k += BLOCKSIZE)
            {
                gemm_avx_one_block(i, j, k, A, B, C);
            }
        }
    }
}


int test()
{
    printf("N=%d,BLOCKSIZE=%d\n",N,BLOCKSIZE);
    float *A = malloc(sizeof(float) * N * N);
    float *B = malloc(sizeof(float) * N * N);
    float *C1 = malloc(sizeof(float) * N * N);
    float *C2 = malloc(sizeof(float) * N * N);
    float *C3 = malloc(sizeof(float) * N * N);

    for (int i = 0; i < N * N; ++i)
    {
        A[i] = rand() / (double)(10.0);
        B[i] = rand() / (double)(10.0);
    }
    memset(C1,0,sizeof(C1));
    memset(C2,0,sizeof(C2));
    memset(C3,0,sizeof(C3));

    clock_t start_time, end_time;
    start_time = clock();
    gemm_baseline(A, B, C1);
    end_time = clock();
    double t1= (end_time - start_time) / (double)(CLOCKS_PER_SEC);
    printf("%.5lf\n", t1);

    start_time = clock();
    gemm_avx(A, B, C2);
    end_time = clock();
    gemm_verify(C1, C2);
    double t2= (end_time - start_time) / (double)(CLOCKS_PER_SEC);
    double eta2=(t1-t2)/t1*100;
    printf("%.5lf %.2f%% \n", t2,eta2);

    start_time = clock();
    gemm_avx_block(A, B, C3);
    end_time = clock();
    double t3= (end_time - start_time) / (double)(CLOCKS_PER_SEC);
    double eta3=(t1-t3)/t1*100;
    printf("%.5lf %.2f%% \n", t3,eta3);

    gemm_verify(C1, C3);

    free(A);
    free(B);
    free(C1);
    free(C2);
    free(C3);
}

int main()
{
    BLOCKSIZE=1<<4;
    for(int n=6;n<11;n++){
        N=1<<n;
        test();
    }
    N=1<<8;
    for(int b=3;b<8;b++){
        BLOCKSIZE=1<<b;
        test();
    }
    return 0;
}


