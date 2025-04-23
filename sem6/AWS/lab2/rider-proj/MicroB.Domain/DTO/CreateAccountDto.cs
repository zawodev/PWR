using MicroB.Domain.Enums;

namespace MicroB.Domain.DTO
{
    public class CreateAccountDto
    {
        public Guid OwnerId { get; set; }
        public decimal Balance { get; set; }
        public AccountType @Type { get; set; }
        public AccountStatus Status { get; set; }
    }
}
