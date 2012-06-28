//
// parametres.cpp
//
// Work for COMELEC380 - Kellya CLANZIG and Flavia CORREIA TOVO
//

#include <iostream>
#include <fstream>
#include <cmath>

#include "parametres.h"
#include "config_generate_automatic.h"

Parametres::Parametres ()
{
	snumber = 0;
	mnumber = 0;

	dw = 32;
	aw = 32;
	sw = dw/8;
	mbusw = aw+sw+dw+4;
	sbusw = 3;

	gnt_bits_number = 0;

	bit31_ignored = true;

	module_name = "wb_conbus_top";
	include = "wb_conbus_defines.v";
}

unsigned Parametres::initialize()
{
	char answer;

	do {
		std::cout<< std::endl << "How many masters?   > ";
		std::cin>> mnumber;

		if (mnumber == 0)
			std::cout<< ERROR_ZERO;
	} while (mnumber == 0);
	gnt_bits_number = (unsigned) ceil( sqrt( mnumber ));

	do {
		std::cout<< std::endl << "How many slaves?    > ";
		std::cin>> snumber;

		if (mnumber == 0)
			std::cout<< ERROR_ZERO;
	} while (snumber == 0);

	std::cout<<std::endl<<"Would you like to change the parametres? (y) or (n)  > ";
	std::cin>> answer;
	if ((answer == 'y')||(answer == 'Y'))
	{
		std::cout<< std::endl << "Would you like to change:"<< std::endl
			<< "Use (y) if you like to change; other char to use default param."<< std::endl<< std::endl
			<< "The data bus width? (dw = 32)  ";
		std::cin>> answer;
		if ((answer == 'y')||(answer == 'Y'))
		{
			std::cout<< "Enter new value    > ";
			std::cin>> dw;
		}
	
		std::cout<< std::endl<< "The adress bus width? (aw = 32)    ";
		std::cin>> answer;
		if ((answer == 'y')||(answer == 'Y'))
		{
			std::cout<< "Enter new value    > ";
			std::cin>> aw;
		}
	
		std::cout<< std::endl<< "The number of select lines? (sw = dw/8)    ";
		std::cin>> answer;
		if ((answer == 'y')||(answer == 'Y'))
		{
			std::cout<<"Enter new value    > ";
			std::cin>> sw;
		}
	
// 		std::cout<< std::endl<< "Use bit 31?";
// 		std::cin>> answer;
// 		if ((answer == 'y')||(answer == 'Y'))
// 		{
// 			bit31_ignored = false;
// 		}
	}

	std::cout<< std::endl<< "Parametres inicialized!"<<std::endl;

	return 0;
}

