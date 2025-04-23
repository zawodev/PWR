using MediatR;

namespace MicroB.Domain.Commands
{
    public class DeleteAccountCommand : IRequest<bool>
    {
        public string IBAN { get; set; }

        public DeleteAccountCommand(string iban) 
        {
            IBAN = iban;
        }
    }
}
