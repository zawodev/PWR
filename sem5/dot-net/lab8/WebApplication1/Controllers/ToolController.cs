using Microsoft.AspNetCore.Mvc;
using System;

namespace WebApplication1.Controllers {
    public class ToolController : Controller {
        [Route("Tool/Solve/{a}/{b}/{c}")]
        public IActionResult Solve(double a, double b, double c) {
            // najpierw obliczamy wyniki oddzielną metodą
            var solution = SolveQuadraticEquation(a, b, c);

            // dopiero później je wyświetlamy (generujemy wiadomość do wyświetlenia)
            var resultMessage = GenerateSolutionMessage(solution);

            ViewData["Message"] = resultMessage.message;
            ViewData["CssClass"] = resultMessage.cssClass;

            return View();
        }

        private static (int, double?, double?) SolveQuadraticEquation(double a, double b, double c) {
            if (a == 0) {
                if (b == 0) {
                    return c == 0 ? (-1, null, null) : (0, null, null);
                } else {
                    double x = -c / b;
                    return (1, x, null);
                }
            }

            double delta = b * b - 4 * a * c;

            if (delta < 0) {
                return (0, null, null);
            } else if (delta == 0) {
                double x = -b / (2 * a);
                return (1, x, null);
            } else {
                double x1 = (-b + Math.Sqrt(delta)) / (2 * a);
                double x2 = (-b - Math.Sqrt(delta)) / (2 * a);
                return (2, x1, x2);
            }
        }

        private static (string message, string cssClass) GenerateSolutionMessage((int solutionCount, double? x1, double? x2) solution) {
            return solution.solutionCount switch {
                -1 => ("Równanie ma nieskończenie wiele rozwiązań.", "identity"),
                0 => ("Równanie nie ma rozwiązań rzeczywistych.", "no-solutions"),
                1 => ($"Równanie ma jedno rozwiązanie: x = {solution.x1:F2}.", "one-solution"),
                2 => ($"Równanie ma dwa rozwiązania: x₁ = {solution.x1:F2}, x₂ = {solution.x2:F2}.", "two-solutions"),
                _ => ("Nieznany przypadek.", "error")
            };
        }
    }
}
