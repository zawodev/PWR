using MediatR;
using MicroA.Domain.Commands;
using MicroA.Domain.DTO;
using MicroA.Domain.Queries;
using MicroA.Infrastructure.CommandHandlers;
using MicroA.Infrastructure.Repositories;
using PWC.Common.Domain.Bus;
using PWC.Infra.Bus;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(typeof(Program).Assembly));

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IUserRepository, UserRepository>();

builder.Services.AddSingleton<IEventBus, RabbitMQBus>(sp =>
{
    var scopeFactory = sp.GetRequiredService<IServiceScopeFactory>();
    return new RabbitMQBus(sp.GetService<IMediator>(), scopeFactory);
});

builder.Services.AddTransient<IRequestHandler<CreateUserCommand, bool>, CreateUserCommandHandler>();
builder.Services.AddTransient<IRequestHandler<UpdateUserCommand, bool>, UpdateUserCommandHandler>();
builder.Services.AddTransient<IRequestHandler<DeleteUserCommand, bool>, DeleteUserCommandHandler>();

builder.Services.AddTransient<IRequestHandler<GetAllUsersQuery, List<UserDto>>, GetAllUsersQueryHandler>();
builder.Services.AddTransient<IRequestHandler<GetUserQuery, UserDto>, GetUserQueryHandler>();

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

app.Run();
