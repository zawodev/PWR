import java.util.Objects;
import java.util.Scanner;

public class Document{
	public String name;
	public TwoWayUnorderedListWithHeadAndTail<Link> link;
	public Document(String name, Scanner scan) {
		this.name=name;
		link=new TwoWayUnorderedListWithHeadAndTail<Link>();
		load(scan);
	}
	public void load(Scanner scan) {
		while (true){
			String line = scan.nextLine();

			if (Objects.equals(line, "eod")) break;

			for(String _link : line.split(" ")){
				if (correctLink(_link)){
					String match = _link.replaceAll("(?i)link=","").toLowerCase();
					if (!match.isEmpty()) link.add(new Link(match));
				}
			}
		}
	}
	// accepted only small letters, capitalic letter, digits nad '_' (but not on the begin)
	public static boolean correctLink(String link) {
		String pattern = "link=";

		if (link.length() < 5) return false;

		for(int i = 0; i < link.length(); i++){
			char c = link.charAt(i);

			// If uppercase, change to lowercase
			if (c >= 'A' && c <= 'Z'){
				c += 'a'-'A';
			}

			// Check if starting pattern matches
			if (i <= 4){
				if (c != pattern.charAt(i)) return false;
			}

			// Check if starts with a lowercase letter
			if (i == 5) {
				if (!(c >= 'a' && c <= 'z')) return false;
			}

			// Check if rest contains a number/lowercase letter/underscore
			if (i > 5){
				if (!(c >= '0' && c <= '9') && !(c >= 'a' && c<='z') && c != '_') return false;
			}
		}
		return true;
	}
	
	@Override
	public String toString() {
		StringBuilder info = new StringBuilder("Document: ").append(this.name);
		for (Link _link : this.link) {
			info.append("\n").append(_link.toString());
		}
		return info.toString();
	}
	
	public String toStringReverse() {
		String retStr="Document: "+name;
		return retStr+link.toStringReverse();
	}

}
