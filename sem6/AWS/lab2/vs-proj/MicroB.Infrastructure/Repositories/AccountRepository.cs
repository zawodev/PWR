using MicroB.Domain.Entities;

namespace MicroB.Infrastructure.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private List<Account> _context { get; set; }

        public AccountRepository()
        {
            _context = new List<Account>();
        }

        public void Delete(string iban)
        {
            var accountToRemove = _context.Single(account => account.IBAN == iban);
            _context.Remove(accountToRemove);
        }

        public Account FindById(string iban)
        {
            return _context.First(account => account.IBAN == iban);
        }

        public List<Account> GetAll()
        {
            return _context;
        }

        public void Update(Account account)
        {
            var accountToUpdate = _context.First(a => a.IBAN == account.IBAN);

            accountToUpdate.Status = account.Status;
            accountToUpdate.Balance = account.Balance;
            accountToUpdate.Type = account.Type;
        }

        public void Add(Account account)
        {
            _context.Add(account);
        }
    }
}
