using MediatR;
using MicroA.Domain.DTO;
using MicroA.Domain.Queries;
using MicroA.Infrastructure.Repositories;

namespace MicroA.Infrastructure.CommandHandlers
{
    public class GetUserQueryHandler : IRequestHandler<GetUserQuery, UserDto>
    {
        private readonly IUserRepository _userRepository;

        public GetUserQueryHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<UserDto> Handle(GetUserQuery request, CancellationToken cancellationToken)
        {
            var user = _userRepository.FindById(request.Id);

            return await Task.FromResult(new UserDto(user.Id, user.Name, user.Surname, user.Email));
        }
    }
}
