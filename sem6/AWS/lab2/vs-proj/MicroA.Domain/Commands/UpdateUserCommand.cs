namespace MicroA.Domain.Commands
{
    public class UpdateUserCommand : UserCommand
    {
        public UpdateUserCommand(Guid id, string name, string surname, string email) 
        { 
            Id = id;
            Name = name;
            Surname = surname;
            Email = email;
        }
    }
}
