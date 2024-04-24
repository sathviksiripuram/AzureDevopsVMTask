using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.IO;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        // Add logging
        services.AddLogging();
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILogger<Startup> logger)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseRouting();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapGet("/", async context =>
            {

                context.Response.ContentType = "text/plain";


                DateTime currentTime = DateTime.Now;


                string greetingMessage = $"Hello World! Current server time is {currentTime}  Hello from VM-1";


                string requestPath = context.Request.Path;
                LogRequest(requestPath, currentTime, logger);


                await context.Response.WriteAsync(greetingMessage);
            });
            endpoints.MapFallback(async context =>
            {
                context.Response.ContentType = "text/plain";
                await context.Response.WriteAsync("404 - Not Found");
            });

        });
    }

    private void LogRequest(string path, DateTime timestamp, ILogger<Startup> logger)
    {

        logger.LogInformation($"[{timestamp}] Requested path: {path}");


        string logFilePath = "request.log";
        string logMessage = $"[{timestamp}] Requested path: {path}";


        File.AppendAllText(logFilePath, logMessage + Environment.NewLine);
    }
}

public class Program
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
