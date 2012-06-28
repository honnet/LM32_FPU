//
// parametres.h
//
// Work for COMELEC380 - Kellya CLANZIG and Flavia CORREIA TOVO
//

#include <string>

#ifndef PARAMETRES_H
#define PARAMETRES_H

class Parametres{
	unsigned snumber; // number of slavers
	unsigned mnumber; // number of masters

	unsigned dw;    // Data bus Width
	unsigned aw;    // Address bus Width
	unsigned sw;    // Number of Select Lines
	unsigned mbusw; //address width + byte select width + dat width + cyc + we + stb +cab , input from master interface
	unsigned sbusw; //  ack + err + rty, input from slave interface

	unsigned gnt_bits_number;

	bool bit31_ignored; // true if the bit 31 is always ignored

	std::string module_name;
	std::string include;

	std::string buffer;

public:
	Parametres ();

	unsigned initialize();

	unsigned write_top();

	unsigned write_arb();

	std::string replace(const std::string & s1,
					const std::string & s2,
					const std::string & s3);
	// s3 will be put in s1 at the place of s2


	~Parametres();
};

#endif
