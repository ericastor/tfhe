#!/usr/bin/perl

open(F,"ctags -f - --fields=+S --excmd=number --c++-kinds=p --extra=+q *.h | grep -e '^[a-zA-Z]*::[a-zA-Z]*\\s.*signature:(' |");
open(G,">autogenerated.h");
open(H,">autogenerated.cpp");
print G <<EOF
//THIS  FILE IS AUTOMATICALLY GENERATED
//DO NOT EDIT BY HANDS
EOF
;
print H <<EOF
//THIS  FILE IS AUTOMATICALLY GENERATED
//DO NOT EDIT BY HANDS
#include "lwe.h"
#include <cstdlib>
#include <new>
using namespace std;
EOF
;

while ($line=<F>) {
    chop $line;
    $line =~ /^([a-zA-Z]+)::([a-zA-Z]+)\t([a-z.]*)\t.*signature:\((.*)\)$/;
    $struct = $1;
    $fname = $2;
    $file = $3;
    $sgn = $4;
    ($struct eq '') && next;
    ($struct eq $fname) || next;
    ($sgn eq "const $struct&") && next;
    $sgncall = $sgn;
    $sgncall =~ s/[^,]* +([a-zA-Z_]+)/\1/g;
    print "found: $file -- $struct"."::$fname($sgn) -- ($sgncall)\n";

    print G <<EOF
//allocate memory space for a $struct
EXPORT $struct* alloc_$struct();
EXPORT $struct* alloc_${struct}_array(int nbelts);

//free memory space for a $struct
EXPORT void free_$struct($struct* ptr);
EXPORT void free_${struct}_array(int nbelts, $struct* ptr);

//initialize the $struct structure
//(equivalent of the C++ constructor)
EXPORT void init_$struct($struct* obj, $sgn);
EXPORT void init_${struct}_array(int nbelts, $struct* obj, $sgn);

//destroys the $struct structure
//(equivalent of the C++ destructor)
EXPORT void destroy_$struct($struct* obj);
EXPORT void destroy_${struct}_array(int nbelts, $struct* obj);
 
//allocates and initialize the $struct structure
//(equivalent of the C++ new)
EXPORT $struct* new_$struct($sgn);
EXPORT $struct* new_${struct}_array(int nbelts, $sgn);

//destroys and frees the $struct structure
//(equivalent of the C++ delete)
EXPORT void delete_$struct($struct* obj);
EXPORT void delete_${struct}_array(int nbelts, $struct* obj);
EOF
;
    print H <<EOF
#include "$file" 
//allocate memory space for a $struct\n
EXPORT $struct* alloc_$struct() {
    return ($struct*) malloc(sizeof($struct));
}
EXPORT $struct* alloc_${struct}_array(int nbelts) {
    return ($struct*) malloc(nbelts*sizeof($struct));
}

//free memory space for a LWEKey
EXPORT void free_$struct($struct* ptr) {
    free(ptr);
}
EXPORT void free_${struct}_array(int nbelts, $struct* ptr) {
    free(ptr);
}

//initialize the key structure
//(equivalent of the C++ constructor)
EXPORT void init_$struct($struct* obj, $sgn) {
    new(obj) $struct($sgncall);
}
EXPORT void init_${struct}_array(int nbelts, $struct* obj, $sgn) {
    for (int i=0; i<nbelts; i++) {
	new(obj+i) $struct($sgncall);
    }
}

//destroys the $struct structure
//(equivalent of the C++ destructor)
EXPORT void destroy_$struct($struct* obj) {
    obj->~$struct();
}
EXPORT void destroy_${struct}_array(int nbelts, $struct* obj) {
    for (int i=0; i<nbelts; i++) {
	(obj+i)->~$struct();
    }
}
 
//allocates and initialize the $struct structure
//(equivalent of the C++ new)
EXPORT $struct* new_$struct($sgn) {
    return new $struct($sgncall);
}
EXPORT $struct* new_${struct}_array(int nbelts, $sgn) {
    $struct* obj = alloc_${struct}_array(nbelts);
    init_${struct}_array(nbelts,obj,$sgncall);
    return obj;
}

//destroys and frees the $struct structure
//(equivalent of the C++ delete)
EXPORT void delete_$struct($struct* obj) {
    delete obj;
}
EXPORT void delete_${struct}_array(int nbelts, $struct* obj) {
    destroy_${struct}_array(nbelts,obj);
    free_${struct}_array(nbelts,obj);
}
EOF
;

}
close G;
close H;
