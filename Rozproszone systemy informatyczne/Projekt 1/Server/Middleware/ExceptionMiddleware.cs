﻿using Projekt_1_Web_Serwisy.Exceptions;
using System.Net;

namespace Projekt_1_Web_Serwisy.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _requestDelegate;

    public ExceptionMiddleware(RequestDelegate _requestDelegate) => this._requestDelegate = _requestDelegate;

    public async Task Invoke(HttpContext context)
    {
        try
        {
            await _requestDelegate(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        context.Response.ContentType = "text/plain";
        HttpStatusCode statusCode = HttpStatusCode.InternalServerError;

        switch (ex)
        {

            case NotFoundException or MotorbikeReservedException or MotorbikeNotReservedException
                 or MotorbikeCannotBeRentException or ThisMotorbikeIsNotRentedException:
                statusCode = HttpStatusCode.BadRequest;
                break;
            case CouldNotCreateInvoiceException:
                statusCode = HttpStatusCode.Conflict;
                break;
        }

        context.Response.StatusCode = (int)statusCode;
        return context.Response.WriteAsync(ex.Message);
    }
}

public static class SoapCoreExceptionMiddleware
{
    public static IApplicationBuilder UseSoapExceptionMiddleware(this IApplicationBuilder builder)
        => builder.UseMiddleware<ExceptionMiddleware>();
}
