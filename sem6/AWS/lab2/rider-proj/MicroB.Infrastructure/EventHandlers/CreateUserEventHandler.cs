using MediatR;
using MicroB.Domain.Commands;
using MicroB.Domain.Enums;
using MicroB.Domain.Events;
using PWC.Common.Domain.Bus;

namespace MicroB.Infrastructure.EventHandlers
{
    public class CreateUserEventHandler : IEventHandler<CreateUserEvent>
    {
        private readonly IMediator _mediator;

        public CreateUserEventHandler(IMediator mediator)
        {
            _mediator = mediator;
        }

        public async Task Handle(CreateUserEvent @event)
        {
            await _mediator.Send(new CreateAccountCommand(@event.UserId, 0, AccountType.PRP, AccountStatus.Active));
        }
    }
}
