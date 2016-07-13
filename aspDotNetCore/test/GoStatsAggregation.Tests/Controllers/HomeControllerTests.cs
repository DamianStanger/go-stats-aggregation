using FluentAssertions;
using GoStatsAggregation.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace GoStatsAggregation.Tests.Controllers
{
    public class HomeControllerTests
    {
        //        private readonly Mock<ILogger<HomeController>> _logger;
        private readonly HomeController _homeController;
        private ILogger<HomeController> _logger;
        //        private IConfigurationRoot Configuration { get; }

        public HomeControllerTests()
        {
            //            _logger = new Mock<ILogger<HomeController>>();
            //            _logger.Setup(l => l.LogInformation(It.IsAny<string>()));
            //            _homeController = new HomeController(_logger.Object);

            LoggerFactory lf = new LoggerFactory();
            ILoggerFactory loggerFactory = lf.AddConsole();
            _logger = loggerFactory.CreateLogger<HomeController>();

            _homeController = new HomeController(_logger);
        }


        [Fact]
        public void ShouldReturnIndexView()
        {
            var actionResult = (ViewResult)_homeController.Index();
            actionResult.ViewName.Should().BeNull();
            actionResult.ViewData.Count.Should().Be(0);
        }

    }
}