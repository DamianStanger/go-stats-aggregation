using GoServerStats.Services;
using Xunit;

namespace GoServerStats.Tests
{	
    public class FoobarTest
    {
        private readonly Foobar _foobar;
         public FoobarTest()
         {
             _foobar = new Foobar();
         }

        [Fact]
        public void ReturnFalseGivenValueOf1()
        {
            var result = _foobar.Foo();

            Assert.Equal(result, 2);
        }

        [Fact]
        public void Return1()
        {
            var result = _foobar.Foo();

            Assert.Equal(result, 1);
        }
    }
}