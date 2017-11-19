#include <iostream>
#include <iomanip>
#include <string>
#include <cmath>
using namespace std;

int findMultiple(char);
int convertHex(string);

class stackType
{
	public:
		void push(int);
		int pop();
		nodeType* top;
};

struct nodeType
{
	stackType info;
    nodeType *next;
};

int main()
{
	//Converting using powers of 16
	int multiple;					//16^(exponent) * multiple
	stackType Decimal;
	int decimal_int = 0;
	string str;
	cout << "Hexadecimal: ";
	cin >> str;
	int start = 0;
	for (int i = 0; i < str.length(); i++)
	{
		if (str.at(i) == ',')
			Decimal.push(convertHex(str.substr(start, (i - start))));
		start++;


	}
	return 0;
}

int convertHex(string hex_str)
{
	int mult;
	int power = hex_str.length() - 1;
	int decimal_int = 0;
	for (int i = 0; i < hex_str.length - 1; i++)
	{
		mult = findMultiple(hex_str.at(i));
		if (mult = -1)
			return -1;
		decimal_int = decimal_int + (pow(16, power) * mult);
	}
	
}

int findMultiple(char ch)
{
	if (ch == '0')
		return 0;
	if (ch == '1')
		return 1;
	if (ch == '2')
		return 2;
	if (ch == '3')
		return 3;
	if (ch == '4')
		return 4;
	if (ch == '5')
		return 5;
	if (ch == '6')
		return 6;
	if (ch == '7')
		return 7;
	if (ch == '8')
		return 8;
	if (ch == '9')
		return 9;
	if (ch == 'A' || ch == 'a')
		return 10;
	if (ch == 'B' || ch == 'b')
		return 11;
	if (ch == 'C' || ch == 'c')
		return 12;
	if (ch == 'D' || ch == 'd')
		return 13;
	if (ch == 'E' || ch == 'e')
		return 14;
	if (ch == 'F' || ch == 'f')
		return 15;
	return -1;
}
