import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;
import weka.core.converters.ArffSaver;
import weka.filters.Filter;
import weka.filters.unsupervised.attribute.Remove;
import java.io.File;

public class Main {
    public static void main(String[] args) {
        try {
            // wczytujemy naprawiony plik (numeric zamiast czegos tam string)
            DataSource source = new DataSource("272644L1_2_fixed.arff");
            Instances data = source.getDataSet();
            if (data.classIndex() == -1) {
                data.setClassIndex(data.numAttributes() - 1);
            }

            int statusIndex = data.attribute("status pozyczki").index();
            int kwotaIndex = data.attribute("kwota kredytu").index();

            // pętla od tyłu usuwająca rekody dla któychb odmowa
            for (int i = data.numInstances() - 1; i >= 0; i--) {
                String status = data.instance(i).stringValue(statusIndex);
                double kwota = data.instance(i).value(kwotaIndex);

                if (status.equals("odmowa") || kwota > 900.0) {
                    data.delete(i);
                }
            }

            // filtr usuwający kolumne
            Remove removeFilter = new Remove();
            removeFilter.setAttributeIndices(String.valueOf(statusIndex + 1));
            removeFilter.setInputFormat(data);
            Instances newData = Filter.useFilter(data, removeFilter);

            // zapis do pliku wynikowego
            ArffSaver saver = new ArffSaver();
            saver.setInstances(newData);
            saver.setFile(new File("272644L3_2.arff"));
            saver.writeBatch();

            System.out.println("program zakonczyl dzialanie sukcesem");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}