
# DeviceMarketName

DeviceMarketName is a lightweight .NET library for looking up Android device marketing names from their model identifiers using Google's official `supported_devices.csv`.

[![NuGet](https://img.shields.io/nuget/v/DeviceMarketName.svg?style=flat-square)](https://www.nuget.org/packages/DeviceMarketName/)
[![Build status](https://ci.appveyor.com/api/projects/status/l9b1tv6vkwp3qkds?svg=true)](https://ci.appveyor.com/project/mveism/devicemarketname)

## Installation

Install the package via NuGet:

```bash
dotnet add package DeviceMarketName
```

## Basic Usage

Add the library to your project:

```csharp
using DeviceMarketName;
```

Lookup a device's marketing name:

```csharp
var deviceModel = "Pixel 4";
var marketingName = DeviceLookup.GetMarketingName(deviceModel);
Console.WriteLine($"Device Model: {deviceModel}, Marketing Name: {marketingName}");
```

> **Note:** Before anything else, `DeviceMapGen.ps1` must be executed to generate the device lookup files.


---

## Device Lookup Generator (`DeviceMapGen.ps1`)

`DeviceMapGen.ps1` is a PowerShell script that automates download 'supported_devices.csv' from google then generates partial C# files for device lookup. It reads a CSV file containing device models and their corresponding marketing names, and produces strongly-typed C# `switch` expressions for the `DeviceLookup` class.

### How To Build

1. Run the script in PowerShell:

```powershell
.\DeviceMapGen.ps1
```

2. The script will download 'supported_devices.csv' then generate/update the partial C# files under the project folder.

### `DeviceMapGen.ps1` Features

- Reads supported devices from a CSV file (local copy or downloads if missing).  
- Generates multiple partial files (`DeviceLookup_PartNNN.cs`) to keep switch statements manageable.  
- Combines partial files in a main `DeviceLookup.cs` file.  
- Ensures that the first matching marketing name is returned for a device model.  
- Simplifies maintaining and updating device model mappings for Android applications.

---

## Library Features

- Lightweight and simple to use  
- Based on Google's official `supported_devices.csv`  
- Fast lookups without loading all data into memory  

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License.
