using MediatR;
using MicroA.Domain.DTO;

namespace MicroA.Domain.Queries
{
    public class GetUserQuery : IRequest<UserDto>
    {
        public Guid Id { get; protected set; }

        public GetUserQuery(Guid id) 
        {
            Id = id;
        }
    }
}
