# ============================================================================
# MULTI-STAGE DOCKERFILE EXPLANATION (For Beginners)
# ============================================================================
# This Dockerfile uses TWO stages (two FROM statements):
# 
# STAGE 1: BUILD STAGE (Lines 12-19)
#   - Uses: dotnet/sdk:7.0 (has compilers, build tools - BIG image ~1GB)
#   - Purpose: Compile your C# code into executable files
#   - Result: Creates compiled files in /source/publish folder
#   - This stage is THROWN AWAY after building (not included in final image)
#
# STAGE 2: RUNTIME STAGE (Lines 22-25)
#   - Uses: dotnet/runtime:7.0 (only runtime - SMALL image ~200MB)
#   - Purpose: Run your compiled application
#   - Copies: Only the compiled files from Stage 1
#   - Result: Final small, efficient Docker image
#
# WHY TWO STAGES?
#   Imagine building a house:
#   - Stage 1 = Construction site (needs tools, materials, workers)
#   - Stage 2 = Finished house (only needs furniture, no construction tools)
#   You don't ship the construction site, only the finished house!
# ============================================================================

# because of dotnet, we always build on amd64, and target platforms in cli
# dotnet doesn't support QEMU for building or running. 
# (errors common in arm/v7 32bit) https://github.com/dotnet/dotnet-docker/issues/1537
# https://hub.docker.com/_/microsoft-dotnet
# hadolint ignore=DL3029
# to build for a different platform than your host, use --platform=<platform>
# for example, if you were on Intel (amd64) and wanted to build for ARM, you would use:
# docker buildx build --platform "linux/arm64/v8" .

# ============================================================================
# STAGE 1: BUILD STAGE
# ============================================================================
# Start with SDK image (has everything needed to BUILD/COMPILE code)
FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/sdk:7.0 AS build
# The "AS build" gives this stage a name so we can reference it later

# Set working directory inside container (like cd /source)
WORKDIR /source

# Copy ONLY the .csproj file first (Docker optimization trick)
# This allows Docker to cache the restore step if project file doesn't change
COPY *.csproj .

# Download all NuGet packages your project needs
# (like npm install for Node.js, or pip install for Python)
RUN dotnet restore

# Now copy ALL your source code files (.cs files, etc.)
COPY . .

# COMPILE your code into executable files
# -c Release = Build in Release mode (optimized, no debug info)
# -r linux-x64 = Target Linux 64-bit platform
# --self-contained false = Don't bundle .NET runtime (we'll use the one in runtime image)
# -o ./publish = Output compiled files to ./publish folder
RUN dotnet publish -c Release -r linux-x64 --self-contained false -o ./publish
# After this, your compiled app is in /source/publish folder
# This stage is now DONE - we got what we need (the compiled files)


# ============================================================================
# STAGE 2: RUNTIME STAGE (Final Image)
# ============================================================================
# Start FRESH with a smaller runtime-only image (no build tools!)
FROM mcr.microsoft.com/dotnet/runtime:7.0
# This is a NEW, clean container - Stage 1 is gone!

# Set working directory for running the app
WORKDIR /app

# Copy ONLY the compiled files from Stage 1 (the /source/publish folder)
# COPY --from=build means "copy from the stage named 'build'"
COPY --from=build /source/publish .

# Tell Docker what command to run when container starts
# This runs: dotnet Worker.dll
ENTRYPOINT ["dotnet", "Worker.dll"]
# When you run the container, it executes this command automatically

