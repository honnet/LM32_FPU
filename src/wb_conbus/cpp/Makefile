#
# Makefile for the program of automatically generation
#
#
#
#
# Work for COMELEC380 - Kellya CLANZIG and Flavia CORREIA TOVO
# June 2009
#


EXEC = generate_automatic

FILES = generate_automatic.cpp parametres.cpp
OBJS = $(patsubst %.cpp,%.o,$(FILES))

INCLUDES = $(patsubst %.cpp,%.d,$(FILES))

CXX= g++
CCC= $(CXX)

CXXFLAGS= -Wall
CCFLAGS= ${CXXFLAGS}

LDFLAGS=

LDLIBS= 

all: $(EXEC)

#-include $(INCLUDES)

$(EXEC): $(OBJS) Makefile #config_generate_automatic.h parametres.h
	$(CCC) $(CCFLAGS) $(LDFLAGS) -o $@ $(OBJS) ${LDLIBS}

%.d: %.cpp
	$(CCC) -MM -MF $@ -MP -MT $(patsubst %.cpp,%.o,$<) $<

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH)-o $@ $< 

clean:
	rm -f $(EXEC) $(OBJS) $(INCLUDES) *~
