using MicroA.Domain.Entities;

namespace MicroA.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private List<User> _context {  get; set; }
        public UserRepository() 
        {
            _context = new List<User>();
        }

        public void Delete(Guid id)
        {
            var userToRemove = _context.Single(user => user.Id == id);
            _context.Remove(userToRemove);
        }

        public User FindById(Guid id)
        {
            return _context.First(user => user.Id == id);
        }

        public List<User> GetAll()
        {
            return _context;
        }

        public void Update(User user)
        {
            var userToUpdate = _context.First(u => u.Id == user.Id);
            
            userToUpdate.Name = user.Name;
            userToUpdate.Surname = user.Surname;
            userToUpdate.Email = user.Email;
        }

        public User Add(User user)
        {
            _context.Add(user);
            return user;
        }
    }
}
