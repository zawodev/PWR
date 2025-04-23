using MicroB.Domain.Enums;

namespace MicroB.Domain.DTO
{
    public class AccountDto
    {
        public Guid OwnerId { get; set; }
        public string IBAN { get; protected set; }
        public decimal Balance { get; set; }
        public AccountType @Type { get; set; }
        public AccountStatus Status { get; set; }

        public AccountDto(Guid ownerId, string iban, decimal balance, AccountType @type, AccountStatus status)
        {
            OwnerId = ownerId;
            IBAN = iban;
            Balance = balance;
            @Type = @type;
            Status = status;
        }
    }
}
