#!/bin/bash
set -ev
dotnet restore StudentAPI.sln --no-cache
dotnet test ./StudentAPI.Tests/StudentAPI.Tests.csproj
dotnet publish StudentAPI.sln -c Release -o out