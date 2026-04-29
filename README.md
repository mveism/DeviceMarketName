# DeviceMarketName

[![NuGet](https://img.shields.io/nuget/v/DeviceMarketName.svg?style=flat-square)](https://www.nuget.org/packages/DeviceMarketName/)
[![Build status](https://ci.appveyor.com/api/projects/status/l9b1tv6vkwp3qkds?svg=true)](https://ci.appveyor.com/project/mveism/devicemarketname)

DeviceMarketName is a lightweight and user-friendly .NET library that enables you to look up Android device marketing names based on their model identifiers, leveraging Google's official `supported_devices.csv` data.

> ✅ **Ready to use – no extra steps, no CSV files, no scripts.**  
> All device mappings are pre-generated and embedded within the package. Just install the NuGet package and call a simple method.

---

## Library Features

- 🧩 Simple, lightweight, and efficient
- 🔍 Based on Google's official supported_devices.csv for accuracy and reliability
- ⚡ Fast lookups without loading the entire dataset into memory
- 🔧 Compatible with all .NET project types—including Console, Web, Desktop, MAUI, Xamarin.Android, etc.—without dependencies on Android-specific libraries
- 📂 No need to download or manage CSV files manually—everything is pre-built and embedded
- 🚀 No runtime dependency on external CSV resources
---

## Installation 🛠️

Add the package to your project via the command line:
```bash
dotnet add package DeviceMarketName
```
---

## Basic Usage (Ready-to-Use) 🚀

Simply reference the library and call the lookup method.
No additional setup, scripts, or configuration are required.
Look up a device’s marketing name with a single line.
Just include the namespace and call the lookup method:

```csharp
using DeviceMarketName;

string deviceModel = "Pixel 4";
string marketingName = DeviceLookup.GetMarketingName(deviceModel);
Console.WriteLine($"Device Model: {deviceModel}, Marketing Name: {marketingName}");
```

**That’s all you need.**  
The library works immediately after installation — there is absolutely no additional setup required. You do not need to download, inspect, or interact with Google’s `supported_devices.csv` file, and you never need to run any generation scripts and 

All device mappings are pre‑generated at build time and compiled directly into the assembly. The NuGet package does not include the `supported_devices.csv` file at all, and it is not used at runtime in any way. Everything is embedded and optimized for fast lookups out of the box.

### .NET for Android Usage
In a .NET for Android (Xamarin.Android) application you can directly use `Android.OS.Build.Model` to retrieve the device model and resolve its marketing name.
```csharp
using Android.OS;
using DeviceMarketName;

string marketingName = DeviceLookup.GetMarketingName(Build.Model);
```
---

## Customizing the Device Mappings (for Library Maintainers & Advanced Users) 🛠️

If you want to **modify the source code**, add new devices, or regenerate the lookup tables from the latest Google spreadsheet, the `DeviceMapGen.ps1` script is provided for that purpose.

> ⚠️ Normal use of the library **does not** require running this script. It is only for those who need to update or change the built-in mappings.

### How `DeviceMapGen.ps1` Works

`DeviceMapGen.ps1` is a PowerShell script that:
- Downloads the latest `supported_devices.csv` from Google (or uses a local copy if already present).
- Generates multiple partial C# files (`DeviceLookup_PartNNN.cs`) containing `switch` expressions for fast device lookup.
- Ensures the first matching marketing name is returned for each device model.

### Steps to Regenerate the Lookups

1. **Run the script** from the repository root:
   
```powershell
   .\DeviceMapGen.ps1
```

> *Regular users of the NuGet package do not need to run this script.*

2. The script will download the CSV (if needed) and generate/update the partial C# files in the project folder.
3. Rebuild the library – the new mappings will be compiled in.
After regeneration, the updated library can be packaged and distributed (or used locally) just like the official release.

#### *Script Features*
- Reads supported devices from the official CSV file
- Automatically downloads the file if it is missing
- Splits large mappings into multiple partial classes
- Generates efficient C# switch expressions for fast lookup
- Keeps the device database easy to update and maintain
This step is only required if you want to regenerate or modify the device mapping data.

## Contributing 🤝
Contributions are highly encouraged! Feel free to submit issues or pull requests to help improve this project.

## License ⚖️
This project is licensed under the MIT License.