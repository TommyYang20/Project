#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

#define SIZE 1024

volatile __uint64_t A[SIZE][SIZE];
volatile __uint64_t B[SIZE][SIZE];
volatile __uint64_t C[SIZE][SIZE];
volatile __uint64_t D[SIZE][SIZE];
volatile __uint64_t E[SIZE][SIZE];

void transpose(volatile __uint64_t T[][SIZE]) {
    int i, j, temp;
    for (i = 0; i < SIZE; i++) {
        for (j = i; j < SIZE; j++) {
            if (i != j) {
                temp = T[j][i];
                T[j][i] = T[i][j];
                T[i][j] = temp;
            }
        }
    }
}

void init(volatile __uint64_t A[][SIZE], volatile __uint64_t B[][SIZE])
{
	int r, c;

	for (c = 0; c < SIZE; c++) {
		for (r = 0; r < SIZE; r++) {
			A[r][c] = rand();
			B[r][c] = rand();
		}
	} 
}

int verify(volatile __uint64_t C[][SIZE], volatile __uint64_t D[][SIZE])
{
	int r, c;

	for (c = 0; c < SIZE; c++) {
		for (r = 0; r < SIZE; r++) {
			if (C[r][c] != D [r][c]) {
				printf("error!\n");
				goto out;
			}
			
		}
	}
	return 0;

out:
	return -1;
}

void matmul(volatile __uint64_t A[][SIZE], volatile __uint64_t B[][SIZE])
{
	int rowA, colB, idx;

	for (rowA = 0; rowA < SIZE; rowA++) {
		for (colB = 0; colB < SIZE; colB++) {
			for (idx = 0; idx < SIZE; idx++) {
				C[rowA][colB] += A[rowA][idx] * B[idx][colB];
			}
		}
	}
}

void matmulT(volatile __uint64_t A[][SIZE], volatile __uint64_t B[][SIZE]) {
    int rowA, rowB, idx;
    for (rowA = 0; rowA < SIZE; rowA++) {
        for (rowB = 0; rowB < SIZE; rowB++) {
            for (idx = 0; idx < SIZE; idx++) {
                D[rowA][rowB] += A[rowA][idx] * B[rowB][idx];
            }
        }
    }
}

void matmulTT(volatile __uint64_t A[][SIZE], volatile __uint64_t B[][SIZE], int tileSize) {
    int rowA, colB, idx, i, j, k;
    
    for (rowA = 0; rowA < SIZE; rowA += tileSize) {
        for (colB = 0; colB < SIZE; colB += tileSize) {
            /*for (k = 0; k < SIZE; k += tileSize) {
                for (i = rowA; i < (rowA+tileSize); i++) {
                    for (j = colB; i < (colB+tileSize); j++) {*/
						for (idx = k; idx < (k+tileSize); idx++) {
                        	E[rowA][colB] += A[rowA][idx] * B[idx][colB];
                    	}
					}
                }
            }
       /* }
   }
}*/

int main(int argc, char *argv)
{
	clock_t t;
	double time_taken;

	init(A, B);
	memset((__uint64_t**)C, 0, sizeof(__uint64_t) * SIZE * SIZE);
    matmulTT(A, B, 2);
	//matmul(A, B);
	//transpose(B);
	t = clock();
	//matmulT(A, B);
	t = clock() - t;
	//if (verify(C, D) == 0)
		//printf("D is good. \n");
	//else
		//printf("D is bad. \n");
    if (verify(C, E) == 0)
        printf("E is good. \n");
    else
        printf("E is bad. \n");
	time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds
	
	printf("Matmul took %f seconds to execute \n", time_taken);
}
