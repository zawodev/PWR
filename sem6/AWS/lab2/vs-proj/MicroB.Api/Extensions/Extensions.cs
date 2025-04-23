using MicroB.Domain.Events;
using MicroB.Infrastructure.EventHandlers;
using PWC.Common.Domain.Bus;

namespace MicroB.Api.Extensions
{
    public static class Extensions
    {

        public static void ConfigureEventBus(this WebApplication app)
        {
            var eventBus = app.Services.GetRequiredService<IEventBus>();
            eventBus.Subscribe<CreateUserEvent, CreateUserEventHandler>();

        }

    }
}
