namespace MicroA.Domain.Commands
{
    public class DeleteUserCommand : UserCommand
    {
        public DeleteUserCommand(Guid id) 
        {
            Id = id;
        }
    }
}
