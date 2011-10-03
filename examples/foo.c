/* Sample C file with #ifdef conditions for Vimpeg ifdef.vim example */

#include <stdio.h>

#ifdef ALLOWED
int allowed_x = 1;
#else
int disallowed_x = 1;
#endif

#ifndef DISALLOWED
int allowed_y = 1;
#else
int disallowed_y = 1;
#endif

int main() {
  printf("%s\n", "Always here.");
}
