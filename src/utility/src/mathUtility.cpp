/**
 * @file mathUtility.cpp
 *
 * @brief Provides functions for math. utilities
 */

#include <cstring>

#include "../header/mathUtility.h"

using namespace Coruh::Utility;


double MathUtility::calculateMean(const double data[], int datalen) {
	double sum = 0.0;

	for (int i = 0; i < datalen; ++i) {
		sum += data[i];
	}

	return sum / datalen;
}

double MathUtility::calculateMedian(const double data[], int datalen) {

	//TODO: Move this memory allocation to control function
	double* sortedData = new double[datalen];
	double median = 0;

	memcpy(sortedData, data, sizeof(double) * datalen);

	qsort(sortedData, datalen, sizeof(double), compareDouble);

	if (datalen % 2 == 0) {
		int index1 = datalen / 2 - 1;
		int index2 = datalen / 2;
		median = (sortedData[index1] + sortedData[index2]) / 2.0;
	}else {
		int index = datalen / 2;
		median = sortedData[index];
	}

	delete[] sortedData;
	return median;
}

int MathUtility::compareDouble(const void* a, const void* b) {
	
	double val1 = *(const double*)a;
	double val2 = *(const double*)b;

	if (val1 < val2) {
		return -1;
	}else if (val1 > val2) {
		return 1;
	}else {
		return 0;
	}
}

void MathUtility::calculateMinMax(const double data[], int datalen, double* min, double* max) {
	
	*min = data[0];
	*max = data[0];

	for (int i = 1; i < datalen; ++i) {
	
		if (data[i] < *min) {
			*min = data[i];
		}
	
		if (data[i] > *max) {
			*max = data[i];
		}
	}
}

