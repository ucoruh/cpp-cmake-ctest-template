/**
 * @file mathUtility.h
 * 
 * @brief Provides functions for math. utilities
 */

#ifndef MATH_UTILITY_H
#define MATH_UTILITY_H

#include "commonTypes.h"

namespace Coruh
{
    namespace Utility
    {
        /**
            @class MathUtility
            @brief Provides Math. functions for various operations.
        */
        class MathUtility
        {
        public:
			/**
			 * @brief Calculates the mean (average) of an array of data.
			 *
			 * This function calculates the mean (average) of the given array of data.
			 * The data array should contain datalen elements.
			 *
			 * @param fiArray The array of data.
			 * @param fiArrayLen The length of the data array.
			 * @return The calculated mean.
			 */
			static double calculateMean(const double fiArray[], int fiArrayLen);

			/**
			 * @brief Calculates the median of an array of data.
			 *
			 * This function calculates the median of the given array of data.
			 * The data array should contain datalen elements.
			 *
			 * @param fiArray The array of data.
			 * @param fiArrayLen The length of the data array.
			 * @return The calculated median.
			 */
			static double calculateMedian(const double fiArray[], int fiArrayLen);

			/**
			 * @brief Compares two double values for sorting purposes.
			 *
			 * This function is used as a comparison function for sorting an array of doubles in ascending order.
			 *
			 * @param fiPtrLhs Pointer to the first double value.
			 * @param fiPtrRhs Pointer to the second double value.
			 * @return An integer value indicating the comparison result.
			 *   - -1 if the first value is less than the second value.
			 *   - 0 if the values are equal.
			 *   - 1 if the first value is greater than the second value.
			 */
			static int compareDouble(const void *fiPtrLhs, const void *fiPtrRhs);

			/**
			 * @brief Calculates the minimum and maximum values in an array of data.
			 *
			 * This function calculates the minimum and maximum values in the given array of data.
			 * The data array should contain datalen elements.
			 *
			 * @param fiArray The array of data.
			 * @param fiArrayLen The length of the data array.
			 * @param foMin Pointer to store the minimum value.
			 * @param foMax Pointer to store the maximum value.
			 */
			static void calculateMinMax(const double fiArray[], int fiArrayLen, double *foMin, double *foMax);

        };
    }
}

#endif // FILE_UTILITY_H