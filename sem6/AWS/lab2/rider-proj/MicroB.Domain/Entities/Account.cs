using MicroB.Domain.Enums;
using SinKien.IBAN4Net;

namespace MicroB.Domain.Entities
{
    public class Account
    {
        public Guid OwnerId { get; set; }
        public string IBAN { get; protected set; }
        public decimal Balance { get; set; }
        public AccountType @Type { get; set; }
        public AccountStatus Status { get; set; }

        public Account(string iban, decimal balance, AccountType @type, AccountStatus status)
        {
            IBAN = iban;
            Balance = balance;
            @Type = @type;
            Status = status;
        }

        public Account(Guid ownerId, decimal balance, AccountType @type, AccountStatus status)
        {
            OwnerId = ownerId;
            Balance = balance;
            @Type = @type;
            Status = status;
            IBAN = new IbanBuilder()
                .CountryCode(CountryCode.GetCountryCode("CZ"))
                .BankCode("0800")
                .AccountNumberPrefix("000019")
                .AccountNumber(new Random().NextInt64(1000000000, 9999999999).ToString())
                .Build()
                .ToString();
        }
    }
}
