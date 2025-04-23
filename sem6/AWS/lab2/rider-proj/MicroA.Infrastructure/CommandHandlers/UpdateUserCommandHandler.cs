using MediatR;
using MicroA.Domain.Commands;
using MicroA.Domain.Entities;
using MicroA.Infrastructure.Repositories;

namespace MicroA.Infrastructure.CommandHandlers
{
    public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, bool>
    {
        private readonly IUserRepository _userRepository;
        public UpdateUserCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<bool> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
        {
            _userRepository.Update(new User(request.Id, request.Name, request.Surname, request.Email));
            return await Task.FromResult(true);
        }
    }
}
