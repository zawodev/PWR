using MicroA.Domain.Entities;

namespace MicroA.Infrastructure.Repositories
{
    public interface IUserRepository
    {
        List<User> GetAll();

        User FindById(Guid id);

        void Update(User user);

        void Delete(Guid id);

        User Add(User user);
    }
}
