using MediatR;
using MicroA.Domain.Commands;
using MicroA.Infrastructure.Repositories;

namespace MicroA.Infrastructure.CommandHandlers
{
    public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, bool>
    {
        private readonly IUserRepository _userRepository;

        public DeleteUserCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<bool> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
        {
            _userRepository.Delete(request.Id);
            return await Task.FromResult(true);
        }
    }
}
