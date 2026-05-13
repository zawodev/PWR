import weka.classifiers.AbstractClassifier;
import weka.classifiers.Classifier;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.functions.MultilayerPerceptron;
import weka.classifiers.functions.SMO;
import weka.classifiers.rules.JRip;
import weka.classifiers.rules.ZeroR;
import weka.classifiers.trees.J48;
import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;

import java.util.Random;

public class Lista10Zad1 {

    // ---------------------------------------------------------------
    // Klasa przechowująca wyniki dla jednego eksperymentu
    // ---------------------------------------------------------------
    static class Results {
        double[][] confusionMatrix; // [rzeczywista][przewidziana]
        double accuracy;
        double tpRate;
        double tnRate;
        double fpRate;
        double gMean;
        double auc;

        Results(int numClasses) {
            confusionMatrix = new double[numClasses][numClasses];
        }
    }

    // ---------------------------------------------------------------
    // zad 1: walidacja krzyżowa
    // Parametry:
    //   data        – wczytany zbiór Instances (klasa już ustawiona)
    //   classifier  – dowolny klasyfikator Weka
    //   numFolds    – liczba foldów N
    //   repetitions – liczba powtórzeń eksperymentu
    //   positiveClassIndex – indeks klasy pozytywnej w liście wartości atrybutu klasy
    // ---------------------------------------------------------------
    public static Results crossValidate(Instances data,
                                        Classifier classifier,
                                        int numFolds,
                                        int repetitions,
                                        int positiveClassIndex) throws Exception {

        int numClasses = data.numClasses();
        // Akumulatory dla uśredniania po powtórzeniach
        double[][] sumConfusion = new double[numClasses][numClasses];

        for (int rep = 0; rep < repetitions; rep++) {
            // Losowe przetasowanie zbioru (inne ziarno dla każdego powtórzenia)
            Instances shuffled = new Instances(data);
            shuffled.randomize(new Random(rep * 1000L + 42));

            // Stratyfikacja – zachowanie proporcji klas w foldach
            if (shuffled.classAttribute().isNominal()) {
                shuffled.stratify(numFolds);
            }

            // Macierz konfuzji dla tego powtórzenia (suma po foldach)
            // Macierz konfuzji dla tego powtórzenia (suma po foldach)
            double[][] repConfusion = new double[numClasses][numClasses];

            for (int fold = 0; fold < numFolds; fold++) {
                Instances train = shuffled.trainCV(numFolds, fold);
                Instances test  = shuffled.testCV(numFolds, fold);

                // Klonowanie klasyfikatora (każdy fold uczy od zera)
                Classifier clonedClassifier = AbstractClassifier.makeCopy(classifier);
                clonedClassifier.buildClassifier(train);

                // Klasyfikacja obserwacji testowych
                for (int i = 0; i < test.numInstances(); i++) {
                    int actual    = (int) test.instance(i).classValue();
                    int predicted = (int) clonedClassifier.classifyInstance(test.instance(i));
                    repConfusion[actual][predicted]++;
                }
            }

            // Dodaj macierz tego powtórzenia do sumy
            for (int r = 0; r < numClasses; r++) {
                for (int c = 0; c < numClasses; c++) {
                    sumConfusion[r][c] += repConfusion[r][c];
                }
            }
        }

        // Uśrednianie macierzy konfuzji po powtórzeniach
        Results results = new Results(numClasses);
        for (int r = 0; r < numClasses; r++) {
            for (int c = 0; c < numClasses; c++) {
                results.confusionMatrix[r][c] = sumConfusion[r][c] / repetitions;
            }
        }

        // Obliczanie metryk (dla klasyfikacji binarnej)
        // positiveClassIndex = 0 → klasa "pozytywna" to pierwsza wartość atrybutu
        int pos = positiveClassIndex;
        int neg = (pos == 0) ? 1 : 0;

        double tp = results.confusionMatrix[pos][pos];
        double fn = results.confusionMatrix[pos][neg];
        double fp = results.confusionMatrix[neg][pos];
        double tn = results.confusionMatrix[neg][neg];

        double total = tp + tn + fn + fp;

        results.accuracy = (tp + tn) / total;
        results.tpRate   = tp / (tp + fn);          // sensitivity / recall
        results.tnRate   = tn / (tn + fp);          // specificity
        results.fpRate   = fp / (fp + tn);          // FP rate
        results.gMean    = Math.sqrt(results.tpRate * results.tnRate);
        results.auc      = (1.0 + results.tpRate - results.fpRate) / 2.0;

        return results;
    }

