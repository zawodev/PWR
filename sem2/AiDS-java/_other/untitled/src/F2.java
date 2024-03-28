public class F2 implements SeriesGenerator<String>{
    @Override
    public String generate(int n) {
        String pom = "";

        for(int i = 0; i < n; i++)
        {
            pom=pom+"a";
        }

        return pom;
    }
}
