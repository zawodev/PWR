package Exercise3;

public class SMSRequest {
    private final String phoneNumber;
    private final String message;

    public SMSRequest(String phoneNumber, String message) {
        this.phoneNumber = phoneNumber;
        this.message = message;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getMessage() {
        return message;
    }
}
