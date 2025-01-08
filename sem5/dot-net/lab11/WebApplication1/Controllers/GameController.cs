using Microsoft.AspNetCore.Mvc;

namespace WebApplication1.Controllers {
    public class GameController : Controller {
        // property to access session values for range
        private int Range {
            get => HttpContext.Session.GetInt32("Range") ?? 30; // default range
            set => HttpContext.Session.SetInt32("Range", value);
        }

        private int RandomValue {
            get => HttpContext.Session.GetInt32("RandomValue") ?? 0;
            set => HttpContext.Session.SetInt32("RandomValue", value);
        }

        private int Attempts {
            get => HttpContext.Session.GetInt32("Attempts") ?? 0;
            set => HttpContext.Session.SetInt32("Attempts", value);
        }

        private List<int> Guesses {
            get => HttpContext.Session.GetString("Guesses") != null
                ? Newtonsoft.Json.JsonConvert.DeserializeObject<List<int>>(HttpContext.Session.GetString("Guesses"))
                : new List<int>();
            set => HttpContext.Session.SetString("Guesses", Newtonsoft.Json.JsonConvert.SerializeObject(value));
        }

        [Route("Set,{n}")]
        public IActionResult Set(int n) {
            Range = n;

            ViewData["Message"] = $"Zakres ustawiony na {n}";
            return View();
        }

        [Route("Draw")]
        public IActionResult Draw() {
            Random random = new Random();
            RandomValue = random.Next(0, Range);
            Attempts = 0;
            Guesses = new List<int>();

            ViewData["Message"] = $"Wylosowano nową liczbę z zakresu [0, {Range}]";
            return View();
        }

        [Route("Guess,{guess}")]
        public IActionResult Guess(int guess) {
            Attempts++;
            var guesses = Guesses;
            guesses.Add(guess);
            Guesses = guesses;

            string message;

            if (guess < RandomValue) {
                message = "Za mało";
            } else if (guess > RandomValue) {
                message = "Za dużo";
            } else {
                message = $"FENOMENALNIE! Zgadłeś liczbę {RandomValue} w {Attempts} próbach.";
            }

            ViewData["Message"] = message;
            ViewData["Attempts"] = Attempts;
            ViewData["Guesses"] = Guesses;

            return View();
        }
    }
}
