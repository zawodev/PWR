using MediatR;
using MicroA.Domain.DTO;
using MicroA.Domain.Queries;
using MicroA.Infrastructure.Repositories;

namespace MicroA.Infrastructure.CommandHandlers
{
    public class GetAllUsersQueryHandler : IRequestHandler<GetAllUsersQuery, List<UserDto>>
    {
        private readonly IUserRepository _userRepository;

        public GetAllUsersQueryHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<List<UserDto>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
        {
            return await Task.FromResult(_userRepository.GetAll().Select(user => new UserDto(user.Id, user.Name, user.Surname, user.Email)).ToList());
        }
    }
}
