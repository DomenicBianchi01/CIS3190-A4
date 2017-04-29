all: programs

programs:
	gcc -Wall -std=c99 kmp.c -o kmpC
	gfortran -Wall -std=f2003 kmp.f95 -o kmpFortran
	gnatmake kmp.adb -Wall -o kmpAda
