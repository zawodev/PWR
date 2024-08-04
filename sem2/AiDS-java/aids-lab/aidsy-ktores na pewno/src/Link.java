import java.util.Objects;

public class Link{
	public String ref;
	// in the future there will be more fields
	public Link(String ref) {
		this.ref=ref;
	}
	@Override
	public String toString() {
		return this.ref;
	}
	@Override
	public boolean equals(Object obj) {
		return Objects.equals(this.ref, obj.toString());
	}
	
}