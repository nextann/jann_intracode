#include <stdio.h>
#define read(x) scanf("%d",&x)
#define write(x) printf("%d\n",x)
int square ( int x ) {
int lvar[3];
lvar[0]=x*x;
lvar[1]=lvar[0]+500;
lvar[2]=lvar[1]/1000;
return lvar[2] ;
}
int complex_abs_squared ( int real , int imag ) {
int lvar[1];
lvar[0]=square(real)+square(imag);
return lvar[0] ;
}
int check_for_bail ( int real , int imag ) {
if ( real > 4000 || imag > 4000 ) goto l1t;
goto l1f;
l1t:;
return 0 ;
l1f:;
 if ( 1600 > complex_abs_squared(real,imag) ) goto l2t;
goto l2f;
l2t:;
return 0 ;
l2f:;
 return 1 ;
}
int absval ( int x ) {
int lvar[1];
if ( x < 0 ) goto l3t;
goto l3f;
l3t:;
lvar[0]=-1*x;
return lvar[0] ;
l3f:;
 return x ;
}
int checkpixel ( int x , int y ) {
int lvar[14];
lvar[0] = 0 ;
lvar[1] = 0 ;
lvar[3] = 0 ;
lvar[4] = 16000 ;
l4:;
if ( lvar[3] < 255 ) goto l5t;
goto l5f;
l5t:;
lvar[5]=square(lvar[0])-square(lvar[1]);
lvar[6]=lvar[5]+x;
lvar[2] = lvar[6] ;
lvar[7]=lvar[0]*lvar[1];
lvar[8]=2*lvar[7];
lvar[9]=lvar[8]+500;
lvar[10]=lvar[9]/1000;
lvar[11]=lvar[10]+y;
lvar[1] = lvar[11] ;
lvar[0] = lvar[2] ;
lvar[12]=absval(lvar[0])+absval(lvar[1]);
if ( lvar[12] > 5000 ) goto l6t;
goto l6f;
l6t:;
return 0 ;
l6f:;
 lvar[13]=lvar[3]+1;
lvar[3] = lvar[13] ;
goto l4;
l5f:;
 return 1 ;
}
int main ( ) {
int lvar[5];
lvar[1] = 950 ;
l7:;
if ( lvar[1] > -950 ) goto l8t;
goto l8f;
l8t:;
lvar[0] = -2100 ;
l9:;
if ( lvar[0] < 1000 ) goto l10t;
goto l10f;
l10t:;
lvar[2] = checkpixel(lvar[0],lvar[1]) ;
if ( 1 == lvar[2] ) goto l11t;
goto l11f;
l11t:;
printf ( "X" ) ;
l11f:;
 if ( 0 == lvar[2] ) goto l12t;
goto l12f;
l12t:;
printf ( " " ) ;
l12f:;
 lvar[3]=lvar[0]+40;
lvar[0] = lvar[3] ;
goto l9;
l10f:;
 printf ( "\n" ) ;
lvar[4]=lvar[1]-50;
lvar[1] = lvar[4] ;
goto l7;
l8f:;
 }
