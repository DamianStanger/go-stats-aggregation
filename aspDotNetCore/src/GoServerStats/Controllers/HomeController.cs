using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace GoServerStats.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            _logger.LogInformation("Index called");
            return View();
        }

        public IActionResult About()
        {
            _logger.LogInformation("About called");
            ViewData["Message"] = "Your application description page.";

            return View();
        }

        public IActionResult Contact()
        {
            _logger.LogInformation("Contact called");
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Error()
        {
            _logger.LogInformation("Error called");
            return View();
        }
    }
}
