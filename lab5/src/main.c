#include <time.h>
#include <immintrin.h>
#include <stdlib.h>
#include <stdio.h>

const int N=1<<10;
int NN=N*N;
int BLOCK_SIZE=1<<5;

void gemm_baseline(float *A, float *B, float *C) {
    for(int i=0;i<N;i++){
        for(int j=0;j<N;j++){
            float sum=0;
            for(int k=0;k<N;k++){
                sum+=A[i*N+k]*B[k*N+j];
            }
            C[i*N+j]=sum;
        }
    }
}

void gemm_avx(float *A, float *B, float *C) {
    __m256 c0;
    __m128 temp_a, temp_b, temp_c;
    float* c_tmp = (float*)malloc(8 * sizeof(float));

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j += 8) {
            c0 = _mm256_load_ps(C + i * N + j);
            if (N - j > 7) {
                for (int k = 0; k < N; k++) {
                    c0 = _mm256_add_ps(c0, _mm256_mul_ps(_mm256_broadcast_ss(A + i * N + k), _mm256_load_ps(B + k * N + j)));
                }
                _mm256_store_ps(C + i * N + j, c0);
            }
            if (N - j >= 4 && N - j <= 7) {
                temp_c = _mm_load_ps(C + i * N + j);
                for (int k = 0; k < N; k++) {
                    temp_a = _mm_broadcast_ss(A + i * N + k);
                    temp_b = _mm_load_ps(B + k * N + j);
                    temp_c = _mm_add_ps(temp_c, _mm_mul_ps(temp_a, temp_b));
                }
                _mm_store_ps(c_tmp, temp_c);
                *(C + i * N + j) = c_tmp[0];
                *(C + i * N + j + 1) = c_tmp[1];
                *(C + i * N + j + 2) = c_tmp[2];
                *(C + i * N + j + 3) = c_tmp[3];
            }
            if (N - j < 4) {
                float temp_a, temp_b, temp_c = 0;
                for (int k = 0; k < N; k++) {
                    temp_a = *(A + i * N + k);
                    temp_b = *(B + k * N + j);
                    temp_c += temp_a * temp_b;
                }
                *(C + i * N + j) = temp_c;
            }
        }
    }
}

void gemm_avx_block(float *A,float *B,float *C, int block_size){
    __m256 c0;
    __m128 temp_a, temp_b, temp_c;
    int finished_i_blocks, finished_j_blocks;  //已经处理完的 i 和 j 的块数量
    float* c_tmp = (float*)malloc(8 * sizeof(float));
    // 对整块进行计算
    for (int i0 = 0; i0 < N; i0 += block_size) {
        finished_i_blocks = i0 / block_size;
        for (int j0 = 0; j0 < N; j0 += block_size) {
            finished_j_blocks = j0 / block_size;
            for (int i = i0; i < i0 + block_size; i++) {
                for (int j = j0; j < j0 + block_size; j += 8) {
                    c0 = _mm256_load_ps(C + i * N + j);
                    if (N - j > 7) {
                        for (int k = 0; k < N; k++) {
                            c0 = _mm256_add_ps(c0, _mm256_mul_ps(_mm256_broadcast_ss(A + i * N + k), _mm256_load_ps(B + k * N + j)));
                        }
                        _mm256_store_ps(C + i * N + j, c0/2.0);
                    }
                    if (N - j >= 4 && N - j <= 7) {
                        temp_c = _mm_load_ps(C + i * N + j);
                        for (int k = 0; k < N; k++) {
                            temp_a = _mm_broadcast_ss(A + i * N + k);
                            temp_b = _mm_load_ps(B + k * N + j);
                            temp_c = _mm_add_ps(temp_c, _mm_mul_ps(temp_a, temp_b));
                        }
                        _mm_store_ps(c_tmp, temp_c);
                        *(C + i * N + j) = c_tmp[0]/2.0;
                        *(C + i * N + j + 1) = c_tmp[1]/2.0;
                        *(C + i * N + j + 2) = c_tmp[2]/2.0;
                        *(C + i * N + j + 3) = c_tmp[3]/2.0;
                    }
                    if (N - j < 4) {
                        float temp_a, temp_b, temp_c = 0;
                        for (int k = 0; k < N; k++) {
                            temp_a = *(A + i * N + k);
                            temp_b = *(B + k * N + j);
                            temp_c += temp_a * temp_b;
                        }
                        *(C + i * N + j) = temp_c/2.0;
                    }
                }
            }
        }
    }

    // 处理剩余的行和列
    for (int i = finished_i_blocks * block_size; i < N; i++) {
        for (int j = finished_j_blocks * block_size; j < N; j++) {
            float sum = C[i * N + j];
            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum/2.0;
        }
    }
}

int gemm_verify(float *C1,float *C2){
    for(int i=0;i<NN;i++){
        if(abs(C1[i]-C2[i])>1e-15){
            printf("error! %f,%f\n",C1[i],C2[i]);
        }
    }
    return 1;
}

int main() {
    float *A0 = (float *)malloc(NN * sizeof(float));
    float *B0 = (float *)malloc(NN  * sizeof(float));
    float *C1 = (float *)malloc(NN * sizeof(float));
    float *C2 = (float *)malloc(NN * sizeof(float));

    srand(time(NULL));
    int i, j;
    for (i = 0; i < N; ++i) {
        for (j = 0; j < N; ++j) {
            A0[i * N + j] = (float)rand() / RAND_MAX * (-10.0f - 10) + 10;
            B0[i * N + j] = (float)rand() / RAND_MAX * (-10.0f - 10) + 10;
        }
    }
    clock_t s, e;
    s = clock();
    gemm_baseline(A0, B0, C1);
    e = clock();
    printf("base_line time: %f\n", (float)(e - s) / CLOCKS_PER_SEC);

    s = clock();
    gemm_avx(A0, B0, C2);
    e = clock();
    printf("avx time: %f\n", (float)(e - s) / CLOCKS_PER_SEC);
    gemm_verify(C1,C2);

    s = clock();
    gemm_avx_block(A0, B0, C2,BLOCK_SIZE);
    e = clock();
    printf("avx_block time: %f\n", (float)(e - s) / CLOCKS_PER_SEC);
    gemm_verify(C1,C2);

    free(A0);
    free(B0);
    free(C1);
    free(C2);
    return 0;
}








