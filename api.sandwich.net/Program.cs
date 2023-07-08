using api.sandwich.net.Models;
using Microsoft.EntityFrameworkCore;

public partial class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}

internal class Startup
{

    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    private IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
        // Add services to the container.

        services.AddControllers();

        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen();

        var connString = Configuration.GetConnectionString("DataStore");
        services.AddDbContext<SandwichContext>(options =>
        {
            options.UseNpgsql(connString);
        });
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {

        // Configure the HTTP request pipeline.
        if (env.IsDevelopment())
        {
        }

        app.UseSwagger();
        app.UseSwaggerUI();

        app.UseRouting();
        app.UseEndpoints(endpoints => { endpoints.MapControllers(); });

    }

}
