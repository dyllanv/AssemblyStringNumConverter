# AssemblyStringNumConverter

CS271 - Computer Architecture and Assembly Language: Portfolio Assignment

Converts a string of numbers to a numeric representation. Converts the numeric representation back into a string to display to user. User enters 10 signed integers to be put in a array. The final array, the sum of numbers in the array, and the rounded average of the numbers is then displayed to the user.

Implements homemade readVal and and writeVal procedures for signed integers.
Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input
from the user, and WriteString to display output. Program asks user to input a numeric value that
can fit inside a 32 bit register. Uses macro to get input as a string. String value is then converted,
if valid, into numeric value and stored in an array. User must enter 10 values to be placed in array.
A running sum is kept and displayed throughout the program. The array is then displayed, the total sum
is displayed, and the average of input values is displayed (rounded down to nearest integer). Each time
a number is displayed (after having been converted from string to numeric form), the numeric value is
converted into a string (in reverse). The reversed string is then reversed/aligned to be displayed as
a string, by calling a macro to display it, reflecting the proper numeric value. Conversions are made
by converting ascii values to decimal, and then back to ascii.