unsigned Parametres::write_top()
{
	std::ofstream file;
	std::string file_name = module_name+".v";

	char gnt_bits_number_str[3];
	char counter_buffer [5];
	
	file.open(file_name.c_str());
	if( !file )
	{
		std::cout << "Error opening file" << std::endl;
		return ERROR_OPENING_FILE;
	}

	sprintf( gnt_bits_number_str, "%d", gnt_bits_number );


	// Includes
	file << INT_FILE_1 <<std::endl;
	file << "`include \""<<include<<"\""<< std::endl;
	file << "`define	dw "<< dw <<"// Data bus Width"<< std::endl;
	file << "`define	aw "<< aw <<"// Address bus Width"<< std::endl;
	file << "`define	sw "<< sw <<"// Number of Select Lines"<< std::endl;
	file << "`define	mbusw "<< mbusw <<"// address width + byte select width + "
		<< "dat width + cyc + we + stb +cab , input from master interface"<< std::endl;
	file << "`define	sbusw "<< sbusw <<"// ack + err + rty, input from slave interface"<< std::endl;
	file << "`define	mselectw "<< mnumber <<"// number of masters"<< std::endl;
	file << "`define	sselectw "<< snumber <<"// number of slaves"<< std::endl;
	file << std::endl << std::endl;

	// Module name
	buffer = replace(MODULE1,"MODULE_NAME",module_name);
	file << buffer;

	// Parametres:
	for (unsigned i = 0; i< snumber; i++)
	{
		if (i <= 1)
		{
			sprintf( counter_buffer, "%d", i);
			buffer = replace(PARAM_S_ADR_W, "XX", counter_buffer);
			if (bit31_ignored)
				buffer = replace(buffer, "ZZ", "4");
			else
				buffer = replace(buffer, "ZZ", "5");
			file << buffer;

			buffer = replace(PARAM_S_ADR_W_COMEN, "XX", counter_buffer);
			file << buffer;
	
			if (bit31_ignored)
				file << PARAM_S_ADR_W_31BIT_N;
			else
				file << PARAM_S_ADR_W_31BIT_Y;

			buffer = replace(PARAM_S_ADR, "XX", counter_buffer);
			buffer = replace(buffer, "zz", counter_buffer);
	
			if (bit31_ignored)
			{
				buffer = replace(buffer, "ZZ", "4");
				file << buffer;
			}
			else
			{
				buffer = replace(buffer, "ZZ", "5");
				file << buffer;
			}

			if (i < (snumber-1))
				file<<",	";
			else
				file<<"		";

			buffer = replace(PARAM_S_ADR_COMEN, "XX", counter_buffer);
			file << buffer;
		}
		if (i == 2)
		{
			
			if (snumber >3)
				sprintf( counter_buffer, "%d", 20+snumber-1);
			else
				sprintf( counter_buffer, "%d", 2);

			buffer = replace(PARAM_S_ADR_W, "XX", counter_buffer);
			if (bit31_ignored)
				buffer = replace(buffer, "ZZ", "8");
			else
				buffer = replace(buffer, "ZZ", "9");
			file << buffer;

			sprintf( counter_buffer, "%d to slave %d", i*10,(snumber-1));
			buffer = replace(PARAM_S_ADR_W_COMEN, "XX", counter_buffer);
			file << buffer;

			if (bit31_ignored)
				file << PARAM_S_ADR_W_31BIT_N;
			else
				file << PARAM_S_ADR_W_31BIT_Y;
		}
		if (i >= 2)
		{
			std::string value;

			sprintf( counter_buffer, "%d", i);
			buffer = replace(PARAM_S_ADR, "XX", counter_buffer);
	
			if (bit31_ignored)
			{
				value = "9";
				buffer = replace(buffer, "zz", value.append(counter_buffer));
				buffer = replace(buffer, "ZZ", "8");
				file << buffer;
			}
			else
			{
				value = "F";
				buffer = replace(buffer, "zz", value.append(counter_buffer));
				buffer = replace(buffer, "ZZ", "9");
				file << buffer;
			}

			if (i < (snumber-1))
				file<<",";
			else
				file<<"	";

			buffer = replace(PARAM_S_ADR_COMEN, "XX", counter_buffer);
			file << buffer;
		}
	}
	file << AFTER_PARAM << std::endl;

	// Inputs and outputs names
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(MASTER_INTERFACE, "XX", counter_buffer);
		file << std::endl<< buffer << "," << std::endl;
	}

	for (unsigned i = 0; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(SLAVE_INTERFACE, "XX", counter_buffer);
		file << std::endl<< buffer;
		if(i < (snumber -1))
			file << "," << std::endl;
		else
			file << std::endl;
	}

	// Inputs and Outputs definitions
	file<< BEGIN_IOS <<std::endl <<std::endl;

	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(MASTER_INT_INOUTS, "XX", counter_buffer);
		file << std::endl<< buffer << std::endl;
	}

	for (unsigned i = 0; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(SLAVE_INT_INOUTS, "XX", counter_buffer);
		file << std::endl<< buffer << std::endl;
	}

	// Local wires
	buffer = replace(LOCAL_WIRES, "HH", gnt_bits_number_str);
	file<< std::endl<< buffer<< std::endl;

	// Master output Interfaces
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(MASTER_OUT_INT, "XX", counter_buffer);
		file << std::endl<< buffer << std::endl;
	}

	buffer = replace(I_BUS_S_PART1, "XX", "0");
	file << std::endl<< buffer;
	for (unsigned i = 1; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(I_BUS_S_PART2, "XX", counter_buffer);
		file << buffer;
	}
	buffer = replace(I_BUS_S_PART3, "XX", "0");
	file<< buffer;
	for (unsigned i = 1; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(I_BUS_S_PART4, "XX", counter_buffer);
		file << buffer;
	}
	buffer = replace(I_BUS_S_PART5, "XX", "0");
	file << buffer;
	for (unsigned i = 1; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(I_BUS_S_PART6, "XX", counter_buffer);
		file << buffer;
	}
	file<< I_BUS_S_PART7<<std::endl;

	// Slave output interfaces
	for (unsigned i = 0; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(SLAVE_OUT_INT, "XX", counter_buffer);
		file << std::endl<< buffer << std::endl;
	}

	// Master and Slave input interface
	file << "// Master and Slave input interface"<<std::endl
		<<"always @(gnt ,\n";
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(MASTER_IN_INT, "XX", counter_buffer);
		buffer = replace(buffer, "HH", gnt_bits_number_str);
		file << buffer;
		if(i < (mnumber -1))
			file << "," << std::endl;
		else
			file <<")"<< std::endl;
	}
	file<<"		case(gnt)"<<std::endl;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(MASTER_IN_INT2, "XX", counter_buffer);
		buffer = replace(buffer, "HH", gnt_bits_number_str);
		file << buffer;
	}
	sprintf( counter_buffer, "%d", mbusw );
	//m0_adr_i, m0_sel_i, m0_dat_i, m0_we_i, m0_cab_i, m0_cyc_i,m0_stb_i
	buffer = replace(MASTER_IN_INT_DEFAULT, "ZZ", counter_buffer);
	file << buffer<< std::endl;

	file << SLAVE_IN_INT;
	for (unsigned i = 0; i< snumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(SLAVE_IN_INT_2, "XX", counter_buffer);
		file << buffer;
	}
	file << SLAVE_IN_INT_VALUE<< std::endl;

	// Arbitor
	file <<"// Arbitor"<<std::endl;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(ARBITOR_M_ASSIGN, "XX", counter_buffer);
		buffer = replace(buffer, "HH", gnt_bits_number_str);
		file << buffer;
	}
	file << std::endl << ARBITOR_MODULE1;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", mnumber - i - 1 );
		buffer = replace(ARBITOR_MODULE1_2, "XX", counter_buffer);
		file << buffer;
		if(i < (mnumber -1))
			file << "," << std::endl;
	}
	file << ARBITOR_MODULE1_END<<std::endl;

	// Address decode logic
	sprintf( counter_buffer, "%d", mnumber -1);
	buffer = replace(DECODE_WIRE, "ZZ", counter_buffer);
	file << buffer;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(DECODE_M_SEL, "XX", counter_buffer);
		file << buffer;
		if(i < (mnumber -1))
			file << ", ";
		else
			file <<";"<< std::endl;
	}

	file << "always @(gnt ,\n";
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(DECODE_M_SEL, "XX", counter_buffer);
		file << buffer;
		if(i < (mnumber -1))
			file << ",";
		else
			file <<")"<< std::endl;
	}
	file<<"		case(gnt)"<<std::endl;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(DECODE_M_ADR, "XX", counter_buffer);
		buffer = replace(buffer, "HH", gnt_bits_number_str);
		file << buffer;
	}
	sprintf( counter_buffer, "%d", mnumber -1);
	buffer = replace(DECODE_M_ADR_DEFAULT, "ZZ", counter_buffer);
	file << buffer<< std::endl;

	// Decode all master address before arbitor for running faster
	file <<"// Decode all master address before arbitor for running faster"<<std::endl;
	// XX Slaves, xx Masters, ZZ Address, KK -1 ou 0 si bit 31 valid or not
	for (unsigned i = 0; i< mnumber; i++)
	{
		for (unsigned j = 0; j< snumber; j++)
		{
			if (j <= 1)
			{
				sprintf( counter_buffer, "%d", j);
				buffer = replace(DECODE_M_ADR_RUN_FASTER, "ZZ", counter_buffer);
			}
			if (j > 1)
			{
				if (snumber >3)
					sprintf( counter_buffer, "%d", 20+snumber-1);
				else
					sprintf( counter_buffer, "%d", 2);
				buffer = replace(DECODE_M_ADR_RUN_FASTER, "ZZ", counter_buffer);
			}
			sprintf( counter_buffer, "%d", i );
			buffer = replace(buffer, "xx",counter_buffer);

			sprintf( counter_buffer, "%d", j );
			buffer = replace(buffer, "XX",counter_buffer);

			if (bit31_ignored)
				buffer = replace(buffer, "KK", "-1");
			else
				buffer = replace(buffer,"KK"," ");

			file << buffer;
		}
		file << std::endl;
	}

	// end of module
	file << END_MODULE1<< std::endl;

	file.close();

	std::cout<< std::endl << "File "<< file_name <<" created!" << std::endl;

	return 0;
}