    // ---------------------------------------------------------------
    // Wydruk wyników w czytelnej formie
    // ---------------------------------------------------------------
    static void printResults(String classifierName, Instances data, Results res, int positiveClassIndex) {

        int numClasses = data.numClasses();
        String[] classNames = new String[numClasses];
        for (int i = 0; i < numClasses; i++) {
            classNames[i] = data.classAttribute().value(i);
        }

        System.out.println("============================================================");
        System.out.println("Klasyfikator: " + classifierName);
        System.out.println("Klasa pozytywna: " + classNames[positiveClassIndex]);
        System.out.println("------------------------------------------------------------");

        // Macierz konfuzji
        System.out.println("Macierz konfuzji (wiersze=rzeczywiste, kolumny=przewidziane):");
        System.out.printf("%-20s", "");
        for (String cn : classNames) System.out.printf("%-15s", cn);
        System.out.println();
        for (int r = 0; r < numClasses; r++) {
            System.out.printf("%-20s", classNames[r]);
            for (int c = 0; c < numClasses; c++) {
                System.out.printf("%-15.2f", res.confusionMatrix[r][c]);
            }
            System.out.println();
        }

        System.out.println("------------------------------------------------------------");
        System.out.printf("Accuracy  : %.4f%n", res.accuracy);
        System.out.printf("TP rate   : %.4f%n", res.tpRate);
        System.out.printf("TN rate   : %.4f%n", res.tnRate);
        System.out.printf("FP rate   : %.4f%n", res.fpRate);
        System.out.printf("GMean     : %.4f%n", res.gMean);
        System.out.printf("AUC       : %.4f%n", res.auc);
        System.out.println("============================================================");
        System.out.println();
    }

