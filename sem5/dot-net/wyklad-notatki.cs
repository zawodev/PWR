// read about Razor engine

public static void Main()
{
    var template = @"
    <html>
        <head>
            <title>@Model.Title</title>
        </head>
        <body>
            <h1>@Model.Title</h1>
            <p>@Model.Content</p>
        </body>
    </html>";

    var model = new { Title = "Hello, World!", Content = "This is a simple web page." };

    var result = Razor.Parse(template, model);

    Console.WriteLine(result);
}