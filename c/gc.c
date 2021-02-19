#include <stdio.h>

int main()
{
  char buf[1000];
  int gc=0;
  int total=0;
  char tablegc[256]={0,};
  char tabletotal[256]={0,};
  FILE *f=fopen("chry_multiplied.fa","r");
  tabletotal['A']=1;
  tabletotal['T']=1;
  tabletotal['C']=1;
  tabletotal['G']=1;
  tablegc['C']=1;
  tablegc['G']=1;
  while (fgets(buf,1000,f))
    if (*buf!='>') {
      char c, *ptr=buf;
      while ((c=*ptr++)) {
	total+=tabletotal[(int)c];
	gc+=tablegc[(int)c];
      }
    }
  fclose(f);
  printf("%.10f\n",(100.*gc)/total);
  return 0;
}
