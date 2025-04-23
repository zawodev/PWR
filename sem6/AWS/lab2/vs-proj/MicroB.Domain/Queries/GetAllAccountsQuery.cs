using MediatR;
using MicroB.Domain.DTO;

namespace MicroB.Domain.Queries
{
    public class GetAllAccountsQuery : IRequest<List<AccountDto>>
    {
        public GetAllAccountsQuery() { }
    }
}
