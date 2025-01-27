﻿using Microsoft.AspNetCore.Mvc;

namespace WebApplication1.Controllers {
    public class GameController : Controller {
        private static int range = 100;
        private static int randomValue;
        private static int attempts;
        
        // dotychczasowe próby zgadnięcia liczby w formie listy intów
        private static List<int> guesses = new List<int>();

        [Route("Set,{n}")]
        public IActionResult Set(int n) {
            range = n;

            ViewData["Message"] = $"zakres ustawiony na {n}";
            return View();
            //return Content($"Zakres ustawiony na {n}."); // ?? lepiej nie content chyba
        }

        [Route("Draw")]
        public IActionResult Draw() {
            Random random = new Random();
            randomValue = random.Next(0, range);
            attempts = 0;
            guesses.Clear();

            ViewData["Message"] = $"wylosowano nową liczbę z zakresu [0, {range}]";
            return View();
            //return Content("Wylosowano nową liczbę.");
        }

        [Route("Guess,{guess}")]
        public IActionResult Guess(int guess) {
            attempts++;
            string message;
            guesses.Add(guess);

            if (guess < randomValue) {
                message = "za mało";
            } else if (guess > randomValue) {
                message = "za dużo";
            } else {
                message = $"FENOMENALNIE! zgadłeś liczbę {randomValue} w {attempts} próbach";
            }

            ViewData["Message"] = message;
            ViewData["Attempts"] = attempts;
            ViewData["Guesses"] = guesses;

            return View();
        }
    }
}
