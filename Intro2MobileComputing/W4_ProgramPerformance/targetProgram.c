#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ARRAY_LEN 100

void generateArray(int *arr, int len);
void findMinMax(int *arr, int len, int *min, int *max);


int main() {
	int arr[ARRAY_LEN];
	int min, max;

	generateArray(arr, ARRAY_LEN);

	findMinMax(arr, ARRAY_LEN, &min, &max);

	printf("(Min, Max) = (%d, %d)\n", min, max);

	return 0;
}


void generateArray(int *arr, int len) {
	int i;
	srand(time(NULL));

	for(i = 0; i < len; i++) {
		arr[i] = rand();
		printf("%d, ", arr[i]);
	}
}

void findMinMax(int *arr, int len, int *resMin, int *resMax) {
	int min = arr[0];
	int max = arr[0];
	int i;
	for(i = 1; i < len; i++) {
		if(arr[i] < min) min = arr[i];
		if(arr[i] > max) max = arr[i];
	}

	*resMin = min;
	*resMax = max;
}

