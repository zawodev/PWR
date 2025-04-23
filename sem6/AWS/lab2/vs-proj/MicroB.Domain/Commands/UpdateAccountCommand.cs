using MediatR;
using MicroB.Domain.Enums;

namespace MicroB.Domain.Commands
{
    public class UpdateAccountCommand :IRequest<bool>
    {
        public string IBAN { get; set; }
        public decimal Balance { get; set; }
        public AccountType @Type { get; set; }
        public AccountStatus Status { get; set; }

        public UpdateAccountCommand(string iban, decimal balance, AccountType type, AccountStatus status)
        {
            IBAN = iban;
            Balance = balance;
            Type = type;
            Status = status;
        }
    }
}
