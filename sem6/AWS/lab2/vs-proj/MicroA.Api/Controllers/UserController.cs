using MediatR;
using MicroA.Domain.Commands;
using MicroA.Domain.DTO;
using MicroA.Domain.Queries;
using Microsoft.AspNetCore.Mvc;

namespace MicroA.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {

        private readonly ILogger<UserController> _logger;
        private readonly IMediator _mediator;

        public UserController(IMediator mediator, ILogger<UserController> logger)
        {
            _logger = logger;
            _mediator = mediator;
        }

        [HttpGet("User")]
        public async Task<ActionResult<UserDto>> Get(Guid id)
        {
            var result = await _mediator.Send(new GetUserQuery(id));
            return Ok(result);
        }

        [HttpGet("Users")]
        public async Task<ActionResult<List<UserDto>>> GetAll()
        {
            var result = await _mediator.Send(new GetAllUsersQuery());
            return Ok(result);
        }

        [HttpPut("User")]
        public async Task<ActionResult> Put([FromBody] UpdateUserDto dto)
        {
            await _mediator.Send(new UpdateUserCommand(dto.Id, dto.Name, dto.Surname, dto.Email));
            return Ok();
        }

        [HttpDelete("User")]
        public async Task<ActionResult> Delete(Guid id) 
        {
            await _mediator.Send(new DeleteUserCommand(id));
            return Ok();
        }

        [HttpPost("User")]
        public async Task<ActionResult> Post([FromBody] CreateUserDto dto) 
        {
            await _mediator.Send(new CreateUserCommand(dto.Name, dto.Surname, dto.Name));
            return Ok(); 
        }
    }
}
