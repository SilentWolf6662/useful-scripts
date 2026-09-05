#!/bin/bash

# 1. Hent applikationsnavn fra brugeren
read -p "Enter application name: " app

# Hvis brugeren ikke indtaster noget, stop scriptet
if [ -z "$app" ]; then
    echo "Application name cannot be empty."
    exit 1
fi

# 2. Bekræftelse
read -p "Are You Sure? (y/n): " choice
case "$choice" in 
  [yY][eE][sS]|[yY]) 
    echo "Creating $app..."
    ;;
  *)
    echo "Cancelled."
    exit 0
    ;;
esac

# 3. Opret og gå ind i projektmappen
mkdir -p "$app"
cd "$app" || exit

# 4. Opret projekter
dotnet new blazor -au None -o "${app}.WebUi"
dotnet new classlib -o "${app}.Application"
dotnet new classlib -o "${app}.Domain"
dotnet new nunit -o "${app}.Domain.Test"
dotnet new classlib -o "${app}.Infrastructure"

# 5. Tilføj interne projektreferencer
dotnet add "${app}.WebUi/${app}.WebUi.csproj" reference "${app}.Application/${app}.Application.csproj"
dotnet add "${app}.WebUi/${app}.WebUi.csproj" reference "${app}.Domain/${app}.Domain.csproj"
dotnet add "${app}.WebUi/${app}.WebUi.csproj" reference "${app}.Infrastructure/${app}.Infrastructure.csproj"
dotnet add "${app}.Domain.Test/${app}.Domain.Test.csproj" reference "${app}.Domain/${app}.Domain.csproj"
dotnet add "${app}.Application/${app}.Application.csproj" reference "${app}.Domain/${app}.Domain.csproj"
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" reference "${app}.Domain/${app}.Domain.csproj"
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" reference "${app}.Application/${app}.Application.csproj"

# 6. Opret løsning (SLN) og tilføj projekter
dotnet new sln -n "$app"
dotnet sln "${app}.sln" add "${app}.WebUi/${app}.WebUi.csproj"
dotnet sln "${app}.sln" add "${app}.Application/${app}.Application.csproj"
dotnet sln "${app}.sln" add "${app}.Domain/${app}.Domain.csproj"
dotnet sln "${app}.sln" add "${app}.Domain.Test/${app}.Domain.Test.csproj"
dotnet sln "${app}.sln" add "${app}.Infrastructure/${app}.Infrastructure.csproj"

# 7. Tilføj NuGet-pakker
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.EntityFrameworkCore
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.EntityFrameworkCore.SqlServer
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.EntityFrameworkCore.Tools
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.EntityFrameworkCore.Design
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.VisualStudio.Web.CodeGeneration.Design
dotnet add "${app}.WebUi/${app}.WebUi.csproj" package Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter

dotnet add "${app}.Application/${app}.Application.csproj" package Microsoft.Extensions.DependencyInjection
dotnet add "${app}.Application/${app}.Application.csproj" package Microsoft.Extensions.Configuration.Abstractions

dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" package Microsoft.EntityFrameworkCore
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.SqlServer
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.Tools
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" package Microsoft.Extensions.DependencyInjection
dotnet add "${app}.Infrastructure/${app}.Infrastructure.csproj" package Microsoft.Extensions.Configuration.Abstractions

dotnet add "${app}.Domain.Test/${app}.Domain.Test.csproj" package Moq

# 8. Opdater NuGet-pakker til nyeste versioner
echo "Updating NuGet packages..."
dotnet tool update --global dotnet-outdated-tool
export PATH="$PATH:$HOME/.dotnet/tools" # Sikrer at globale dotnet tools kan køres med det samme
dotnet outdated --upgrade

echo "Done!"
