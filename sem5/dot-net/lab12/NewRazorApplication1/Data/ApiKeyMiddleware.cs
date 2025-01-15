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
            // Only check API key for requests starting with /api
            if (!context.Request.Path.StartsWithSegments("/api")) {
                await _next(context); // Skip middleware for non-API requests
                return;
            }

            // If the request is a GET, no API key is required
            if (context.Request.Method == HttpMethods.Get) {
                await _next(context); // Allow the request to continue
                return;
            }

            // For other methods like POST, PUT, DELETE, validate the API key
            var apiKeyHeader = context.Request.Headers["ApiKey"];

            // Check if the ApiKey header exists and is valid
            if (!apiKeyHeader.Any()) {
                _logger.LogWarning("API key is missing.");
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                await context.Response.WriteAsync("API key is missing.");
                return;
            }

            var apiKey = apiKeyHeader.FirstOrDefault();

            // Validate the API key from the database
            var keyRecord = await dbContext.ApiKeys
                .Where(a => a.Key == apiKey && a.IsActive)
                .FirstOrDefaultAsync();

            if (keyRecord == null) {
                _logger.LogWarning("Invalid or inactive API key.");
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                await context.Response.WriteAsync("Invalid or inactive API key.");
                return;
            }

            // API key is valid, proceed to the next middleware
            await _next(context);
        }
    }
}
