using Microsoft.AspNetCore.Mvc;

namespace WebApplication1.Controllers {
    public class ToolController : Controller {
        [Route("Tool/Solve/{a}/{b}/{c}")]
        public IActionResult Solve(double a, double b, double c) {
            string resultMessage;
            string cssClass;

            if (a == 0 && b == 0 && c == 0) {
                resultMessage = "Równanie jest tożsamościowe.";
                cssClass = "identity";
            } else if (a == 0 && b == 0) {
                resultMessage = "Brak rozwiązań.";
                cssClass = "no-solutions";
            } else if (a == 0) {
                double x = -c / b;
                resultMessage = $"Równanie ma jedno rozwiązanie: x = {x:F2}.";
                cssClass = "one-solution";
            } else {
                double delta = b * b - 4 * a * c;
                if (delta < 0) {
                    resultMessage = "Brak rozwiązań rzeczywistych.";
                    cssClass = "no-solutions";
                } else if (delta == 0) {
                    double x = -b / (2 * a);
                    resultMessage = $"Równanie ma jedno rozwiązanie: x = {x:F2}.";
                    cssClass = "one-solution";
                } else {
                    double x1 = (-b - Math.Sqrt(delta)) / (2 * a);
                    double x2 = (-b + Math.Sqrt(delta)) / (2 * a);
                    resultMessage = $"Równanie ma dwa rozwiązania: x₁ = {x1:F2}, x₂ = {x2:F2}.";
                    cssClass = "two-solutions";
                }
            }

            ViewData["Message"] = resultMessage;
            ViewData["CssClass"] = cssClass;

            return View();
        }
    }
}
