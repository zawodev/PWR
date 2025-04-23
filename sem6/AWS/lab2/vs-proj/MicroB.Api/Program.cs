using MediatR;
using MicroB.Api.Extensions;
using MicroB.Domain.Commands;
using MicroB.Domain.DTO;
using MicroB.Domain.Events;
using MicroB.Domain.Queries;
using MicroB.Infrastructure.CommandHandlers;
using MicroB.Infrastructure.EventHandlers;
using MicroB.Infrastructure.Repositories;
using PWC.Common.Domain.Bus;
using PWC.Infra.Bus;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(typeof(Program).Assembly));

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IAccountRepository, AccountRepository>();

builder.Services.AddSingleton<IEventBus, RabbitMQBus>(sp =>
{
    var scopeFactory = sp.GetRequiredService<IServiceScopeFactory>();
    return new RabbitMQBus(sp.GetService<IMediator>(), scopeFactory);
});

builder.Services.AddTransient<CreateUserEventHandler>();
builder.Services.AddTransient<IEventHandler<CreateUserEvent>, CreateUserEventHandler>();

builder.Services.AddTransient<IRequestHandler<CreateAccountCommand, bool>, CreateAccountCommandHandler>();
builder.Services.AddTransient<IRequestHandler<UpdateAccountCommand, bool>, UpdateAccountCommandHandler>();
builder.Services.AddTransient<IRequestHandler<DeleteAccountCommand, bool>, DeleteAccountCommandHandler>();

builder.Services.AddTransient<IRequestHandler<GetAllAccountsQuery, List<AccountDto>>, GetAllAccountsQueryHandler>();
builder.Services.AddTransient<IRequestHandler<GetAccountQuery, AccountDto>, GetAccountQueryHandler>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.ConfigureEventBus();

app.Run();
