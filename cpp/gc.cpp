#include <string>
#include <fstream>
#include <iostream>

int main() {

    std::fstream fs("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa", std::ios::in);

    int a = 0;
    int t = 0;
    int g = 0;
    int c = 0;

    if ( fs.is_open() )  {
        std::string line;
        while (std::getline(fs, line)) {
            if(*(line.begin()) != '>') {
                for(std::string::const_iterator pos = line.begin(); pos!=line.end() ; ++pos){
                     switch (*pos){
                       case 'A' :
                         a++;
                         break;

                       case 'C' :
                         c++;
                         break;

                       case 'G' :
                         g++;
                         break;

                       case 'T' :
                         t++;
                         break;

                       default:
                         break;
                     }
                }
          }
    }
    //std::cout << "gcCount: " << gcCount << " / totalBaseCount: "<< totalBaseCount << " = " ;
    int totalBaseCount = a + t + g + c;
    int gcCount = g + c;
    std::cout << ( (float)gcCount / (float)totalBaseCount ) * 100 << std::endl ;
  } else {
    std::cout << "can't open file" ;
  }
  return 0 ;
}
