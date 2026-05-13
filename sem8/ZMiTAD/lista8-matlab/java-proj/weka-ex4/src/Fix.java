import java.nio.file.Files;
import java.nio.file.Paths;

public class Fix {
    public static void main(String[] args) {
        try {
            System.out.println("Naprawiam plik...");
            // Wczytujemy cały Twój oryginalny plik jako jeden wielki tekst
            String content = Files.readString(Paths.get("272644L3_1.arff"));
            
            // 1. Wyłapujemy liczby w apostrofach z przecinkiem (np. '496,83') 
            // i zamieniamy je na ułamek z kropką (496.83). 
            // Magia wyrażeń regularnych ($1 to część przed przecinkiem, $2 to po przecinku).
            content = content.replaceAll("'(\\d+),(\\d+)'", "$1.$2");
            
            // 2. Zamieniamy błędną definicję atrybutu (tę długą listę) na poprawny typ liczbowy (numeric)
            content = content.replaceAll("@attribute 'kwota kredytu' \\{.*\\}", "@attribute 'kwota kredytu' numeric");

            // Zapisujemy idealnie czysty plik pod nową nazwą
            Files.writeString(Paths.get("272644L3_1_fixed.arff"), content);
            
            System.out.println("Gotowe! Teraz możesz używać pliku: 272644L3_1_fixed.arff");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}