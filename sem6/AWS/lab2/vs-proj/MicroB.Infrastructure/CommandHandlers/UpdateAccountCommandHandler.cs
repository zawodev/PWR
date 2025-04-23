using MediatR;
using MicroB.Domain.Commands;
using MicroB.Domain.Entities;
using MicroB.Infrastructure.Repositories;

namespace MicroB.Infrastructure.CommandHandlers
{
    public class UpdateAccountCommandHandler : IRequestHandler<UpdateAccountCommand, bool>
    {
        private readonly IAccountRepository _accountRepository;

        public UpdateAccountCommandHandler(IAccountRepository accountRepository)
        {
            _accountRepository = accountRepository;
        }

        public async Task<bool> Handle(UpdateAccountCommand request, CancellationToken cancellationToken)
        {
            _accountRepository.Update(new Account(request.IBAN, request.Balance, request.@Type, request.Status));
            return await Task.FromResult(true);
        }
    }
}
