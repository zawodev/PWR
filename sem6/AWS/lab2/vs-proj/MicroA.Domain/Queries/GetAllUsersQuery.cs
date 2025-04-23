using MediatR;
using MicroA.Domain.DTO;

namespace MicroA.Domain.Queries
{
    public class GetAllUsersQuery : IRequest<List<UserDto>>
    {
        public GetAllUsersQuery() { }
    }
}
