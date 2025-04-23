using PWC.Common.Domain.Events;

namespace PWC.Common.Domain.Bus
{
    public interface IEventHandler<in TEvent> : IEventHandler where TEvent : Event
    {
        Task Handle(TEvent @event);

    }

    public interface IEventHandler { }
}
