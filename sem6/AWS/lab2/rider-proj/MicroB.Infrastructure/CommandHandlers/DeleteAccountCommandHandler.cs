using MediatR;
using MicroB.Domain.Commands;
using MicroB.Infrastructure.Repositories;

namespace MicroB.Infrastructure.CommandHandlers
{
    public class DeleteAccountCommandHandler : IRequestHandler<DeleteAccountCommand, bool>
    {
        private readonly IAccountRepository _accountRepository;
        public DeleteAccountCommandHandler(IAccountRepository accountRepository)
        {
            _accountRepository = accountRepository;
        }

        public async Task<bool> Handle(DeleteAccountCommand request, CancellationToken cancellationToken)
        {
            _accountRepository.Delete(request.IBAN);
            return await Task.FromResult(true);
        }
    }
}
