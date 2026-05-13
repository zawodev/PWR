import weka.core.Instances;
import weka.core.Instance;
import weka.core.converters.ConverterUtils.DataSource;
import weka.filters.Filter;
import weka.filters.supervised.attribute.Discretize;

import java.util.*;

public class Lista9Zad2 {

    private static double LOG_BASE = 2.0;

    public static void main(String[] args) {
        try {
            // Wczytanie podstawy logarytmu z argumentów wywołania (domyślnie 2.0)
            if (args.length > 0) {
                LOG_BASE = Double.parseDouble(args[0]);
                if (LOG_BASE <= 0 || LOG_BASE == 1.0) {
                    throw new IllegalArgumentException("Podstawa logarytmu musi być > 0 i != 1");
                }
            }
            System.out.println("Podstawa logarytmu: " + LOG_BASE);

            // Wczytanie danych
            DataSource source = new DataSource("272644L3_1.arff");
            Instances data = source.getDataSet();

            // Ustawienie indeksu klasy
            data.setClassIndex(data.attribute("status pozyczki").index());

            // Dyskretyzacja całego zbioru (filtr nadzorowany) przed obliczeniami
            Discretize discretize = new Discretize();
            discretize.setInputFormat(data);
            data = Filter.useFilter(data, discretize);

            // Obliczenie głównej entropii zbioru H(Class)
            double classEntropy = entropy(data);
            System.out.println("Entropia klasy: " + classEntropy + "\n");

            // Formatowanie nagłówka tabeli
            System.out.printf("%-5s %-25s %-12s %-12s %-12s%n", "Nr", "Atrybut", "InfoGain", "SplitInfo", "GainRatio");
            System.out.println("--------------------------------------------------------------------------");

            // Analiza poszczególnych atrybutów
            for (int i = 0; i < data.numAttributes(); i++) {
                // Pomijamy klasę i ewentualne atrybuty numeryczne, które nie uległy dyskretyzacji
                if (i == data.classIndex() || data.attribute(i).isNumeric()) continue;

                double infoGain = classEntropy - conditionalEntropy(data, i);
                double splitInfo = splitInfo(data, i); // Odpowiada H(Attribute)

                double gainRatio = (splitInfo == 0) ? 0 : infoGain / splitInfo;

                System.out.printf("%-5d %-25s %-12.6f %-12.6f %-12.6f%n",
                        i, data.attribute(i).name(), infoGain, splitInfo, gainRatio);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Oblicza H(X) - entropię głównej klasy
    public static double entropy(Instances data) {
        Map<String, Integer> counts = new HashMap<>();
        for (Instance inst : data) {
            String cls = inst.stringValue(data.classIndex());
            counts.put(cls, counts.getOrDefault(cls, 0) + 1);
        }

        double entropy = 0.0;
        int total = data.numInstances();
        for (int count : counts.values()) {
            double p = (double) count / total;
            entropy -= p * logBase(p);
        }
        return entropy;
    }

    // Oblicza H(Class | Attribute) - sumuje entropię dla każdego wariantu atrybutu
    public static double conditionalEntropy(Instances data, int attrIndex) {
        Map<String, List<Instance>> groups = new HashMap<>();
        for (Instance inst : data) {
            String val = inst.stringValue(attrIndex);
            groups.computeIfAbsent(val, k -> new ArrayList<>()).add(inst);
        }

        double result = 0.0;
        int total = data.numInstances();

        for (List<Instance> subset : groups.values()) {
            // Tworzymy mniejszy zbiór z wierszami odpowiadającymi konkretnej wartości atrybutu
            Instances subData = new Instances(data, subset.size());
            for (Instance inst : subset) subData.add(inst);

            double weight = (double) subset.size() / total;
            result += weight * entropy(subData);
        }
        return result;
    }

    // Oblicza H(Attribute) - miarę rozproszenia samego atrybutu
    public static double splitInfo(Instances data, int attrIndex) {
        Map<String, Integer> counts = new HashMap<>();
        for (Instance inst : data) {
            String val = inst.stringValue(attrIndex);
            counts.put(val, counts.getOrDefault(val, 0) + 1);
        }

        double splitInfo = 0.0;
        int total = data.numInstances();
        for (int count : counts.values()) {
            double p = (double) count / total;
            splitInfo -= p * logBase(p);
        }
        return splitInfo;
    }

    // Matematyczny logarytm o zadanej podstawie
    public static double logBase(double x) {
        if (x <= 0.0) return 0.0;
        return Math.log(x) / Math.log(LOG_BASE);
    }
}