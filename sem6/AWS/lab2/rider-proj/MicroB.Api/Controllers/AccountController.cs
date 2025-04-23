using MediatR;
using MicroB.Domain.Commands;
using MicroB.Domain.DTO;
using MicroB.Domain.Queries;
using Microsoft.AspNetCore.Mvc;

namespace MicroB.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccountController : ControllerBase
    {

        private readonly ILogger<AccountController> _logger;
        private readonly IMediator _mediator;

        public AccountController(IMediator mediator, ILogger<AccountController> logger)
        {
            _logger = logger;
            _mediator = mediator;
        }

        [HttpGet("Account")]
        public async Task<ActionResult<AccountDto>> Get(string iban)
        {
            var result = await _mediator.Send(new GetAccountQuery(iban));
            return Ok(result);
        }

        [HttpGet("Accounts")]
        public async Task<ActionResult<List<AccountDto>>> GetAll()
        {
            var result = await _mediator.Send(new GetAllAccountsQuery());
            return Ok(result);
        }

        [HttpPut("Account")]
        public async Task<ActionResult> Put([FromBody] UpdateAccountDto dto)
        {
            await _mediator.Send(new UpdateAccountCommand(dto.IBAN, dto.Balance, dto.@Type, dto.Status));
            return Ok();
        }

        [HttpDelete("Account")]
        public async Task<ActionResult> Delete(string iban) 
        {
            await _mediator.Send(new DeleteAccountCommand(iban));
            return Ok();
        }

        [HttpPost("Account")]
        public async Task<ActionResult> Post([FromBody] CreateAccountDto dto) 
        {
            await _mediator.Send(new CreateAccountCommand(dto.OwnerId, dto.Balance, dto.@Type, dto.Status));
            return Ok(); 
        }
    }
}
