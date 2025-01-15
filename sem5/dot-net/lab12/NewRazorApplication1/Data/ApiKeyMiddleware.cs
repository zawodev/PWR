using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Threading.Tasks;
using WebApplication2Razor.Data;
using NewRazorApplication1.Data;

namespace NewRazorApplication1.Data {
    public class ApiKeyMiddleware {
        private readonly RequestDelegate _next;
        private readonly ILogger<ApiKeyMiddleware> _logger;

        public ApiKeyMiddleware(RequestDelegate next, ILogger<ApiKeyMiddleware> logger) {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, ShopDbContext dbContext) {
            Console.WriteLine(context.Request.Path);
            // only check ap[i key for requests starting with /api
            if (!context.Request.Path.StartsWithSegments("/api")) {
                await _next(context);
                return;
            }

            // if the request is a GET, no API key is required
            if (context.Request.Method == HttpMethods.Get) {
                await _next(context);
                return;
            }

            // if the request is a POST api/articles/AddToCart, no API key is required
            if (context.Request.Path.StartsWithSegments("/api/articles/AddToCart")) {
                await _next(context);
                return;
            }

            // for other methods like POST, PUT, DELETE, validate the API key
            var apiKeyHeader = context.Request.Headers["ApiKey"];

            // check if the apikye header exists and is valid
            if (!apiKeyHeader.Any()) {
                _logger.LogWarning("API key is missing");
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                await context.Response.WriteAsync("API key is missing");
                return;
            }

            var apiKey = apiKeyHeader.FirstOrDefault();

            var keyRecord = await dbContext.ApiKeys
                .Where(a => a.Key == apiKey && a.IsActive)
                .FirstOrDefaultAsync();

            if (keyRecord == null) {
                _logger.LogWarning("invalid or inactive API key");
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                await context.Response.WriteAsync("invalid or inactive API key");
                return;
            }

            await _next(context);
        }
    }
}
