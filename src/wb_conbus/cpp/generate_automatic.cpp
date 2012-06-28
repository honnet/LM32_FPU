//
// generate_automatic.cpp
//
// Work for COMELEC380 - Kellya CLANZIG and Flavia CORREIA TOVO
//

#include <iostream>
#include <fstream>

#include "config_generate_automatic.h"
#include "parametres.h"

int main (int argc, const char* argv[])
{
	Parametres parametres;

	std::cout<< INTRODUCTION;
	std::cout<< std::endl;

	parametres.initialize();

	parametres.write_top();

	parametres.write_arb();

	return 0;
}
