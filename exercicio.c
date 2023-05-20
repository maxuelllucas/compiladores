#include<stdio.h>

int main(){
    int i,j;
    i=j=1;
    printf("i = %d), j = %d, i+j = %d\n", i, j, i+j);
    j=2;
    printf("i = %d, j = %d, i+j = %d\n", i, j, i+j);
    return 0;
}