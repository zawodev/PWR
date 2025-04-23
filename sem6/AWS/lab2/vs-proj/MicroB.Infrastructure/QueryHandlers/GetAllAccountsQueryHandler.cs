using MediatR;
using MicroB.Domain.DTO;
using MicroB.Domain.Queries;
using MicroB.Infrastructure.Repositories;

namespace MicroB.Infrastructure.CommandHandlers
{
    public class GetAllAccountsQueryHandler : IRequestHandler<GetAllAccountsQuery, List<AccountDto>>
    {
        private readonly IAccountRepository _accountRepository;

        public GetAllAccountsQueryHandler(IAccountRepository accountRepository)
        {
            _accountRepository = accountRepository;
        }

        public async Task<List<AccountDto>> Handle(GetAllAccountsQuery request, CancellationToken cancellationToken)
        {
            return await Task.FromResult(_accountRepository
                .GetAll()
                .Select(account => new AccountDto(account.OwnerId, account.IBAN, account.Balance, account.@Type, account.Status))
                .ToList());
        }
    }
}