unsigned Parametres::write_arb()
{
	std::ofstream file;
	std::string module2_name = replace(module_name,"top","arb");
	std::string file_name = module2_name +".v";

	char gnt_bits_number_str[3];
	char counter_buffer [5];
	
	file.open(file_name.c_str());
	if( !file )
	{
		std::cout << "Error opening file" << std::endl;
		return ERROR_OPENING_FILE;
	}

	sprintf( gnt_bits_number_str, "%d", gnt_bits_number );

	file<< INT_FILE_2<< std::endl;
	file << "`include \""<<include<<"\""<< std::endl<< std::endl;

	// Module
	buffer = replace(MODULE2,"MODULE_NAME",module2_name);
	sprintf( counter_buffer, "%d", mnumber);
	buffer = replace(buffer,"ZZ",counter_buffer);
	buffer = replace(buffer,"HH",gnt_bits_number_str);
	file << buffer<<std::endl;

	buffer = replace(PARAMETRES,"HH",gnt_bits_number_str);
	file << buffer;
	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(PARAM_2, "XX", counter_buffer);
		buffer = replace(buffer,"HH",gnt_bits_number_str);
		file << buffer;
		if(i < (mnumber -1))
			file << ","<< std::endl;
		else
			file <<";"<< std::endl<< std::endl;
	}

	buffer = replace(REGS,"HH",gnt_bits_number_str);
	file << buffer<<std::endl;

	file<<MISC_LOGIC<<std::endl;

	file<<NEXT_ST_LOG;

	for (unsigned i = 0; i< mnumber; i++)
	{
		sprintf( counter_buffer, "%d", i );
		buffer = replace(NEXT_ST_LOG_2, "xx",counter_buffer);
		file<<buffer;

		unsigned k = i;
		for (unsigned j = 0; j< mnumber; j++)
		{
			
			if (k != i)
			{
				sprintf( counter_buffer, "%d", k);
				buffer = replace(NEXT_ST_LOG_3, "XX", counter_buffer);
				file<<buffer;

				if (j < mnumber-1)
					file<<"			else"<<std::endl;
			}

			k++;
			if(k == mnumber)
				k = 0;

			if (j == mnumber-1)
				file<<"		   end"<<std::endl;
		}
	}

	file<< END;

	file.close();

	std::cout<< "File "<< file_name <<" created!" <<std::endl;

	return 0;
}


std::string Parametres::replace( const std::string & str,
				const std::string & will_be_excluded,
				const std::string & will_be_put)
{
	std::string str_done;
	std::string::size_type index;

	str_done.assign( str );

	while((index = str_done.find(will_be_excluded))!= std::string::npos)
	{
		str_done.replace(index,will_be_excluded.length(), will_be_put);
	}

	return str_done;
}

Parametres::~Parametres()
{
	
}
