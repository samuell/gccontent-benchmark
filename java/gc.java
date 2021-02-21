import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class gc {

    /*
     * https://github.com/pditommaso/gccontent-benchmark
     */
    public static void main(String... args) throws IOException  {
        BufferedReader stream = new BufferedReader(new FileReader("chry_multiplied.fa"));

        int[] value = new int[256];
        value['A'] = value['T'] = value['G'] = value['C'] =0;

        String line;
        while( (line=stream.readLine())!= null ) {
            if( line.charAt(0)=='>' )
                continue;

            for( int i=0; i<line.length(); i++ ) {
                value[line.charAt(i)]++;
            }
        }

        int totalBaseCount = value['A'] + value['T'] + value['G'] + value['C'];
        int gcCount = value['G'] + value['C'];

        System.out.println((float)gcCount / (float)totalBaseCount  * 100);
    }

}
