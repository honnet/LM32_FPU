#include <stdio.h>
#define PSH(X) (*(st++)=(X))

#define PLUS 1
#define SPACE 2

#define fabs(x) ((x)<0 ? (-x) : (x))

/* FIXME: This file contains roundoff error */

char * ftoa(char *stin, float f, int flags)
{
  int i;
  unsigned char z;
  int exp = 0;
  char *st ;

  st = stin ;

  if (f < 0.0) {
    PSH('-');
    f = -f;
  } else {
    if (flags & PLUS) PSH('+');
    if (flags & SPACE) PSH(' ');
  }

  if (f) {
    while (f < 1.0) {
      f *=10.0;
      exp--;
    }

    while (f >= 10.0) {
      f /=10.0;
      exp++;
    }
  }

  while ((exp > 0) && (exp < 7)) {
	  z = f;
printf("%d \r\n",z) ;
	  PSH('0'+z);
	  f -= z;
	  f *= 10.0;
  	exp--;
  }

  z = f;
  PSH('0'+z);
  f -= z;
  f *= 10.0;

  PSH('.');

  for (i=0;i<2;i++) {
    z = f;
    PSH('0'+f);
    f -= z;
    f *= 10.0;
  }
  
  if (exp != 0) {

	  PSH('e');
	  if (exp < 0) {
	    PSH('-');
	    exp = -exp;
	  } else {
	    PSH('+');
	  }

	  PSH('0'+exp/10);
	  exp -= (exp/10) * 10;
	  PSH('0'+exp);
  

 }

  PSH(0);


  return stin;
}

