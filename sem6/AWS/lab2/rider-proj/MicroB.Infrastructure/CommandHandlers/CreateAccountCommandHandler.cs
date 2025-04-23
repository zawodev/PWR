using MediatR;
using MicroB.Domain.Commands;
using MicroB.Domain.Entities;
using MicroB.Infrastructure.Repositories;

namespace MicroB.Infrastructure.CommandHandlers
{
    public class CreateAccountCommandHandler : IRequestHandler<CreateAccountCommand, bool>
    {
        private readonly IAccountRepository _accountRepository;

        public CreateAccountCommandHandler(IAccountRepository accountRepository)
        {
            _accountRepository = accountRepository;
        }

        public async Task<bool> Handle(CreateAccountCommand request, CancellationToken cancellationToken)
        {
            _accountRepository.Add(new Account(request.OwnerId, request.Balance, request.@Type, request.Status));
            return await Task.FromResult(true);
        }
    }
}
