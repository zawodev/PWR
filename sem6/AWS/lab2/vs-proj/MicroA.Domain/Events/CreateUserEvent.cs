using PWC.Common.Domain.Events;

namespace MicroA.Domain.Events
{
    public class CreateUserEvent : Event
    {
        public Guid UserId { get; set; }

        public CreateUserEvent(Guid userId)
        {
            UserId = userId;
        }
    }
}
