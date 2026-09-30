#!/bin/sh

if command -v mono
then
    mono openvr_osc.exe "$@"
elif command -v dotnet
then
    dotnet openvr_osc.exe "$@"
else
    echo "No .NET runner is available. Please install mono or dotnet."
fi
