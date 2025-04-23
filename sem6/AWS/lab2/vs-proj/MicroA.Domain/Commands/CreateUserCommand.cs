namespace MicroA.Domain.Commands
{
    public class CreateUserCommand : UserCommand
    {
        public CreateUserCommand(string name, string surname, string email)
        {
            Name = name;
            Surname = surname;
            Email = email;
        }
    }
}