    // ---------------------------------------------------------------
    // MAIN
    // ---------------------------------------------------------------
    public static void main(String[] args) throws Exception {

        if (args.length < 3) {
            System.out.println("<plik.arff> <numFolds> <repetitions> example usage: dane.arff 10 5");
            System.exit(1);
        }

        String arffPath  = args[0];
        int numFolds     = Integer.parseInt(args[1]);
        int repetitions  = Integer.parseInt(args[2]);

        // --- Wczytanie danych ---
        System.out.println("Wczytywanie danych z: " + arffPath);
        DataSource source = new DataSource(arffPath);
        Instances data = source.getDataSet();

        // Ustaw ostatni atrybut jako klasę
        if (data.classIndex() == -1) {
            data.setClassIndex(data.numAttributes() - 1);
        }

        System.out.println("Załadowano " + data.numInstances() + " instancji, " + data.numAttributes() + " atrybutów.");
        System.out.println("Klasa: " + data.classAttribute().name());
        System.out.println("Wartości klasy:");
        for (int i = 0; i < data.numClasses(); i++) {
            System.out.println("  [" + i + "] " + data.classAttribute().value(i));
        }
        System.out.println();

        int positiveClassIndex = 1; // =1 ponieważ klasa pozytywna zły klient

        System.out.println("Liczba foldów: " + numFolds);
        System.out.println("Liczba powtórzeń: " + repetitions);
        System.out.println();

        // ============================================================
        // Zad2: Lista klasyfikatorów do porównania
        // ============================================================

        // 1. ZeroR (baseline – zawsze przewiduje klasę większościową)
        runClassifier("ZeroR (domyślny)", new ZeroR(), data, numFolds, repetitions, positiveClassIndex);

        // 2. JRip – różne wartości parametru minNo (min. obserwacji na regułę)
        JRip jrip1 = new JRip(); jrip1.setMinNo(2);
        runClassifier("JRip (minNo=2)", jrip1, data, numFolds, repetitions, positiveClassIndex);

        JRip jrip2 = new JRip(); jrip2.setMinNo(4);
        runClassifier("JRip (minNo=4)", jrip2, data, numFolds, repetitions, positiveClassIndex);

        JRip jrip3 = new JRip(); jrip3.setMinNo(6);
        runClassifier("JRip (minNo=6)", jrip3, data, numFolds, repetitions, positiveClassIndex);

        // 3. J48 – różne wartości współczynnika przycinania (confidenceFactor)
        J48 j48a = new J48(); j48a.setConfidenceFactor(0.25f); j48a.setUnpruned(false);
        runClassifier("J48 (CF=0.25, pruned)", j48a, data, numFolds, repetitions, positiveClassIndex);

        J48 j48b = new J48(); j48b.setConfidenceFactor(0.10f); j48b.setUnpruned(false);
        runClassifier("J48 (CF=0.10, pruned)", j48b, data, numFolds, repetitions, positiveClassIndex);

        J48 j48c = new J48(); j48c.setUnpruned(true);
        runClassifier("J48 (unpruned)", j48c, data, numFolds, repetitions, positiveClassIndex);

        // 4. SMO – różne wartości C (parametr kary)
        SMO smo1 = new SMO(); smo1.setC(1.0);
        runClassifier("SMO (C=1.0)", smo1, data, numFolds, repetitions, positiveClassIndex);

        SMO smo2 = new SMO(); smo2.setC(0.5);
        runClassifier("SMO (C=0.5)", smo2, data, numFolds, repetitions, positiveClassIndex);

        SMO smo3 = new SMO(); smo3.setC(2.0);
        runClassifier("SMO (C=2.0)", smo3, data, numFolds, repetitions, positiveClassIndex);

        // 5. MultilayerPerceptron – różne topologie sieci
        MultilayerPerceptron mlp1 = new MultilayerPerceptron();
        mlp1.setHiddenLayers("a");           // "a" = (atrybuty+klasy)/2 neuronów
        mlp1.setTrainingTime(500);
        runClassifier("MLP (hidden=auto, iter=500)", mlp1, data, numFolds, repetitions, positiveClassIndex);

        MultilayerPerceptron mlp2 = new MultilayerPerceptron();
        mlp2.setHiddenLayers("10");          // 10 neuronów w jednej warstwie
        mlp2.setTrainingTime(500);
        runClassifier("MLP (hidden=10, iter=500)", mlp2, data, numFolds, repetitions, positiveClassIndex);

        MultilayerPerceptron mlp3 = new MultilayerPerceptron();
        mlp3.setHiddenLayers("10,5");        // dwie warstwy: 10 i 5 neuronów
        mlp3.setTrainingTime(500);
        runClassifier("MLP (hidden=10,5, iter=500)", mlp3, data, numFolds, repetitions, positiveClassIndex);

        // 6. NaiveBayes – z/bez estymacji jądrowej
        NaiveBayes nb1 = new NaiveBayes();
        nb1.setUseKernelEstimator(false);
        runClassifier("NaiveBayes (bez kernela)", nb1, data, numFolds, repetitions, positiveClassIndex);

        NaiveBayes nb2 = new NaiveBayes();
        nb2.setUseKernelEstimator(true);
        runClassifier("NaiveBayes (z kernelem)", nb2, data, numFolds, repetitions, positiveClassIndex);
    }

    // ---------------------------------------------------------------
    // funkcja pomocnicza: uruchom jeden klasyfikator i wydrukuj wyniki
    // ---------------------------------------------------------------
    static void runClassifier(String name, Classifier clf, Instances data, int folds, int reps, int posClassIdx) {
        try {
            Results res = crossValidate(data, clf, folds, reps, posClassIdx);
            printResults(name, data, res, posClassIdx);
        } catch (Exception e) {
            System.out.println("BŁĄD dla klasyfikatora " + name + ": " + e.getMessage());
        }
    }
}
