using MediatR;
using MicroB.Domain.DTO;

namespace MicroB.Domain.Queries
{
    public class GetAccountQuery : IRequest<AccountDto>
    {
        public string IBAN { get; protected set; }

        public GetAccountQuery(string iban) 
        {
            IBAN = iban;
        }
    }
}
