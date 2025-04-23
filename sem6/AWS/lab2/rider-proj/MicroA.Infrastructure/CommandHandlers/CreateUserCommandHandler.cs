using MediatR;
using MicroA.Domain.Commands;
using MicroA.Domain.Entities;
using MicroA.Domain.Events;
using MicroA.Infrastructure.Repositories;
using PWC.Common.Domain.Bus;

namespace MicroA.Infrastructure.CommandHandlers
{
    public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, bool>
    {
        private readonly IEventBus _eventBus;
        private readonly IUserRepository _userRepository;

        public CreateUserCommandHandler(IUserRepository userRepository, IEventBus eventBus)
        {
            _userRepository = userRepository;
            _eventBus = eventBus;
        }

        public async Task<bool> Handle(CreateUserCommand request, CancellationToken cancellationToken)
        {
            var user = _userRepository.Add(new User(request.Name, request.Surname, request.Email));
            await _eventBus.Publish(new CreateUserEvent(user.Id));

            return await Task.FromResult(true);
        }
    }
}
