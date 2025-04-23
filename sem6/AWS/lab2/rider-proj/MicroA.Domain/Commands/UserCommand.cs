using PWC.Common.Domain.Commands;

namespace MicroA.Domain.Commands
{
    public abstract class UserCommand : Command
    {
        public string Name { get; protected set; }

        public string Surname { get; protected set; }

        public string Email { get; protected set; }

        public Guid Id { get; protected set; }
    }
}
