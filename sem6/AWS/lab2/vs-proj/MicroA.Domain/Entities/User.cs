namespace MicroA.Domain.Entities
{
    public class User
    {
        public User(Guid id, string name, string surname, string email)
        {
            Id = id;
            Name = name;
            Surname = surname;
            Email = email;
        }

        public User(string name, string surname, string email)
        {
            Id = Guid.NewGuid();
            Name = name;
            Surname = surname;
            Email = email;
        }

        public Guid Id { get; protected set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string Email { get; set; }
    }
}
