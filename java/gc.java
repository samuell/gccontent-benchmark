import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class gc {

  /*
   * https://github.com/pditommaso/gccontent-benchmark
   */
  public static void main(String... args) throws IOException  {
      BufferedReader stream = new BufferedReader(new FileReader("chry_multiplied.fa"));

      int a = 0;
      int t = 0;
      int g = 0;
      int c = 0;

      String line;
      while( (line=stream.readLine())!= null ) {
        if( line.charAt(0)=='>' )
            continue;

        for( int i=0; i<line.length(); i++ ) {
            switch (line.charAt(i)) {
                case 'A': a++; break;
                case 'C': c++; break;
                case 'G': g++; break;
                case 'T': t++; break;
            }
        }

      }

      int totalBaseCount = a + t + g + c;
      int gcCount = g + c;

      System.out.println((float)gcCount / (float)totalBaseCount  * 100);
  }

}
