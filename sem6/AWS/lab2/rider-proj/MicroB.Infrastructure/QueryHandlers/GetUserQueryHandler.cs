using MediatR;
using MicroB.Domain.DTO;
using MicroB.Domain.Queries;
using MicroB.Infrastructure.Repositories;
using PWC.Common.Domain.Bus;

namespace MicroB.Infrastructure.CommandHandlers
{
    public class GetAccountQueryHandler : IRequestHandler<GetAccountQuery, AccountDto>
    {
        private readonly IAccountRepository _accountRepository;

        public GetAccountQueryHandler(IAccountRepository accountRepository, IEventBus eventBus)
        {
            _accountRepository = accountRepository;
        }

        public async Task<AccountDto> Handle(GetAccountQuery request, CancellationToken cancellationToken)
        {
            var account = _accountRepository.FindById(request.IBAN);

            return await Task.FromResult(new AccountDto(account.OwnerId, account.IBAN, account.Balance, account.@Type, account.Status));
        }
    }
}
