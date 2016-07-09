using FluentAssertions;
using GoServerStats.Controllers;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace GoServerStats.Tests.Controllers
{
    public class HomeControllerTests
    {
        [Fact]
        public void ShouldReturnIndexView()
        {
            var homeController = new HomeController();
            var actionResult = (ViewResult) homeController.Index();
            actionResult.ViewName.Should().BeNull();
            actionResult.ViewData.Count.Should().Be(0);
        }

    }
}