using MicroB.Domain.Entities;

namespace MicroB.Infrastructure.Repositories
{
    public interface IAccountRepository
    {
        void Delete(string number);

        Account FindById(string number);

        List<Account> GetAll();

        void Update(Account account);

        void Add(Account account);
    }
}
