using MediatR;
using MicroB.Domain.Enums;

namespace MicroB.Domain.Commands
{
    public class CreateAccountCommand : IRequest<bool>
    {
        public Guid OwnerId { get; set; }
        public decimal Balance { get; set; }
        public AccountType @Type { get; set; }
        public AccountStatus Status { get; set; }

        public CreateAccountCommand(Guid ownerId, decimal balance, AccountType type, AccountStatus status)
        {
            OwnerId = ownerId;
            Balance = balance;
            Type = type;
            Status = status;
        }
    }
}
