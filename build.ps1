# Get the absolute root path of the repo
$RepoRoot = $PSScriptRoot

# 1. Build Boost
cd "$RepoRoot\boost"
.\bootstrap.bat
.\b2.exe link=static runtime-link=static threading=multi address-model=64 -a --layout=versioned

# 2. Build MPIR
cd "$RepoRoot\mpir\msvc\vs22"
.\msbuild.bat gc LIB x64 Release

# 3. Build MPFR (The problematic part)
cd "$RepoRoot\mpfr"
# Create the architecture folder if it's missing (needed for MPFR on modern systems)
if (-not (Test-Path "src\x86_64\corei5")) {
    New-Item -ItemType Directory -Force -Path "src\x86_64\corei5"
    Copy-Item -Path "src\x86_64\core2\*" -Destination "src\x86_64\corei5" -Recurse -Force
}

cd "$RepoRoot\mpfr\build.vs22\lib_mpfr"
msbuild /p:Configuration=Release /p:Platform=x64 lib_mpfr.vcxproj

# 4. Build Ledger
cd "$RepoRoot\ledger"
cmake -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_BUILD_TYPE:STRING="Release" `
    -DUSE_PYTHON=OFF `
    -DBUILD_LIBRARY=OFF `
    -DBUILD_DOCS:BOOL="0" `
    -DHAVE_REALPATH:BOOL="0" `
    -DHAVE_GETPWUID:BOOL="0" `
    -DHAVE_GETPWNAM:BOOL="0" `
    -DHAVE_IOCTL:BOOL="0" `
    -DHAVE_ISATTY:BOOL="0" `
    -DMPFR_LIB:FILEPATH="$RepoRoot/mpfr/build.vs22/lib/x64/Release/mpfr.lib" `
    -DGMP_LIB:FILEPATH="$RepoRoot/mpir/lib/x64/Release/mpir.lib" `
    -DMPFR_PATH:PATH="$RepoRoot/mpfr/lib/x64/Release" `
    -DGMP_PATH:PATH="$RepoRoot/mpir/lib/x64/Release" `
    -DBOOST_ROOT:PATH="$RepoRoot/boost/" `
    -DBoost_USE_STATIC_LIBS:BOOL="1" `
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="/MT /Zi /Ob0 /Od"

msbuild /p:Configuration=Release /p:Platform=x64 src\ledger.vcxproj

# 5. Move output to root
copy "$RepoRoot\ledger\src\Release\ledger.exe" "$RepoRoot\"
